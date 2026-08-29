import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

BoxDecoration lightOf(WidgetTester tester) {
  return tester
          .widget<DecoratedBox>(
            find.descendant(
              of: find.byType(PlAnimateLighting),
              matching: find.byType(DecoratedBox),
            ),
          )
          .decoration
      as BoxDecoration;
}

void main() {
  group('PlAnimateLighting', () {
    testWidgets('puts the light behind the content rather than over it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const PlAnimateLighting(child: Text('Live')), width: 200, height: 80),
      );

      final Stack stack = tester.widget<Stack>(
        find.descendant(of: find.byType(PlAnimateLighting), matching: find.byType(Stack)),
      );

      expect(stack.children.first, isA<Positioned>());
      expect(stack.children.last, isA<Text>());
      // The glow reaches past the content, so the stack must not clip.
      expect(stack.clipBehavior, Clip.none);
    });

    testWidgets('turns between the family two ends as it travels', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlAnimateLighting(color: PlassColor.success, child: Text('Live')),
          width: 200,
          height: 80,
        ),
      );

      final SweepGradient gradient = lightOf(tester).gradient! as SweepGradient;

      expect(gradient.colors[1], isNot(gradient.colors[2]));
    });

    testWidgets('takes one flat colour when a family is not what is wanted', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const PlAnimateLighting(glow: Color(0xFFFF9900), child: Text('Live')),
          width: 200,
          height: 80,
        ),
      );

      final SweepGradient gradient = lightOf(tester).gradient! as SweepGradient;

      expect(gradient.colors[1], const Color(0xFFFF9900));
      expect(gradient.colors[2], const Color(0xFFFF9900));
    });

    testWidgets('lights the arc it was asked for', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const PlAnimateLighting(arc: 90, child: Text('Live')), width: 200, height: 80),
      );

      final SweepGradient gradient = lightOf(tester).gradient! as SweepGradient;

      expect(gradient.stops![2], closeTo(0.25, 0.0001));
    });

    testWidgets('follows the radius it was given, plus the spread it reaches', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const PlAnimateLighting(size: PlassSize.xl, spread: 8, child: Text('Live')),
          width: 200,
          height: 80,
        ),
      );

      expect(
        lightOf(tester).borderRadius,
        BorderRadius.circular(PlassTokens.radius[PlassSize.xl]! + 8),
      );
    });

    testWidgets('becomes an even glow where the platform has asked for less movement', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const PlAnimateLighting(child: Text('Live')),
          width: 200,
          height: 80,
          disableAnimations: true,
        ),
      );

      final BoxDecoration light = lightOf(tester);

      expect(light.gradient, isNull);
      expect(light.color, isNotNull);
    });
  });
}
