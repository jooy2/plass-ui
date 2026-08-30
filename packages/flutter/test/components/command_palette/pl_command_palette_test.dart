import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

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

        expect(find.text('No commands found'), findsOneWidget);
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
  });
}
