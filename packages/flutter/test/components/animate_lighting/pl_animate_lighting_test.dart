import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// Whether the light is the even glow reduced motion draws.
bool even(WidgetTester tester) {
  final BoxDecoration light = lightOf(tester);

  return light.gradient == null && light.color != null;
}

/// How far round the arc has turned, in turns.
double turnOf(WidgetTester tester) {
  final SweepGradient arc = lightOf(tester).gradient! as SweepGradient;

  return (arc.transform! as GradientRotation).radians / (2 * math.pi);
}

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

      expect(stack.children.first, isA<PositionedDirectional>());
      // The content is the last child, in a backdrop group of its own.
      expect(
        find.descendant(of: find.byWidget(stack.children.last), matching: find.text('Live')),
        findsOneWidget,
      );
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

    group('paused when the setting is taken away', () {
      /// A light once round a second at an even pace, endless unless [repeat]
      /// says otherwise.
      Widget lighting({bool paused = false, bool still = false, int? repeat}) {
        return host(
          PlAnimateLighting(
            paused: paused,
            repeat: repeat,
            curve: Curves.linear,
            duration: const Duration(seconds: 1),
            child: const Text('Live'),
          ),
          width: 200,
          height: 80,
          disableAnimations: still,
        );
      }

      testWidgets('keeps the even glow until it is let go, paused from the mount', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(lighting(paused: true, still: true));
        await tester.pump(const Duration(milliseconds: 500));

        expect(even(tester), isTrue);

        await tester.pumpWidget(lighting(paused: true));

        // A pause holds what is on the screen. It used to draw the arc at
        // once, while it was still paused.
        expect(even(tester), isTrue);

        await tester.pump(const Duration(milliseconds: 500));

        expect(even(tester), isTrue);
        expect(tester.binding.hasScheduledFrame, isFalse);

        await tester.pumpWidget(lighting());

        expect(even(tester), isFalse);
        expect(turnOf(tester), closeTo(0, 0.001));

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        expect(turnOf(tester), closeTo(0.25, 0.001));
      });

      testWidgets('keeps the even glow until it is let go, paused after it landed', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(lighting(still: true));
        await tester.pump(const Duration(milliseconds: 1250));
        await tester.pumpWidget(lighting(paused: true, still: true));
        await tester.pump(const Duration(milliseconds: 500));

        expect(even(tester), isTrue);

        await tester.pumpWidget(lighting(paused: true));

        expect(even(tester), isTrue);

        await tester.pump(const Duration(milliseconds: 500));

        expect(even(tester), isTrue);
        expect(tester.binding.hasScheduledFrame, isFalse);

        await tester.pumpWidget(lighting());
        await tester.pump();

        // On from where its run stood when it landed, at the end of a delay of
        // nothing, which is where it began, as before.
        expect(even(tester), isFalse);
        expect(turnOf(tester), closeTo(0, 0.001));

        await tester.pump(const Duration(milliseconds: 250));

        expect(turnOf(tester), closeTo(0.25, 0.001));
      });

      testWidgets('keeps the even glow until it is let go, once a light that ends landed', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(lighting(repeat: 1, still: true));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpWidget(lighting(repeat: 1, paused: true, still: true));
        await tester.pumpWidget(lighting(repeat: 1, paused: true));

        // A pause holds what is on the screen, whether the light ends or not.
        // One that ends used to draw the arc at once, while it was still
        // paused.
        expect(even(tester), isTrue);

        await tester.pump(const Duration(milliseconds: 500));

        expect(even(tester), isTrue);
        expect(tester.binding.hasScheduledFrame, isFalse);

        await tester.pumpWidget(lighting(repeat: 1));
        await tester.pump();

        // Let go, it is the arc where its run ended, and it stays there, as a
        // light that ends does.
        expect(even(tester), isFalse);
        expect(turnOf(tester), closeTo(1, 0.001));
        expect(await redrawsIn(tester), isFalse);
      });
    });

    group('endless when the platform gives movement back', () {
      /// Once round a second at an even pace, after a delay of 300ms.
      Widget lighting({bool paused = false, bool still = false}) {
        return host(
          PlAnimateLighting(
            paused: paused,
            curve: Curves.linear,
            delay: const Duration(milliseconds: 300),
            duration: const Duration(seconds: 1),
            child: const Text('Live'),
          ),
          width: 200,
          height: 80,
          disableAnimations: still,
        );
      }

      /// Waits out the delay from the frame the light was let go on, and a
      /// quarter of a turn after it.
      Future<void> expectStartAfterDelay(WidgetTester tester) async {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 299));

        expect(turnOf(tester), closeTo(0, 0.001));

        await tester.pump(const Duration(milliseconds: 1));
        await tester.pump(const Duration(milliseconds: 250));

        expect(turnOf(tester), closeTo(0.25, 0.001));
      }

      testWidgets('starts the arc from the beginning, after its delay', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(lighting(still: true));
        await tester.pump(const Duration(milliseconds: 1250));
        await tester.pumpWidget(lighting());

        // Where the arc begins, as the React build starts a light the setting
        // switched off. It used to jump to where its passes would have got to
        // by now, most of the way round.
        expect(turnOf(tester), closeTo(0, 0.001));

        await expectStartAfterDelay(tester);
      });

      testWidgets('starts the arc from the beginning, after its delay, once a pause is let go', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(lighting());
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 250));

        expect(turnOf(tester), closeTo(0.25, 0.001));

        await tester.pumpWidget(lighting(still: true));
        await tester.pumpWidget(lighting(paused: true, still: true));
        await tester.pumpWidget(lighting(paused: true));
        await tester.pump(const Duration(milliseconds: 500));

        expect(even(tester), isTrue);

        await tester.pumpWidget(lighting());

        // It used to go on from where it stood when the setting arrived,
        // straight away.
        expect(turnOf(tester), closeTo(0, 0.001));

        await expectStartAfterDelay(tester);
      });
    });
  });
}
