import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/surface.dart';

import '../../support/host.dart';

const List<PlCommandItem> commands = <PlCommandItem>[
  PlCommandItem(value: 'new', label: 'New document', group: 'File', shortcut: 'Mod+N'),
  PlCommandItem(value: 'open', label: 'Open', group: 'File', keywords: <String>['load']),
  PlCommandItem(
    value: 'copy',
    label: 'Copy',
    group: 'Edit',
    description: 'Put it on the clipboard',
  ),
  PlCommandItem(value: 'gone', label: 'Unavailable', group: 'Edit', disabled: true),
];

/// The palette with a caller holding its open state, which is the only shape
/// this build offers.
class _Host extends StatefulWidget {
  const _Host({
    this.open = true,
    this.onSelect,
    this.shortcut,
    this.items = commands,
    this.placeholder,
  });

  final bool open;
  final ValueChanged<PlCommandItem>? onSelect;
  final String? shortcut;
  final List<PlCommandItem> items;
  final String? placeholder;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late bool _open = widget.open;

  @override
  Widget build(BuildContext context) {
    return PlCommandPalette(
      items: widget.items,
      open: _open,
      shortcut: widget.shortcut,
      onOpenChanged: (bool next) => setState(() => _open = next),
      onSelect: widget.onSelect,
      placeholder: widget.placeholder,
    );
  }
}

