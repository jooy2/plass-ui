import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

Widget _subject({
  bool? open,
  bool arrow = false,
  bool disabled = false,
  ValueChanged<bool>? onOpenChanged,
  Duration delay = Duration.zero,
  Duration closeDelay = Duration.zero,
}) {
  return PlHoverCard(
    open: open,
    arrow: arrow,
    disabled: disabled,
    delay: delay,
    closeDelay: closeDelay,
    onOpenChanged: onOpenChanged,
    title: const Text('Ada Lovelace'),
    description: const Text('Mathematician'),
    trigger: const Text('Ada'),
    child: const Text('Wrote the first algorithm intended for a machine.'),
  );
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(host(child, width: 400, overlay: true));
  await tester.pumpAndSettle();
}

/// Moves a mouse onto [finder] and leaves it there.
Future<TestGesture> _hover(WidgetTester tester, Finder finder) async {
  final TestGesture pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await pointer.addPointer(location: Offset.zero);
  addTearDown(pointer.removePointer);

  await pointer.moveTo(tester.getCenter(finder));
  await tester.pumpAndSettle();

  return pointer;
}

void main() {
  group('PlHoverCard', () {
    testWidgets('draws nothing until the pointer rests on the trigger', (
      WidgetTester tester,
    ) async {
      await _pump(tester, _subject());

      expect(find.text('Mathematician'), findsNothing);
    });

    testWidgets('opens on the pointer and closes when it leaves', (WidgetTester tester) async {
      await _pump(tester, _subject());

      final TestGesture pointer = await _hover(tester, find.text('Ada'));

      expect(find.text('Mathematician'), findsOneWidget);

      await pointer.moveTo(const Offset(1, 1));
      await tester.pumpAndSettle();

      expect(find.text('Mathematician'), findsNothing);
    });

    testWidgets('stays open while the pointer is on the card itself', (WidgetTester tester) async {
      await _pump(tester, _subject());

      final TestGesture pointer = await _hover(tester, find.text('Ada'));

      // The whole difference from a tooltip: the gap between the trigger and
      // the card has no pointer in it, so leaving the trigger for the card must
      // not close it.
      await pointer.moveTo(tester.getCenter(find.text('Mathematician')));
      await tester.pumpAndSettle();

      expect(find.text('Mathematician'), findsOneWidget);
    });

    testWidgets('takes an open state from outside', (WidgetTester tester) async {
      await _pump(tester, _subject(open: true));

      expect(find.text('Mathematician'), findsOneWidget);
    });

    testWidgets('reports every change through `onOpenChanged`', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await _pump(tester, _subject(onOpenChanged: changes.add));
      await _hover(tester, find.text('Ada'));

      expect(changes, <bool>[true]);
    });

    testWidgets('waits out its delay before opening', (WidgetTester tester) async {
      await _pump(tester, _subject(delay: const Duration(milliseconds: 400)));

      final TestGesture pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await pointer.addPointer(location: Offset.zero);
      addTearDown(pointer.removePointer);

      await pointer.moveTo(tester.getCenter(find.text('Ada')));
      await tester.pump(const Duration(milliseconds: 200));

      // A card that opened the moment a pointer crossed a link would open on
      // every link on the way to somewhere else.
      expect(find.text('Mathematician'), findsNothing);

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Mathematician'), findsOneWidget);
    });

    testWidgets('does not open at all when it is disabled', (WidgetTester tester) async {
      await _pump(tester, _subject(disabled: true));
      await _hover(tester, find.text('Ada'));

      expect(find.text('Mathematician'), findsNothing);
    });

    testWidgets('draws the wedge only when it is asked for one', (WidgetTester tester) async {
      await _pump(tester, _subject(open: true));

      final int without = find.byType(CustomPaint).evaluate().length;

      await _pump(tester, _subject(open: true, arrow: true));

      expect(find.byType(CustomPaint).evaluate().length, greaterThan(without));
    });

    testWidgets('names the title as a heading', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await _pump(tester, _subject(open: true));

      expect(
        tester.getSemantics(find.text('Ada Lovelace').last),
        matchesSemantics(label: 'Ada Lovelace', isHeader: true),
      );

      handle.dispose();
    });
  });
}
