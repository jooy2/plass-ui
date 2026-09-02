import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// Six cards wide enough that a 300px strip genuinely overflows.
List<Widget> _cards({int count = 6}) {
  return <Widget>[
    for (var index = 0; index < count; index += 1)
      SizedBox(width: 120, height: 60, child: Text('Card ${index + 1}')),
  ];
}

Widget _zone({
  List<Widget>? children,
  PlassOrientation orientation = PlassOrientation.horizontal,
  int lines = 1,
  PlScrollZoneButtons buttons = PlScrollZoneButtons.auto,
  PlScrollZoneButtonPlacement placement = PlScrollZoneButtonPlacement.overlay,
  PlScrollZoneMode mode = PlScrollZoneMode.item,
  int step = 1,
  bool snap = false,
  bool wheel = true,
  String? label,
  String previousLabel = 'Previous',
  String nextLabel = 'Next',
  ScrollController? controller,
}) {
  return host(
    PlScrollZone(
      orientation: orientation,
      lines: lines,
      spacing: 8,
      buttons: buttons,
      buttonPlacement: placement,
      mode: mode,
      step: step,
      snap: snap,
      wheel: wheel,
      label: label,
      previousLabel: previousLabel,
      nextLabel: nextLabel,
      controller: controller,
      children: children ?? _cards(),
    ),
    width: 300,
    height: 200,
  );
}

