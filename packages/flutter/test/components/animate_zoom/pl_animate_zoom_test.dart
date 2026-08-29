import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

Transform transformOf(WidgetTester tester) {
  return tester.widget<Transform>(
    find.descendant(of: find.byType(PlAnimateZoom), matching: find.byType(Transform)),
  );
}

/// The x scale, and not `getMaxScaleOnAxis()`: that one takes the maximum
/// across all three axes, and z is always 1.
double scaleOf(WidgetTester tester) => transformOf(tester).transform.storage[0];

void main() {
  group('PlAnimateZoom', () {
    testWidgets('travels more than twice as far as a grow does', (WidgetTester tester) async {
      await tester.pumpWidget(host(const PlAnimateZoom(child: Text('Landed'))));

      expect(scaleOf(tester), closeTo(0.4, 0.001));
    });

    testWidgets('arrives at its natural size once the run is over', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const PlAnimateZoom(duration: Duration(milliseconds: 200), child: Text('Landed'))),
      );

      await tester.pumpAndSettle();

      expect(scaleOf(tester), closeTo(1, 0.001));
    });

    testWidgets('is always about the centre', (WidgetTester tester) async {
      await tester.pumpWidget(host(const PlAnimateZoom(child: Text('Landed'))));

      expect(transformOf(tester).alignment, Alignment.center);
    });

    testWidgets('takes a scale above one, which arrives oversized and settles back', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const PlAnimateZoom(from: 1.4, child: Text('Landed'))));

      expect(scaleOf(tester), closeTo(1.4, 0.001));
    });

    testWidgets('draws no opacity layer at all when the fade is off', (WidgetTester tester) async {
      await tester.pumpWidget(host(const PlAnimateZoom(fade: false, child: Text('Landed'))));

      expect(
        find.descendant(of: find.byType(PlAnimateZoom), matching: find.byType(Opacity)),
        findsNothing,
      );
    });

    testWidgets('falls away on the same curve run backwards', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlAnimateZoom(
            mode: PlassAnimateMode.exit,
            duration: Duration(milliseconds: 200),
            child: Text('Leaving'),
          ),
        ),
      );

      expect(scaleOf(tester), closeTo(1, 0.001));

      await tester.pumpAndSettle();

      expect(scaleOf(tester), closeTo(0.4, 0.001));
    });

    testWidgets('is simply there where the platform has asked for less movement', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const PlAnimateZoom(child: Text('Landed')), disableAnimations: true),
      );

      expect(scaleOf(tester), closeTo(1, 0.001));
    });
  });
}
