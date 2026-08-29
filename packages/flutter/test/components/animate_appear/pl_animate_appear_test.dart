import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// How far each child is still to travel, in order.
List<Offset> offsetsOf(WidgetTester tester) {
  return tester
      .widgetList<Transform>(
        find.descendant(of: find.byType(PlAnimateAppear), matching: find.byType(Transform)),
      )
      .map((Transform moved) => Offset(moved.transform.storage[12], moved.transform.storage[13]))
      .toList();
}

List<Widget> get _three => const <Widget>[Text('One'), Text('Two'), Text('Three')];

void main() {
  group('PlAnimateAppear', () {
    testWidgets('drifts every child up from below over a short distance', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(PlAnimateAppear(children: _three)));

      expect(offsetsOf(tester), <Offset>[
        const Offset(0, 12),
        const Offset(0, 12),
        const Offset(0, 12),
      ]);
    });

    group('stagger', () {
      testWidgets('holds each child back by its own position', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlAnimateAppear(
              stagger: const Duration(milliseconds: 100),
              duration: const Duration(milliseconds: 100),
              curve: Curves.linear,
              children: _three,
            ),
          ),
        );

        // 150ms in: the first child has landed and the third has not been let
        // go at all, which is the whole claim the stagger makes.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));

        final List<Offset> offsets = offsetsOf(tester);

        expect(offsets[0].dy, 0);
        expect(offsets[2].dy, 12);
        expect(offsets[0].dy, lessThan(offsets[1].dy));
        expect(offsets[1].dy, lessThanOrEqualTo(offsets[2].dy));
      });

      testWidgets('runs the list backwards when asked', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            PlAnimateAppear(
              reverse: true,
              stagger: const Duration(milliseconds: 100),
              duration: const Duration(milliseconds: 100),
              curve: Curves.linear,
              children: _three,
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));

        final List<Offset> offsets = offsetsOf(tester);

        expect(offsets[2].dy, 0);
        expect(offsets[0].dy, 12);
      });

      testWidgets('counts children rather than leaves, so a group is one step', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const PlAnimateAppear(
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[Text('One'), Text('Two')],
                ),
                Text('Three'),
              ],
            ),
          ),
        );

        expect(offsetsOf(tester), hasLength(2));
      });
    });

    testWidgets('travels the other way when it comes from the left', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(PlAnimateAppear(from: PlassSide.left, distance: 20, children: _three)),
      );

      expect(offsetsOf(tester).first, const Offset(-20, 0));
    });

    testWidgets('lands everything where it belongs once the run is over', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          PlAnimateAppear(
            stagger: const Duration(milliseconds: 40),
            duration: const Duration(milliseconds: 100),
            children: _three,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(offsetsOf(tester), everyElement(Offset.zero));
    });

    testWidgets('draws no opacity layers at all when the fade is off', (WidgetTester tester) async {
      await tester.pumpWidget(host(PlAnimateAppear(fade: false, children: _three)));

      expect(
        find.descendant(of: find.byType(PlAnimateAppear), matching: find.byType(Opacity)),
        findsNothing,
      );
    });

    testWidgets('runs down the list by default and across when asked', (WidgetTester tester) async {
      await tester.pumpWidget(host(PlAnimateAppear(children: _three)));

      expect(tester.widget<Flex>(find.byType(Flex)).direction, Axis.vertical);

      await tester.pumpWidget(
        host(PlAnimateAppear(orientation: PlassOrientation.horizontal, children: _three)),
      );

      expect(tester.widget<Flex>(find.byType(Flex)).direction, Axis.horizontal);
    });

    testWidgets('is simply there where the platform has asked for less movement', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(PlAnimateAppear(children: _three), disableAnimations: true));

      expect(offsetsOf(tester), everyElement(Offset.zero));
    });
  });
}