void main() {
  group('PlScrollZone', () {
    group('the strip', () {
      testWidgets('renders every child', (WidgetTester tester) async {
        await tester.pumpWidget(_zone());
        await tester.pumpAndSettle();

        expect(find.text('Card 1'), findsOneWidget);
        expect(find.text('Card 6'), findsOneWidget);
      });

      testWidgets('runs across the box and scrolls that way', (WidgetTester tester) async {
        await tester.pumpWidget(_zone());
        await tester.pumpAndSettle();

        expect(
          tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView)).scrollDirection,
          Axis.horizontal,
        );
      });

      testWidgets('runs down the box when it is asked to', (WidgetTester tester) async {
        await tester.pumpWidget(_zone(orientation: PlassOrientation.vertical));
        await tester.pumpAndSettle();

        expect(
          tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView)).scrollDirection,
          Axis.vertical,
        );
      });

      testWidgets('stacks the children into as many lines as it was given', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(_zone(lines: 2));
        await tester.pumpAndSettle();

        // Six children, two to a column: three columns, and the strip is half as
        // long as it would otherwise be.
        expect(
          tester.getTopLeft(find.text('Card 1')).dx,
          tester.getTopLeft(find.text('Card 2')).dx,
        );
        expect(
          tester.getTopLeft(find.text('Card 3')).dx,
          greaterThan(tester.getTopLeft(find.text('Card 1')).dx),
        );
      });

      testWidgets('names the scrollable region', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_zone(label: 'Categories'));
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Categories'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('draws no sheet of its own', (WidgetTester tester) async {
        await tester.pumpWidget(_zone(buttons: PlScrollZoneButtons.none));
        await tester.pumpAndSettle();

        // A shelf is a way of laying children out; the children arrive with
        // their own surfaces. With the buttons off there is nothing left to
        // paint at all.
        expect(
          decorationsOf(tester, find.byType(PlScrollZone)),
          everyElement(predicate<BoxDecoration>((BoxDecoration d) => d.color == null)),
        );
      });
    });

    group('the buttons', () {
      testWidgets('offers the one that has somewhere to go', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_zone());
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Next'), findsOneWidget);
        expect(find.bySemanticsLabel('Previous'), findsNothing);

        handle.dispose();
      });

      testWidgets('draws both from the first frame when it is told to', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_zone(buttons: PlScrollZoneButtons.always));
        await tester.pumpAndSettle();

        expect(
          tester.getSemantics(find.bySemanticsLabel('Previous')),
          isNot(matchesSemantics(hasEnabledState: true, isEnabled: true)),
        );
        expect(find.bySemanticsLabel('Next'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('draws none at all when it is told to', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_zone(buttons: PlScrollZoneButtons.none));
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Next'), findsNothing);
        expect(find.text('Card 1'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('draws neither while everything fits', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_zone(children: _cards(count: 1)));
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Next'), findsNothing);
        expect(find.bySemanticsLabel('Previous'), findsNothing);

        handle.dispose();
      });

      testWidgets('takes names of its own', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          _zone(buttons: PlScrollZoneButtons.always, previousLabel: 'Earlier', nextLabel: 'Later'),
        );
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Later'), findsOneWidget);
        expect(find.bySemanticsLabel('Earlier'), findsOneWidget);

        handle.dispose();
      });
    });

    group('pressing one', () {
      testWidgets('moves to the next child along', (WidgetTester tester) async {
        final controller = ScrollController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(_zone(controller: controller));
        await tester.pumpAndSettle();

        await tester.tap(find.bySemanticsLabel('Next'));
        await tester.pumpAndSettle();

        // 120px of card plus the 8px gutter, measured off the strip rather than
        // assumed from a size the caller never stated.
        expect(controller.offset, 128);
      });

      testWidgets('moves by more than one when it is asked to', (WidgetTester tester) async {
        final controller = ScrollController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(_zone(controller: controller, step: 2));
        await tester.pumpAndSettle();

        await tester.tap(find.bySemanticsLabel('Next'));
        await tester.pumpAndSettle();

        expect(controller.offset, 256);
      });

      testWidgets('moves by everything on screen in page mode', (WidgetTester tester) async {
        final controller = ScrollController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(_zone(controller: controller, mode: PlScrollZoneMode.page));
        await tester.pumpAndSettle();

        await tester.tap(find.bySemanticsLabel('Next'));
        await tester.pumpAndSettle();

        expect(controller.offset, 300);
      });

      testWidgets('comes back, and the back button appears with somewhere to go', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        final controller = ScrollController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(_zone(controller: controller));
        await tester.pumpAndSettle();

        await tester.tap(find.bySemanticsLabel('Next'));
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Previous'), findsOneWidget);

        await tester.tap(find.bySemanticsLabel('Previous'));
        await tester.pumpAndSettle();

        expect(controller.offset, 0);

        handle.dispose();
      });
    });

    group('where the buttons sit', () {
      testWidgets('puts them beside the strip by default', (WidgetTester tester) async {
        // Built without a `buttonPlacement` rather than through the helper,
        // which passes one: what is being tested is the default itself.
        await tester.pumpWidget(
          host(PlScrollZone(spacing: 8, children: _cards()), width: 300, height: 200),
        );
        await tester.pumpAndSettle();

        // The scroller stops where the button starts, so nothing is ever
        // half-hidden behind a control.
        expect(tester.getSize(find.byType(SingleChildScrollView)).width, lessThan(300));
      });

      testWidgets('overlays them when it is asked to, so the strip keeps its whole box', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(_zone());
        await tester.pumpAndSettle();

        expect(tester.getSize(find.byType(SingleChildScrollView)).width, 300);
      });

      testWidgets('keeps the lane of a button that has nowhere to go', (WidgetTester tester) async {
        await tester.pumpWidget(_zone(placement: PlScrollZoneButtonPlacement.inline));
        await tester.pumpAndSettle();

        final double withSpare = tester.getSize(find.byType(SingleChildScrollView)).width;

        await tester.pumpWidget(
          _zone(placement: PlScrollZoneButtonPlacement.inline, buttons: PlScrollZoneButtons.always),
        );
        await tester.pumpAndSettle();

        // A lane that came and went would resize the strip under the pointer
        // that had just reached the end of it.
        expect(tester.getSize(find.byType(SingleChildScrollView)).width, withSpare);
      });

      testWidgets('draws the button in that lane rather than reserving it empty', (
        WidgetTester tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_zone(placement: PlScrollZoneButtonPlacement.inline));
        await tester.pumpAndSettle();

        // The lane is paid for either way, so the only question is what stands
        // in it. An empty reserved lane reads as odd padding on one side of the
        // box; a disabled button reads as what it is. It is also what `always`
        // draws in the same position, so the two settings agree about how
        // "nowhere to go" looks.
        expect(
          tester.getSemantics(find.bySemanticsLabel('Previous')),
          isNot(matchesSemantics(hasEnabledState: true, isEnabled: true)),
        );
        expect(find.bySemanticsLabel('Next'), findsOneWidget);

        handle.dispose();
      });
    });

    group('the wheel', () {
      /// A mouse parked on the strip, and one turn of its wheel.
      Future<void> spin(WidgetTester tester, Offset delta, {Finder? on}) async {
        final pointer = TestPointer(1, PointerDeviceKind.mouse);

        pointer.hover(tester.getCenter(on ?? find.byType(SingleChildScrollView)));
        await tester.sendEventToBinding(pointer.scroll(delta));
        await tester.pump();
      }

      testWidgets('scrolls the strip along on a vertical wheel', (WidgetTester tester) async {
        final controller = ScrollController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(_zone(controller: controller));
        await tester.pumpAndSettle();

        // A horizontal `Scrollable` reads the horizontal half of a scroll and a
        // mouse wheel only ever produces the vertical one, so without this the
        // strip under the pointer would not move at all.
        await spin(tester, const Offset(0, 100));

        expect(controller.offset, 100);
      });

      testWidgets('leaves the wheel alone when it is turned off', (WidgetTester tester) async {
        final controller = ScrollController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(_zone(controller: controller, wheel: false));
        await tester.pumpAndSettle();

        await spin(tester, const Offset(0, 100));

        expect(controller.offset, 0);
      });

      testWidgets('hands the wheel back once the strip has reached its end', (
        WidgetTester tester,
      ) async {
        final inner = ScrollController();
        final outer = ScrollController();
        addTearDown(inner.dispose);
        addTearDown(outer.dispose);

        await tester.pumpWidget(
          host(
            SingleChildScrollView(
              controller: outer,
              child: Column(
                children: <Widget>[
                  PlScrollZone(
                    controller: inner,
                    spacing: 8,
                    buttons: PlScrollZoneButtons.none,
                    children: _cards(),
                  ),
                  const SizedBox(height: 600),
                ],
              ),
            ),
            width: 300,
            height: 200,
          ),
        );
        await tester.pumpAndSettle();

        await spin(tester, const Offset(0, 10000), on: find.byType(PlScrollZone));

        expect(inner.offset, inner.position.maxScrollExtent);
        expect(outer.offset, 0);

        await spin(tester, const Offset(0, 100), on: find.byType(PlScrollZone));

        // The strip has nothing left, so what is behind it takes the wheel. A
        // shelf that swallowed it at both ends would be a hole a reader scrolls
        // into.
        expect(outer.offset, 100);
        expect(inner.offset, inner.position.maxScrollExtent);
      });
    });

    group('snap', () {
      testWidgets('brings the nearest child to the leading edge', (WidgetTester tester) async {
        final controller = ScrollController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(_zone(controller: controller, snap: true));
        await tester.pumpAndSettle();

        await tester.drag(find.byType(SingleChildScrollView), const Offset(-100, 0));
        await tester.pumpAndSettle();

        // Whatever the drag left behind, the strip settles on a child's edge.
        expect(controller.offset % 128, moreOrLessEquals(0, epsilon: 0.5));
      });
    });
  });
}
