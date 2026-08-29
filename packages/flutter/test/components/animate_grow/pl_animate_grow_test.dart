import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

Transform transformOf(WidgetTester tester) {
  return tester.widget<Transform>(
    find.descendant(of: find.byType(PlAnimateGrow), matching: find.byType(Transform)),
  );
}

/// The x scale, and not `getMaxScaleOnAxis()`: that one takes the maximum
/// across all three axes, and z is always 1.
double scaleOf(WidgetTester tester) => transformOf(tester).transform.storage[0];

void main() {
  group('PlAnimateGrow', () {
    testWidgets('holds its child at the start scale on the first frame', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const PlAnimateGrow(child: Text('Unfolding'))));

      expect(scaleOf(tester), closeTo(0.8, 0.001));
    });

    testWidgets('arrives at its natural size once the run is over', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const PlAnimateGrow(duration: Duration(milliseconds: 200), child: Text('Unfolding'))),
      );

      await tester.pumpAndSettle();

      expect(scaleOf(tester), closeTo(1, 0.001));
    });

    testWidgets('starts from whatever scale it was given, above one included', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const PlAnimateGrow(from: 1.3, child: Text('Unfolding'))));

      expect(scaleOf(tester), closeTo(1.3, 0.001));
    });

    group('origin', () {
      testWidgets('turns about the middle unless told otherwise', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAnimateGrow(child: Text('Unfolding'))));

        expect(transformOf(tester).alignment, Alignment.center);
      });

      testWidgets('anchors to whichever point it was given', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlAnimateGrow(origin: Alignment.topCenter, child: Text('Unfolding'))),
        );

        expect(transformOf(tester).alignment, Alignment.topCenter);
      });
    });

    group('fade', () {
      testWidgets('fades in with the growth by default', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAnimateGrow(child: Text('Unfolding'))));

        expect(
          tester
              .widget<Opacity>(
                find.descendant(of: find.byType(PlAnimateGrow), matching: find.byType(Opacity)),
              )
              .opacity,
          0,
        );
      });

      testWidgets('draws no opacity layer at all when the fade is off', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlAnimateGrow(fade: false, child: Text('Unfolding'))));

        expect(
          find.descendant(of: find.byType(PlAnimateGrow), matching: find.byType(Opacity)),
          findsNothing,
        );
      });
    });

    testWidgets('folds away on the same curve run backwards', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlAnimateGrow(
            mode: PlassAnimateMode.exit,
            duration: Duration(milliseconds: 200),
            child: Text('Folding'),
          ),
        ),
      );

      expect(scaleOf(tester), closeTo(1, 0.001));

      await tester.pumpAndSettle();

      expect(scaleOf(tester), closeTo(0.8, 0.001));
    });

    testWidgets('is simply there where the platform has asked for less movement', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const PlAnimateGrow(child: Text('Unfolding')), disableAnimations: true),
      );

      expect(scaleOf(tester), closeTo(1, 0.001));
    });
  });
}
