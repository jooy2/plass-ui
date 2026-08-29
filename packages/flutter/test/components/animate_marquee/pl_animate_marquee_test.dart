import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

List<Widget> get _three => const <Widget>[
  SizedBox(width: 60, height: 20),
  SizedBox(width: 60, height: 20),
];

Offset shiftOf(WidgetTester tester) {
  final Transform moved = tester.widget<Transform>(
    find.descendant(of: find.byType(PlAnimateMarquee), matching: find.byType(Transform)),
  );

  return Offset(moved.transform.storage[12], moved.transform.storage[13]);
}

void main() {
  group('PlAnimateMarquee', () {
    testWidgets('lays the content down twice, which is what closes the seam', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(PlAnimateMarquee(children: _three), width: 200, height: 40));

      // The outer flex holds the copies; each copy is a flex of the children.
      expect(find.byType(Flex), findsNWidgets(3));
    });

    testWidgets('takes more copies for content short enough to leave a hole', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(PlAnimateMarquee(copies: 4, children: _three), width: 200, height: 40),
      );

      expect(find.byType(Flex), findsNWidgets(5));
    });

    testWidgets('never draws fewer than one', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(PlAnimateMarquee(copies: 0, children: _three), width: 200, height: 40),
      );

      expect(find.byType(Flex), findsNWidgets(2));
    });

    testWidgets('reads out the first copy only', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(PlAnimateMarquee(copies: 3, children: _three), width: 200, height: 40),
      );

      expect(
        find.descendant(of: find.byType(PlAnimateMarquee), matching: find.byType(ExcludeSemantics)),
        findsNWidgets(2),
      );
    });

    testWidgets('lays the strip out unbounded and clips it', (WidgetTester tester) async {
      await tester.pumpWidget(host(PlAnimateMarquee(children: _three), width: 200, height: 40));

      final UnconstrainedBox box = tester.widget<UnconstrainedBox>(
        find.descendant(of: find.byType(PlAnimateMarquee), matching: find.byType(UnconstrainedBox)),
      );

      // A clip alone would clip the paint and leave the flex asserting that it
      // overflowed; the strip is longer than its box on purpose.
      expect(box.constrainedAxis, Axis.vertical);
      expect(box.clipBehavior, Clip.hardEdge);
    });

    testWidgets('travels along the strip', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          PlAnimateMarquee(gap: 0, speed: 100, curve: Curves.linear, children: _three),
          width: 200,
          height: 40,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(shiftOf(tester).dx, lessThan(0));
      expect(shiftOf(tester).dy, 0);
    });

    testWidgets('travels down it when it runs vertically', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          PlAnimateMarquee(
            orientation: PlassOrientation.vertical,
            gap: 0,
            speed: 100,
            curve: Curves.linear,
            children: _three,
          ),
          width: 200,
          height: 40,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(shiftOf(tester).dy, lessThan(0));
      expect(shiftOf(tester).dx, 0);
    });

    testWidgets('travels at the speed it was given rather than in a time', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          PlAnimateMarquee(gap: 0, speed: 60, curve: Curves.linear, children: _three),
          width: 200,
          height: 40,
        ),
      );

      // The first frame is what measures the strip; the second is what starts
      // the ticker's clock against the duration that measurement decided.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final double before = shiftOf(tester).dx;

      await tester.pump(const Duration(milliseconds: 500));

      // Half a second at 60 logical pixels a second.
      expect(before - shiftOf(tester).dx, closeTo(30, 3));
    });

    testWidgets('stands where it started where the platform has asked for less movement', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(PlAnimateMarquee(children: _three), width: 200, height: 40, disableAnimations: true),
      );

      await tester.pump(const Duration(milliseconds: 600));

      expect(shiftOf(tester), Offset.zero);
    });
  });
}
