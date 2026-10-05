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

    testWidgets('stays where its run ended when a light that ends landed and is given null', (
      WidgetTester tester,
    ) async {
      Widget lighting({int? repeat, bool still = false}) {
        return host(
          PlAnimateLighting(
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

      await tester.pumpWidget(lighting(repeat: 1, still: true));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpWidget(lighting(still: true));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpWidget(lighting());
      await tester.pump();

      // The arc where its run ended, until it runs again, as the React build
      // takes the keyframe off a light that landed. It used to start again
      // from the beginning and go round.
      expect(even(tester), isFalse);
      expect(turnOf(tester), closeTo(1, 0.001));
      expect(await redrawsIn(tester), isFalse);
    });

    testWidgets('stays where a turn ends when an endless light is given a finite repeat under the '
        'setting', (WidgetTester tester) async {
      Widget lighting({int? repeat, bool still = false}) {
        return host(
          PlAnimateLighting(
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

      await tester.pumpWidget(lighting(still: true));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpWidget(lighting(repeat: 5, still: true));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpWidget(lighting(repeat: 5));
      await tester.pump();

      // The React build has a keyframe again for a light that ends, which
      // lands under the setting and is taken off once it goes, so the light
      // does not go on from its clock as an endless run given a count does.
      expect(even(tester), isFalse);
      expect(turnOf(tester), closeTo(1, 0.001));
      expect(await redrawsIn(tester), isFalse);
    });

    for (final int? after in <int?>[null, 8]) {
      testWidgets('stays where a turn ends, until it runs again, when an endless light given a '
          'finite repeat under the setting is given $after once it has gone', (
        WidgetTester tester,
      ) async {
        Widget lighting({int? repeat, bool still = false, bool play = true}) {
          return host(
            PlAnimateLighting(
              repeat: repeat,
              trigger: PlassAnimateTrigger.manual,
              play: play,
              curve: Curves.linear,
              duration: const Duration(seconds: 1),
              child: const Text('Live'),
            ),
            width: 200,
            height: 80,
            disableAnimations: still,
          );
        }

        await tester.pumpWidget(lighting(still: true));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpWidget(lighting(repeat: 5, still: true));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpWidget(lighting(repeat: 5));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpWidget(lighting(repeat: after));
        await tester.pump();

        // The React build keeps the light marked as landed, which takes its
        // keyframe off until it runs again. It used to turn on from where its
        // clock had got to, half a turn in.
        expect(even(tester), isFalse);
        expect(turnOf(tester), closeTo(1, 0.001));
        expect(await redrawsIn(tester), isFalse);

        await tester.pumpWidget(lighting(repeat: after, play: false));
        await tester.pumpWidget(lighting(repeat: after));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        // Run again, it turns from the beginning, and goes on past one turn.
        expect(turnOf(tester), closeTo(0.25, 0.001));

        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));

        expect(tester.binding.hasScheduledFrame, isTrue);
      });
    }

    group('endless, given a finite repeat while a pause held it under the setting', () {
      /// Once round a second at an even pace, after [delay].
      Widget lighting({required int delay, int? repeat, bool paused = false, bool still = false}) {
        return host(
          PlAnimateLighting(
            repeat: repeat,
            paused: paused,
            curve: Curves.linear,
            delay: Duration(milliseconds: delay),
            duration: const Duration(seconds: 1),
            child: const Text('Live'),
          ),
          width: 200,
          height: 80,
          disableAnimations: still,
        );
      }

      /// Lands the light endless, pauses it, gives it two turns and takes the
      /// setting away, and brings the setting back and takes it away again
      /// when [again] says so.
      Future<void> holdThrough(
        WidgetTester tester, {
        required int delay,
        bool again = false,
      }) async {
        await tester.pumpWidget(lighting(delay: delay, still: true));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpWidget(lighting(delay: delay, paused: true, still: true));
        await tester.pumpWidget(lighting(delay: delay, repeat: 2, paused: true, still: true));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpWidget(lighting(delay: delay, repeat: 2, paused: true));
        await tester.pump(const Duration(milliseconds: 500));

        if (again) {
          await tester.pumpWidget(lighting(delay: delay, repeat: 2, paused: true, still: true));
          await tester.pump(const Duration(milliseconds: 500));
          await tester.pumpWidget(lighting(delay: delay, repeat: 2, paused: true));
          await tester.pump(const Duration(milliseconds: 500));
        }

        // A pause holds the even glow reduced motion drew.
        expect(even(tester), isTrue);
        expect(await redrawsIn(tester), isFalse);
      }

      for (final (int delay, bool again) in <(int, bool)>[(0, false), (300, false), (300, true)]) {
        final String setting = again ? 'comes and goes again' : 'goes';

        testWidgets('plays it from the beginning, after a delay of ${delay}ms, once the pause is '
            'let go after the setting $setting', (WidgetTester tester) async {
          await holdThrough(tester, delay: delay, again: again);
          await tester.pumpWidget(lighting(delay: delay, repeat: 2));

          // The React build gives the light back a keyframe for the count, which
          // the pause holds before its run, so it plays once it is let go. It
          // used to stand where the count ends.
          expect(even(tester), isFalse);
          expect(turnOf(tester), closeTo(0, 0.001));

          await tester.pump();

          if (delay > 0) {
            await tester.pump(Duration(milliseconds: delay - 1));

            expect(turnOf(tester), closeTo(0, 0.001));

            await tester.pump(const Duration(milliseconds: 1));
          }

          await tester.pump(const Duration(milliseconds: 250));

          expect(turnOf(tester), closeTo(0.25, 0.001));

          // Two turns, and it stands where the second ends.
          await tester.pumpAndSettle();

          expect(turnOf(tester), closeTo(1, 0.001));
        });
      }

      testWidgets('stands where it ends once the pause is let go, when the setting comes back '
          'with no delay left and goes again', (WidgetTester tester) async {
        await holdThrough(tester, delay: 0, again: true);
        await tester.pumpWidget(lighting(delay: 0, repeat: 2));

        // The setting came back to a run standing where it begins and landed
        // it there, as it lands the keyframe in the React build, which had
        // reached the start of its run once the setting went.
        expect(even(tester), isFalse);
        expect(turnOf(tester), closeTo(1, 0.001));
        expect(await redrawsIn(tester), isFalse);
      });
    });

    group('endless, given a finite repeat under the setting with a delay', () {
      /// Once round a second at an even pace, after a delay of 300ms.
      Widget lighting({int? repeat, bool paused = false, bool still = false}) {
        return host(
          PlAnimateLighting(
            repeat: repeat,
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

      /// Lands the light endless and gives it two turns under the setting.
      Future<void> giveCount(WidgetTester tester) async {
        await tester.pumpWidget(lighting(still: true));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpWidget(lighting(repeat: 2, still: true));
      }

      /// Waits out [left] of the delay from the frame the light was let go on,
      /// and a quarter of a turn after it.
      Future<void> expectStartAfter(WidgetTester tester, Duration left) async {
        await tester.pump();
        await tester.pump(left - const Duration(milliseconds: 1));

        expect(turnOf(tester), closeTo(0, 0.001));

        await tester.pump(const Duration(milliseconds: 1));
        await tester.pump(const Duration(milliseconds: 250));

        expect(turnOf(tester), closeTo(0.25, 0.001));
      }

      testWidgets('plays it from the beginning after what is left of its delay, when the setting '
          'goes before the delay is over', (WidgetTester tester) async {
        await giveCount(tester);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpWidget(lighting(repeat: 2));

        // The keyframe the React build gives back for the count is still
        // waiting out its delay, counted from when the count was given, and
        // plays once it is over. It used to stand where the count ends.
        expect(even(tester), isFalse);
        expect(turnOf(tester), closeTo(0, 0.001));

        await expectStartAfter(tester, const Duration(milliseconds: 200));
      });

      testWidgets('counts the delay only while it is let go, when a pause holds it partway', (
        WidgetTester tester,
      ) async {
        await giveCount(tester);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpWidget(lighting(repeat: 2, paused: true, still: true));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpWidget(lighting(repeat: 2, paused: true));
        await tester.pump(const Duration(milliseconds: 500));

        expect(even(tester), isTrue);

        await tester.pumpWidget(lighting(repeat: 2));

        await expectStartAfter(tester, const Duration(milliseconds: 200));
      });

      testWidgets('measures a new delay from when the count was given', (
        WidgetTester tester,
      ) async {
        await giveCount(tester);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpWidget(
          host(
            const PlAnimateLighting(
              repeat: 2,
              curve: Curves.linear,
              delay: Duration(milliseconds: 500),
              duration: Duration(seconds: 1),
              child: Text('Live'),
            ),
            width: 200,
            height: 80,
            disableAnimations: true,
          ),
        );
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pumpWidget(
          host(
            const PlAnimateLighting(
              repeat: 2,
              curve: Curves.linear,
              delay: Duration(milliseconds: 500),
              duration: Duration(seconds: 1),
              child: Text('Live'),
            ),
            width: 200,
            height: 80,
          ),
        );

        // 500ms from when the count was given, 150ms ago.
        await expectStartAfter(tester, const Duration(milliseconds: 350));
      });

      testWidgets('stands where it ends when the setting goes once the delay is over', (
        WidgetTester tester,
      ) async {
        await giveCount(tester);
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpWidget(lighting(repeat: 2));
        await tester.pump();

        // The keyframe landed under the setting at the end of its delay.
        expect(even(tester), isFalse);
        expect(turnOf(tester), closeTo(1, 0.001));
        expect(await redrawsIn(tester), isFalse);
      });
    });
  });
}
