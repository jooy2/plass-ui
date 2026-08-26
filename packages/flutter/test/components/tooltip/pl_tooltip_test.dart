import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

Widget _tooltip({
  PlassSide side = PlassSide.top,
  PlassSize size = PlassSize.sm,
  bool arrow = true,
  bool disabled = false,
  Duration delay = const Duration(milliseconds: 600),
  ValueChanged<bool>? onOpenChanged,
  Widget content = const Text('Copy'),
}) {
  return host(
    Center(
      child: PlTooltip(
        content: content,
        size: size,
        side: side,
        arrow: arrow,
        disabled: disabled,
        delay: delay,
        onOpenChanged: onOpenChanged,
        child: const SizedBox(width: 80, height: 32, child: Text('Trigger')),
      ),
    ),
    overlay: true,
  );
}

/// Rests the pointer on the trigger, and hands back the gesture so a test can
/// take it away again.
Future<TestGesture> _rest(WidgetTester tester) async {
  final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
  addTearDown(pointer.removePointer);
  await pointer.addPointer(location: Offset.zero);
  await pointer.moveTo(tester.getCenter(find.text('Trigger')));
  await tester.pump();

  return pointer;
}

void main() {
  group('PlTooltip', () {
    group('opening', () {
      testWidgets('waits out the delay before it appears', (WidgetTester tester) async {
        await tester.pumpWidget(_tooltip());
        await _rest(tester);

        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Copy'), findsNothing);

        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
        expect(find.text('Copy'), findsOneWidget);
      });

      testWidgets('goes when the pointer leaves', (WidgetTester tester) async {
        await tester.pumpWidget(_tooltip(delay: Duration.zero));
        final pointer = await _rest(tester);
        await tester.pumpAndSettle();
        expect(find.text('Copy'), findsOneWidget);

        await pointer.moveTo(const Offset(4, 4));
        await tester.pumpAndSettle();
        expect(find.text('Copy'), findsNothing);
      });

      testWidgets('reports both ways round', (WidgetTester tester) async {
        final reported = <bool>[];
        await tester.pumpWidget(_tooltip(delay: Duration.zero, onOpenChanged: reported.add));

        final pointer = await _rest(tester);
        await tester.pumpAndSettle();
        await pointer.moveTo(const Offset(4, 4));
        await tester.pumpAndSettle();

        expect(reported, <bool>[true, false]);
      });

      testWidgets('a disabled tooltip never opens', (WidgetTester tester) async {
        await tester.pumpWidget(_tooltip(delay: Duration.zero, disabled: true));
        await _rest(tester);
        await tester.pumpAndSettle();

        expect(find.text('Copy'), findsNothing);
      });

      testWidgets('a long press is the touch screen way in', (WidgetTester tester) async {
        await tester.pumpWidget(_tooltip(delay: Duration.zero));

        await tester.longPress(find.text('Trigger'));
        await tester.pumpAndSettle();

        expect(find.text('Copy'), findsOneWidget);
      });
    });

    group('placement', () {
      testWidgets('sits above the trigger by default', (WidgetTester tester) async {
        await tester.pumpWidget(_tooltip(delay: Duration.zero));
        await _rest(tester);
        await tester.pumpAndSettle();

        expect(
          tester.getBottomLeft(find.text('Copy')).dy,
          lessThan(tester.getTopLeft(find.text('Trigger')).dy),
        );
      });

      testWidgets('and below it when it is asked to', (WidgetTester tester) async {
        await tester.pumpWidget(_tooltip(delay: Duration.zero, side: PlassSide.bottom));
        await _rest(tester);
        await tester.pumpAndSettle();

        expect(
          tester.getTopLeft(find.text('Copy')).dy,
          greaterThan(tester.getBottomLeft(find.text('Trigger')).dy),
        );
      });

      testWidgets('the wedge sits on the edge facing the trigger', (WidgetTester tester) async {
        await tester.pumpWidget(_tooltip(delay: Duration.zero, size: PlassSize.xl));
        await _rest(tester);
        await tester.pumpAndSettle();

        final wedge = tester.getRect(find.byType(CustomPaint).last);
        final plate = tester.getRect(find.text('Copy'));

        // Below the plate's text and above the trigger: in the gap, pointing
        // down at what the tooltip is about.
        expect(wedge.top, greaterThan(plate.bottom));
        expect(wedge.bottom, lessThanOrEqualTo(tester.getRect(find.text('Trigger')).top));
      });

      testWidgets('and is left out when it is turned off', (WidgetTester tester) async {
        await tester.pumpWidget(_tooltip(delay: Duration.zero));
        await _rest(tester);
        await tester.pumpAndSettle();
        final drawn = find.byType(CustomPaint).evaluate().length;

        // The same open tooltip, rebuilt without its wedge — the pointer is
        // already resting on it and stays there.
        await tester.pumpWidget(_tooltip(delay: Duration.zero, arrow: false));
        await tester.pumpAndSettle();

        // The plate paints itself either way; the wedge is the one that goes.
        expect(find.byType(CustomPaint).evaluate().length, drawn - 1);
      });

      testWidgets('flips to the other side when there is no room', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            Align(
              alignment: Alignment.topCenter,
              child: PlTooltip(
                content: const Text('Copy'),
                delay: Duration.zero,
                child: const SizedBox(width: 80, height: 32, child: Text('Trigger')),
              ),
            ),
            overlay: true,
          ),
        );
        await _rest(tester);
        await tester.pumpAndSettle();

        // Asked for the top, given the bottom: there is nothing above a trigger
        // pinned to the top edge.
        expect(
          tester.getTopLeft(find.text('Copy')).dy,
          greaterThan(tester.getBottomLeft(find.text('Trigger')).dy),
        );
      });
    });

    group('accessibility', () {
      testWidgets('the trigger carries what the plate says', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_tooltip());

        expect(tester.getSemantics(find.text('Trigger')), isSemantics(tooltip: 'Copy'));

        handle.dispose();
      });

      testWidgets('and takes a label when the plate is not plain text', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            Center(
              child: PlTooltip(
                content: const Row(mainAxisSize: MainAxisSize.min, children: <Widget>[Text('⌘C')]),
                semanticLabel: 'Copy, Command C',
                child: const SizedBox(width: 80, height: 32, child: Text('Trigger')),
              ),
            ),
            overlay: true,
          ),
        );

        expect(tester.getSemantics(find.text('Trigger')), isSemantics(tooltip: 'Copy, Command C'));

        handle.dispose();
      });
    });

    group('groups', () {
      testWidgets('a neighbour opens at once once one of them has', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlTooltipProvider(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  PlTooltip(
                    content: const Text('First'),
                    delay: const Duration(milliseconds: 600),
                    child: const SizedBox(width: 60, height: 32, child: Text('One')),
                  ),
                  PlTooltip(
                    content: const Text('Second'),
                    delay: const Duration(milliseconds: 600),
                    child: const SizedBox(width: 60, height: 32, child: Text('Two')),
                  ),
                ],
              ),
            ),
            overlay: true,
          ),
        );

        final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(pointer.removePointer);
        await pointer.addPointer(location: Offset.zero);

        await pointer.moveTo(tester.getCenter(find.text('One')));
        await tester.pump(const Duration(milliseconds: 700));
        await tester.pumpAndSettle();
        expect(find.text('First'), findsOneWidget);

        await pointer.moveTo(tester.getCenter(find.text('Two')));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.text('First'), findsNothing);
        expect(find.text('Second'), findsOneWidget);
      });
    });
  });
}
