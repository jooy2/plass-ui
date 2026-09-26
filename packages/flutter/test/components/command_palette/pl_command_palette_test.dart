import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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
  const _Host({this.open = true, this.onSelect, this.shortcut, this.items = commands});

  final bool open;
  final ValueChanged<PlCommandItem>? onSelect;
  final String? shortcut;
  final List<PlCommandItem> items;

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