void main() {
  group('PlCommandPalette', () {
    testWidgets('is not on screen until it is opened', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const _Host(open: false), width: 700, height: 500, overlay: true),
      );

      expect(find.text('New document'), findsNothing);
    });

    testWidgets('draws every command, in the order it was given', (WidgetTester tester) async {
      await tester.pumpWidget(host(const _Host(), width: 700, height: 500, overlay: true));
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(find.text('New document')).dy,
        lessThan(tester.getTopLeft(find.text('Open')).dy),
      );
      expect(
        tester.getTopLeft(find.text('Open')).dy,
        lessThan(tester.getTopLeft(find.text('Copy')).dy),
      );
    });

    testWidgets('draws a heading each time the group changes', (WidgetTester tester) async {
      await tester.pumpWidget(host(const _Host(), width: 700, height: 500, overlay: true));
      await tester.pumpAndSettle();

      expect(find.text('File'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('draws a description and a shortcut when there is one', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const _Host(), width: 700, height: 500, overlay: true));
      await tester.pumpAndSettle();

      expect(find.text('Put it on the clipboard'), findsOneWidget);
      expect(find.byType(PlHotKeys), findsOneWidget);
    });

    testWidgets('washes the highlighted row in the family s hover tint', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const _Host(), width: 700, height: 500, overlay: true));
      await tester.pumpAndSettle();

      final PlassColorFamily family = PlassTokens.light().family(PlassColor.primary);
      // The first row, which the palette opens on.
      final List<Color?> fills = decorationsOf(
        tester,
        find.ancestor(of: find.text('New document'), matching: find.byType(PlassSurfaceBox)).first,
      ).map((BoxDecoration decoration) => decoration.color).toList();

      // As a `PlSelect` or a `PlMenu` row is, and as the React row's
      // `--p-soft-hover` is, rather than the paler resting tint.
      expect(fills, contains(family.softHover));
      expect(fills, isNot(contains(family.soft)));
    });

    testWidgets('shows the placeholder until something is typed', (WidgetTester tester) async {
      await tester.pumpWidget(host(const _Host(), width: 700, height: 500, overlay: true));
      await tester.pumpAndSettle();

      expect(find.text('Search commands'), findsOneWidget);
    });

    group('searching', () {
      testWidgets('narrows the list to what was typed', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Host(), width: 700, height: 500, overlay: true));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(EditableText), 'copy');
        await tester.pumpAndSettle();

        expect(find.text('Copy'), findsOneWidget);
        expect(find.text('New document'), findsNothing);
      });

      testWidgets('matches keywords that are never drawn', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Host(), width: 700, height: 500, overlay: true));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(EditableText), 'load');
        await tester.pumpAndSettle();

        expect(find.text('Open'), findsOneWidget);
        // The keyword matched but is never drawn as a row.
        expect(find.text('New document'), findsNothing);
        expect(find.text('Copy'), findsNothing);
      });

      testWidgets('folds case, so COPY finds Copy', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Host(), width: 700, height: 500, overlay: true));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(EditableText), 'COPY');
        await tester.pumpAndSettle();

        expect(find.text('Copy'), findsOneWidget);
      });

      testWidgets('says so when nothing matched', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Host(), width: 700, height: 500, overlay: true));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(EditableText), 'zzzzz');
        await tester.pumpAndSettle();

        expect(find.text('Nothing here'), findsOneWidget);
      });
    });

    group('running a command', () {
      testWidgets('calls the command s own handler and then the palette s', (
        WidgetTester tester,
      ) async {
        int own = 0;
        final List<PlCommandItem> seen = <PlCommandItem>[];

        await tester.pumpWidget(
          host(
            _Host(
              onSelect: seen.add,
              items: <PlCommandItem>[
                PlCommandItem(value: 'copy', label: 'Copy', onSelect: () => own += 1),
              ],
            ),
            width: 700,
            height: 500,
            overlay: true,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Copy'));
        await tester.pumpAndSettle();

        expect(own, 1);
        expect(seen.single.value, 'copy');
        // And closes afterwards.
        expect(find.text('Copy'), findsNothing);
      });

      testWidgets('runs nothing for a disabled command', (WidgetTester tester) async {
        final List<PlCommandItem> seen = <PlCommandItem>[];

        await tester.pumpWidget(
          host(
            _Host(
              onSelect: seen.add,
              items: const <PlCommandItem>[
                PlCommandItem(value: 'gone', label: 'Unavailable', disabled: true),
              ],
            ),
            width: 700,
            height: 500,
            overlay: true,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Unavailable'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(seen, isEmpty);
        expect(find.text('Unavailable'), findsOneWidget);
      });

      testWidgets('runs the highlighted row on Enter, moved by the arrow keys', (
        WidgetTester tester,
      ) async {
        final List<PlCommandItem> seen = <PlCommandItem>[];

        await tester.pumpWidget(
          host(_Host(onSelect: seen.add), width: 700, height: 500, overlay: true),
        );
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(seen.single.value, 'open');
      });
    });

    group('a long list', () {
      final List<PlCommandItem> many = <PlCommandItem>[
        for (int i = 0; i < 500; i += 1) PlCommandItem(value: 'c$i', label: 'Command $i'),
      ];

      testWidgets('builds only the rows near the view', (WidgetTester tester) async {
        await tester.pumpWidget(host(_Host(items: many), width: 700, height: 500, overlay: true));
        await tester.pumpAndSettle();

        expect(find.text('Command 0'), findsOneWidget);
        expect(find.text('Command 499'), findsNothing);
      });

      testWidgets('keeps the highlighted row in view as the arrow keys move it', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(_Host(items: many), width: 700, height: 500, overlay: true));
        await tester.pumpAndSettle();

        for (int i = 0; i < 30; i += 1) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pump();
        }
        await tester.pumpAndSettle();

        final Rect list = tester.getRect(find.byType(ListView));
        final Rect row = tester.getRect(find.text('Command 30'));

        expect(row.top, greaterThanOrEqualTo(list.top));
        expect(row.bottom, lessThanOrEqualTo(list.bottom));
      });

      testWidgets('keeps the row the keys chose as the list scrolls under a resting pointer', (
        WidgetTester tester,
      ) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.windows;

        final List<String> seen = <String>[];

        await tester.pumpWidget(
          host(
            _Host(
              items: many,
              shortcut: 'Mod+K',
              onSelect: (PlCommandItem item) => seen.add(item.value),
            ),
            width: 700,
            height: 500,
            overlay: true,
          ),
        );
        await tester.pumpAndSettle();

        final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(mouse.removePointer);
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(tester.getCenter(find.text('Command 2')));
        await tester.pump();

        // Down from the row the pointer lit, past the foot of the list, which
        // scrolls other rows under the pointer as it follows the keys.
        for (int i = 0; i < 15; i += 1) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pumpAndSettle();
        }

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(seen, <String>['c17']);

        // Nor does a list opening under it light the row it lands on.
        seen.clear();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(seen, <String>['c0']);

        // A pointer that moves again lights the row it is on.
        seen.clear();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pumpAndSettle();
        await mouse.moveTo(tester.getCenter(find.text('Command 5')));
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(seen, <String>['c5']);

        debugDefaultTargetPlatformOverride = null;
      });
    });

    group('the shortcut', () {
      testWidgets('opens on the keystroke it was given', (WidgetTester tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.windows;

        await tester.pumpWidget(
          host(const _Host(open: false, shortcut: 'Mod+K'), width: 700, height: 500, overlay: true),
        );

        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pumpAndSettle();

        expect(find.text('New document'), findsOneWidget);

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('binds nothing when it is told not to', (WidgetTester tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.windows;

        await tester.pumpWidget(
          host(const _Host(open: false), width: 700, height: 500, overlay: true),
        );

        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pumpAndSettle();

        expect(find.text('New document'), findsNothing);

        debugDefaultTargetPlatformOverride = null;
      });
    });

    group('focus', () {
      FocusNode field(WidgetTester tester) {
        return tester.widget<EditableText>(find.byType(EditableText)).focusNode;
      }

      /// A focus stop, and the palette after it once [built], which is how an
      /// app that builds the palette only while it is open has it.
      Widget page(FocusNode opener, {required bool built, bool open = true}) {
        return host(
          Column(
            children: <Widget>[
              Focus(focusNode: opener, child: const SizedBox.square(dimension: 1)),
              if (built) PlCommandPalette(items: commands, open: open),
            ],
          ),
          width: 700,
          height: 500,
          overlay: true,
        );
      }

      testWidgets('puts it in the field when the palette is built open', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const _Host(), width: 700, height: 500, overlay: true));
        await tester.pumpAndSettle();

        expect(field(tester).hasPrimaryFocus, isTrue);

        // Typed straight in, with no tap on the field first. The palette's own
        // scope held the focus, and the words went nowhere.
        tester.testTextInput.enterText('copy');
        await tester.pumpAndSettle();

        expect(find.text('Copy'), findsOneWidget);
        expect(find.text('New document'), findsNothing);
      });

      testWidgets('puts it in the field when the palette is opened later', (
        WidgetTester tester,
      ) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.windows;

        await tester.pumpWidget(
          host(const _Host(open: false, shortcut: 'Mod+K'), width: 700, height: 500, overlay: true),
        );

        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pumpAndSettle();

        expect(field(tester).hasPrimaryFocus, isTrue);

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('gives it back to where it was when a palette built open closes', (
        WidgetTester tester,
      ) async {
        final FocusNode opener = FocusNode(debugLabel: 'opener');
        addTearDown(opener.dispose);

        await tester.pumpWidget(page(opener, built: false));
        opener.requestFocus();
        await tester.pump();

        await tester.pumpWidget(page(opener, built: true));
        await tester.pumpAndSettle();

        expect(field(tester).hasPrimaryFocus, isTrue);

        await tester.pumpWidget(page(opener, built: true, open: false));
        await tester.pumpAndSettle();

        expect(find.byType(EditableText), findsNothing);
        expect(opener.hasPrimaryFocus, isTrue);
      });
    });

    group('accessibility', () {
      testWidgets('names each row once, by what it draws', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(host(const _Host(), width: 700, height: 500, overlay: true));
        await tester.pumpAndSettle();

        // The label, then the description and the shortcut, which is one node
        // named by its keys in order. The sheet is lifted into an overlay,
        // which `find.semantics` does not reach, so the tree is walked.
        expect(
          semanticsLabels(tester),
          containsAllInOrder(<String>[
            'New document\nCtrl N',
            'Open',
            'Copy\nPut it on the clipboard',
            'Unavailable',
          ]),
        );

        handle.dispose();
      });

      testWidgets('names the field by its placeholder, typed into or not', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(host(const _Host(), width: 700, height: 500, overlay: true));
        await tester.pumpAndSettle();

        // The editor's own node carries the words, as the React input takes its
        // name from its placeholder, and the drawn placeholder is not a second
        // node beside it reading them again.
        expect(
          semanticsNodeLabelled(tester, 'Search commands'),
          isSemantics(isTextField: true, label: 'Search commands', value: ''),
        );
        expect(
          semanticsLabels(tester).where((String label) => label.contains('Search commands')),
          hasLength(1),
        );

        // The placeholder leaves once something is typed, and the name stays.
        await tester.enterText(find.byType(EditableText), 'copy');
        await tester.pumpAndSettle();

        expect(find.text('Search commands'), findsNothing);
        expect(
          semanticsNodeLabelled(tester, 'Search commands'),
          isSemantics(isTextField: true, label: 'Search commands', value: 'copy'),
        );

        handle.dispose();
      });

      testWidgets('gives the field a screen reader s tap and focus', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(host(const _Host(), width: 700, height: 500, overlay: true));
        await tester.pumpAndSettle();

        SemanticsNode field() => semanticsNodeLabelled(tester, 'Search commands')!;
        FocusNode focus() => tester.widget<EditableText>(find.byType(EditableText)).focusNode;

        Future<void> perform(SemanticsAction action) async {
          field().owner!.performAction(field().id, action);
          await tester.pumpAndSettle();
        }

        // Neither was on the node, so a screen reader on the web, which only
        // moves the focus onto the field's `<input>`, never put the caret in
        // the field, and TalkBack's double tap did nothing.
        expect(
          field(),
          isSemantics(
            isTextField: true,
            label: 'Search commands',
            hasTapAction: true,
            hasFocusAction: true,
          ),
        );

        focus().unfocus();
        await tester.pumpAndSettle();
        await perform(SemanticsAction.focus);

        expect(focus().hasFocus, isTrue);

        // Focused with the keyboard put away, the field gets it back from
        // either.
        for (final SemanticsAction action in <SemanticsAction>[
          SemanticsAction.focus,
          SemanticsAction.tap,
        ]) {
          await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
          expect(tester.testTextInput.isVisible, isFalse, reason: action.name);

          await perform(action);

          expect(tester.testTextInput.isVisible, isTrue, reason: action.name);
        }

        expect(find.text('Open'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('brings the keyboard back as a press lands on the field, once', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const _Host(), width: 700, height: 500, overlay: true));
        await tester.pumpAndSettle();

        final Finder editor = find.byType(EditableText);

        expect(tester.widget<EditableText>(editor).focusNode.hasFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);

        // The keyboard put away under the focus, as Android's back does. The
        // caret of an empty field is already where the press puts it, which on
        // its own asks for no keyboard.
        await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
        tester.testTextInput.log.clear();
        await tester.tap(editor);
        await tester.pumpAndSettle();

        expect(tester.testTextInput.isVisible, isTrue);
        expect(
          tester.testTextInput.log.where((MethodCall call) => call.method == 'TextInput.show'),
          hasLength(1),
        );
      });

      testWidgets('names the field by a placeholder of the caller s own', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          host(
            const _Host(placeholder: 'What do you want to do?'),
            width: 700,
            height: 500,
            overlay: true,
          ),
        );
        await tester.pumpAndSettle();

        expect(
          semanticsNodeLabelled(tester, 'What do you want to do?'),
          isSemantics(isTextField: true, label: 'What do you want to do?'),
        );
        expect(semanticsLabels(tester), isNot(contains('Search commands')));

        handle.dispose();
      });

      testWidgets('offers no tap but the field and the rows, and closes on Escape', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(host(const _Host(), width: 700, height: 500, overlay: true));
        await tester.pumpAndSettle();

        // The backdrop was a node the size of the screen with no name whose
        // tap closed the palette. The React backdrop is hidden from a screen
        // reader while the dialog is open.
        expect(semanticsLabelsWithAction(tester, SemanticsAction.tap), <String>[
          'Search commands',
          'New document\nCtrl N',
          'Open',
          'Copy\nPut it on the clipboard',
        ]);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        expect(find.text('Open'), findsNothing);

        handle.dispose();
      });

      testWidgets('keeps a row a button, and a disabled one a disabled button', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(host(const _Host(), width: 700, height: 500, overlay: true));
        await tester.pumpAndSettle();

        expect(
          semanticsNodeLabelled(tester, 'Open'),
          isSemantics(isButton: true, isSelected: false, hasTapAction: true),
        );
        expect(
          semanticsNodeLabelled(tester, 'Unavailable'),
          isSemantics(isButton: true, hasEnabledState: true, isEnabled: false, hasTapAction: false),
        );

        handle.dispose();
      });
    });
  });
}
