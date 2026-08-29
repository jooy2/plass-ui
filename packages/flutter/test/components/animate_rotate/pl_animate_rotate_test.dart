import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

Transform transformOf(WidgetTester tester) {
  return tester.widget<Transform>(
    find.descendant(of: find.byType(PlAnimateRotate), matching: find.byType(Transform)),
  );
}

/// The rotation the matrix is actually carrying, back in degrees.
double degreesOf(WidgetTester tester) {
  final Matrix4 m = transformOf(tester).transform;

  return math.atan2(m.storage[1], m.storage[0]) * 180 / math.pi;
}

void main() {
  group('PlAnimateRotate', () {
    testWidgets('starts half a turn out and lands square', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const PlAnimateRotate(duration: Duration(milliseconds: 200), child: Text('Turning'))),
      );

      // A half turn reads as 180° either way round; what matters is that it is
      // not yet where it will end up.
      expect(degreesOf(tester).abs(), closeTo(180, 0.001));

      await tester.pumpAndSettle();

      expect(degreesOf(tester), closeTo(0, 0.001));
    });

    testWidgets('takes both ends, which is what makes an endless spin the same widget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const PlAnimateRotate(
            from: 0,
            to: 90,
            duration: Duration(milliseconds: 200),
            fade: false,
            child: Text('Turning'),
          ),
        ),
      );

      expect(degreesOf(tester), closeTo(0, 0.001));

      await tester.pumpAndSettle();

      expect(degreesOf(tester), closeTo(90, 0.001));
    });

    testWidgets('counts in degrees, because the design language does', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const PlAnimateRotate(from: 45, fade: false, child: Text('Turning'))),
      );

      expect(degreesOf(tester), closeTo(45, 0.001));
    });

    testWidgets('turns about whichever point it was given', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const PlAnimateRotate(origin: Alignment.topLeft, child: Text('Turning'))),
      );

      expect(transformOf(tester).alignment, Alignment.topLeft);
    });

    testWidgets('draws no opacity layer at all for a continuous spin', (WidgetTester tester) async {
      await tester.pumpWidget(host(const PlAnimateRotate(fade: false, child: Text('Turning'))));

      expect(
        find.descendant(of: find.byType(PlAnimateRotate), matching: find.byType(Opacity)),
        findsNothing,
      );
    });

    testWidgets('turns out of place on the same curve run backwards', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlAnimateRotate(
            mode: PlassAnimateMode.exit,
            from: 90,
            fade: false,
            duration: Duration(milliseconds: 200),
            child: Text('Leaving'),
          ),
        ),
      );

      expect(degreesOf(tester), closeTo(0, 0.001));

      await tester.pumpAndSettle();

      expect(degreesOf(tester), closeTo(90, 0.001));
    });

    testWidgets('is simply there where the platform has asked for less movement', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const PlAnimateRotate(child: Text('Turning')), disableAnimations: true),
      );

      expect(degreesOf(tester), closeTo(0, 0.001));
    });
  });
}
