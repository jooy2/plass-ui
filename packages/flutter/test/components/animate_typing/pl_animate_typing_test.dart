import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// What is actually drawn: the rich text that is being typed, not the invisible
/// copy holding the box.
String visibleOf(WidgetTester tester) {
  final Text drawn = tester.widget<Text>(
    find.byWidgetPredicate((Widget candidate) => candidate is Text && candidate.textSpan != null),
  );

  return ((drawn.textSpan! as TextSpan).children!.first as TextSpan).text ?? '';
}

/// How many times the line was cleared in [seen], which is how many passes
/// began after the first one when it is not erased.
int clearsIn(List<String> seen) {
  int clears = 0;

  for (int index = 1; index < seen.length; index += 1) {
    if (seen[index].isEmpty && seen[index - 1].isNotEmpty) {
      clears += 1;
    }
  }

  return clears;
}

void main() {
  group('PlAnimateTyping', () {
    testWidgets('gives a screen reader the whole string once', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(const PlAnimateTyping('Deploying to production', caret: false), width: 400),
      );

      expect(
        tester.getSemantics(find.byType(PlAnimateTyping)).getSemanticsData().label,
        'Deploying to production',
      );

      handle.dispose();
    });

    testWidgets('types it out one grapheme at a time', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const PlAnimateTyping('Hello', speed: 100, caret: false), width: 400),
      );

      expect(visibleOf(tester), '');

      await tester.pump(const Duration(milliseconds: 25));

      // A prefix, and not the whole string: it is being revealed rather than
      // switched on.
      expect(visibleOf(tester), isNot(''));
      expect('Hello'.startsWith(visibleOf(tester)), isTrue);
      expect(visibleOf(tester).length, lessThan(5));

      await tester.pump(const Duration(milliseconds: 60));
      expect(visibleOf(tester), 'Hello');
    });

    testWidgets('counts graphemes rather than code points', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const PlAnimateTyping('ab👩‍👩‍👧', speed: 100, caret: false), width: 400),
      );

      // Three graphemes, not nine code points: the family arrives whole rather
      // than being assembled out of parts that mean nothing on their own.
      await tester.pump(const Duration(milliseconds: 35));

      expect(visibleOf(tester), 'ab👩‍👩‍👧');
    });

    testWidgets('holds the box the whole string will need from the first frame', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const PlAnimateTyping('Deploying to production', speed: 100), width: 400),
      );

      final Size empty = tester.getSize(find.byType(PlAnimateTyping));

      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.getSize(find.byType(PlAnimateTyping)), empty);
    });

    group('caret', () {
      testWidgets('draws a block after the text', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAnimateTyping('Hi'), width: 400));

        expect(find.text('|'), findsOneWidget);
      });

      testWidgets('takes whatever character it was given', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAnimateTyping('Hi', caretChar: '▌'), width: 400));

        expect(find.text('▌'), findsOneWidget);
      });

      testWidgets('grows with the reader\'s text size once, like the words beside it', (
        WidgetTester tester,
      ) async {
        Future<double> heightAt(double scale) async {
          await tester.pumpWidget(
            host(
              MediaQuery.withClampedTextScaling(
                minScaleFactor: scale,
                maxScaleFactor: scale,
                child: const PlAnimateTyping('Hi', trigger: PlassAnimateTrigger.manual),
              ),
              width: 400,
            ),
          );

          return tester.getRect(find.text('|')).height;
        }

        final double normal = await heightAt(1);

        expect(await heightAt(2), moreOrLessEquals(normal * 2, epsilon: 0.5));
      });

      testWidgets('can be turned off', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAnimateTyping('Hi', caret: false), width: 400));

        expect(find.text('|'), findsNothing);
      });
    });

    testWidgets('waits empty until it is played, rather than showing the whole line', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const PlAnimateTyping(
            'Hello',
            speed: 100,
            caret: false,
            trigger: PlassAnimateTrigger.manual,
          ),
          width: 400,
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      expect(visibleOf(tester), '');

      await tester.pumpWidget(
        host(
          const PlAnimateTyping(
            'Hello',
            speed: 100,
            caret: false,
            trigger: PlassAnimateTrigger.manual,
            play: true,
          ),
          width: 400,
        ),
      );

      await tester.pump(const Duration(milliseconds: 60));

      expect(visibleOf(tester), 'Hello');
    });

    testWidgets('waits empty again while it is off screen with once off', (
      WidgetTester tester,
    ) async {
      final ScrollController page = ScrollController();

      addTearDown(page.dispose);

      await tester.pumpWidget(
        host(
          SingleChildScrollView(
            controller: page,
            child: const Column(
              children: <Widget>[
                PlAnimateTyping(
                  'Hello',
                  speed: 100,
                  caret: false,
                  trigger: PlassAnimateTrigger.visible,
                  once: false,
                ),
                SizedBox(height: 2000),
              ],
            ),
          ),
          width: 320,
          height: 400,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(visibleOf(tester), 'Hello');

      page.jumpTo(1000);
      await tester.pump();
      await tester.pump();

      // Waiting to be seen again is an empty line, as it is before the first
      // run. Held where it was, it showed the line it had typed.
      expect(visibleOf(tester), '');

      page.jumpTo(0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 25));

      // A new run, from its first character.
      expect(visibleOf(tester).length, inInclusiveRange(1, 4));

      await tester.pump(const Duration(milliseconds: 100));

      expect(visibleOf(tester), 'Hello');
    });

    group('with play turned off and on', () {
      Widget typing({required bool play, bool paused = false}) {
        return host(
          PlAnimateTyping(
            'Hello',
            speed: 100,
            caret: false,
            trigger: PlassAnimateTrigger.manual,
            play: play,
            paused: paused,
          ),
          width: 400,
        );
      }

      testWidgets('waits empty again, and types from the first character', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(typing(play: true));
        await tester.pump(const Duration(milliseconds: 25));

        expect(visibleOf(tester).length, inInclusiveRange(1, 4));

        await tester.pumpWidget(typing(play: false));

        // Taken back by its trigger, it waits as it did before it was first
        // played. Held where it was, it showed the part it had typed.
        expect(visibleOf(tester), '');

        await tester.pump(const Duration(milliseconds: 200));

        expect(visibleOf(tester), '');

        await tester.pumpWidget(typing(play: true));
        await tester.pump(const Duration(milliseconds: 25));

        expect(visibleOf(tester).length, inInclusiveRange(1, 4));

        await tester.pump(const Duration(milliseconds: 100));

        expect(visibleOf(tester), 'Hello');
      });

      testWidgets('holds the line where it is while it is paused', (WidgetTester tester) async {
        await tester.pumpWidget(typing(play: true));
        await tester.pump(const Duration(milliseconds: 25));

        final String typed = visibleOf(tester);

        expect(typed.length, inInclusiveRange(1, 4));

        await tester.pumpWidget(typing(play: true, paused: true));
        await tester.pump(const Duration(milliseconds: 200));

        // A pause is the caller holding it, and it holds the frame it is on.
        expect(visibleOf(tester), typed);

        await tester.pumpWidget(typing(play: true));
        await tester.pump(const Duration(milliseconds: 100));

        expect(visibleOf(tester), 'Hello');
      });
    });

    testWidgets('waits empty again when the pointer leaves one that never stops', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const PlAnimateTyping(
            'Hello',
            speed: 100,
            caret: false,
            repeat: null,
            trigger: PlassAnimateTrigger.hover,
          ),
          width: 400,
        ),
      );

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

      addTearDown(mouse.removePointer);

      await mouse.addPointer(location: Offset.zero);
      await tester.pump();
      await mouse.moveTo(tester.getCenter(find.byType(PlAnimateTyping)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 25));

      expect(visibleOf(tester).length, inInclusiveRange(1, 4));

      await mouse.moveTo(Offset.zero);
      await tester.pump();

      // An endless one stops when the pointer leaves, and waits as it did
      // before the pointer first arrived. Held where it was, it showed the part
      // it had typed.
      expect(visibleOf(tester), '');
    });

    testWidgets('holds the line through a new run while it is paused, and types that run from its '
        'first character once it is let go', (WidgetTester tester) async {
      Widget typing({required bool paused}) {
        return host(
          PlAnimateTyping(
            'Hello',
            speed: 10,
            caret: false,
            trigger: PlassAnimateTrigger.hover,
            paused: paused,
          ),
          width: 400,
        );
      }

      await tester.pumpWidget(typing(paused: false));

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      final Offset over = tester.getCenter(find.byType(PlAnimateTyping));

      addTearDown(mouse.removePointer);

      await mouse.addPointer(location: Offset.zero);
      await tester.pump();
      await mouse.moveTo(over);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(visibleOf(tester), 'Hel');

      await tester.pumpWidget(typing(paused: true));

      // Out and back in, which is a new run, and the pause holds it.
      await mouse.moveTo(Offset.zero);
      await tester.pump();
      await mouse.moveTo(over);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // A pause holds what is on the screen, whichever run it is holding. It
      // used to empty the line for a run that had not begun.
      expect(visibleOf(tester), 'Hel');

      await tester.pumpWidget(typing(paused: false));
      await tester.pump(const Duration(milliseconds: 50));

      // The new run, from its first character, rather than the old line typed
      // on from where it was held.
      expect(visibleOf(tester), 'H');

      await tester.pump(const Duration(milliseconds: 500));

      expect(visibleOf(tester), 'Hello');
    });

    testWidgets('deletes the line again before repeating, one grapheme at a time', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const PlAnimateTyping(
            'Hello',
            speed: 100,
            eraseSpeed: 100,
            hold: Duration(milliseconds: 100),
            erase: true,
            repeat: 2,
            caret: false,
          ),
          width: 400,
        ),
      );

      final List<String> seen = <String>[];

      for (int frame = 0; frame < 40; frame += 1) {
        await tester.pump(const Duration(milliseconds: 10));
        seen.add(visibleOf(tester));
      }

      // Without `erase` the only strings after the full one would be 'Hello'
      // and ''. With it there is a frame on every prefix, on the way back down.
      final int full = seen.indexOf('Hello');
      final List<String> after = seen.sublist(full);

      expect(full, greaterThanOrEqualTo(0));
      expect(after, contains('Hell'));
      expect(after, contains('H'));
      expect(after, contains(''));
    });

    group('paused and let go', () {
      /// Two passes of "Hello", typed in 40ms and held for 100ms in between.
      Widget typing({required bool paused}) {
        return host(
          PlAnimateTyping(
            'Hello',
            speed: 100,
            hold: const Duration(milliseconds: 100),
            repeat: 2,
            paused: paused,
            caret: false,
          ),
          width: 400,
        );
      }

      /// Pumps [frames] frames of 10ms and records what each one drew.
      Future<void> watch(WidgetTester tester, List<String> seen, int frames) async {
        for (int frame = 0; frame < frames; frame += 1) {
          await tester.pump(const Duration(milliseconds: 10));
          seen.add(visibleOf(tester));
        }
      }

      testWidgets('during the hold between two passes, holds and goes on to the next', (
        WidgetTester tester,
      ) async {
        final List<String> seen = <String>[];

        await tester.pumpWidget(typing(paused: false));
        await watch(tester, seen, 8);

        // Typed out, and holding before the second pass.
        expect(visibleOf(tester), 'Hello');

        await tester.pumpWidget(typing(paused: true));
        await watch(tester, seen, 20);
        await tester.pumpWidget(typing(paused: false));
        // Longer than the hold and a whole pass.
        await watch(tester, seen, 40);

        // The second pass was counted before the hold, so the typewriter came
        // back to a pass that was already over and never played it.
        expect(clearsIn(seen), 1);
        expect(visibleOf(tester), 'Hello');
      });

      testWidgets('during the last pass, finishes it and plays no other', (
        WidgetTester tester,
      ) async {
        final List<String> seen = <String>[];

        await tester.pumpWidget(typing(paused: false));
        await watch(tester, seen, 16);

        // Partway through the second pass, which is the last one.
        expect(clearsIn(seen), 1);
        expect(visibleOf(tester).length, inInclusiveRange(1, 4));

        await tester.pumpWidget(typing(paused: true));
        await watch(tester, seen, 20);
        await tester.pumpWidget(typing(paused: false));
        // Longer than the hold and a whole pass, so a third would have started.
        await watch(tester, seen, 40);

        expect(clearsIn(seen), 1);
        expect(visibleOf(tester), 'Hello');
      });
    });

    testWidgets(
      'paused and let go during the hold between two passes, holds for what was left of it',
      (WidgetTester tester) async {
        Widget typing({required bool paused}) {
          return host(
            PlAnimateTyping(
              'Hi',
              speed: 10,
              hold: const Duration(milliseconds: 1000),
              repeat: 2,
              paused: paused,
              caret: false,
            ),
            width: 400,
          );
        }

        await tester.pumpWidget(typing(paused: false));
        await tester.pump(const Duration(milliseconds: 10));
        await tester.pump(const Duration(milliseconds: 100));

        expect(visibleOf(tester), 'Hi');

        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpWidget(typing(paused: true));
        await tester.pump(const Duration(milliseconds: 2000));
        await tester.pumpWidget(typing(paused: false));
        await tester.pump(const Duration(milliseconds: 500));

        expect(visibleOf(tester), 'Hi');

        await tester.pump(const Duration(milliseconds: 150));

        // About 600ms of the hold was left, and the line is cleared for the next
        // pass. Held for the whole of it again, it would still be holding here.
        expect(visibleOf(tester), '');
      },
    );

    group('paused and let go while it erases', () {
      Widget erasing({
        required String text,
        required bool paused,
        required double eraseSpeed,
        required Duration hold,
      }) {
        return host(
          PlAnimateTyping(
            text,
            speed: 10,
            eraseSpeed: eraseSpeed,
            hold: hold,
            erase: true,
            repeat: 2,
            paused: paused,
            caret: false,
          ),
          width: 400,
        );
      }

      testWidgets('during the hold before it deletes, holds for what was left of it', (
        WidgetTester tester,
      ) async {
        Widget typing({required bool paused}) {
          return erasing(
            text: 'Hi',
            paused: paused,
            eraseSpeed: 10,
            hold: const Duration(milliseconds: 1000),
          );
        }

        await tester.pumpWidget(typing(paused: false));
        // The two characters arrive 100ms apart, and the hold starts with the
        // second.
        await tester.pump(const Duration(milliseconds: 10));
        await tester.pump(const Duration(milliseconds: 100));

        expect(visibleOf(tester), 'Hi');

        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpWidget(typing(paused: true));
        await tester.pump(const Duration(milliseconds: 2000));
        await tester.pumpWidget(typing(paused: false));
        await tester.pump(const Duration(milliseconds: 500));

        // About 600ms of the hold was left. Let go, it used to delete at once.
        expect(visibleOf(tester), 'Hi');

        await tester.pump(const Duration(milliseconds: 150));

        // Held for the whole of it again, it would still be holding here.
        expect(visibleOf(tester), 'H');
      });

      testWidgets('partway through deleting, waits the delete delay', (WidgetTester tester) async {
        Widget typing({required bool paused}) {
          // Typed at 100ms a character and deleted at 500ms a character.
          return erasing(text: 'Hello', paused: paused, eraseSpeed: 2, hold: Duration.zero);
        }

        await tester.pumpWidget(typing(paused: false));
        await tester.pump(const Duration(milliseconds: 10));
        await tester.pump(const Duration(milliseconds: 500));

        // Typed out at 400ms, and the first character deleted at once.
        expect(visibleOf(tester), 'Hell');

        await tester.pumpWidget(typing(paused: true));
        await tester.pump(const Duration(milliseconds: 1000));
        await tester.pumpWidget(typing(paused: false));
        await tester.pump(const Duration(milliseconds: 200));

        // Waiting the typing delay instead, it deleted the next one by now.
        expect(visibleOf(tester), 'Hell');

        await tester.pump(const Duration(milliseconds: 350));

        expect(visibleOf(tester), 'Hel');
      });
    });

    group('paused and let go during a wait', () {
      /// Pauses it now, holds it for a long while, and lets it go again.
      Future<void> pauseAndLetGo(
        WidgetTester tester,
        Widget Function({required bool paused}) typing,
      ) async {
        await tester.pumpWidget(typing(paused: true));
        await tester.pump(const Duration(milliseconds: 5000));
        await tester.pumpWidget(typing(paused: false));
      }

      testWidgets('waits out only what was left of the delay', (WidgetTester tester) async {
        Widget typing({required bool paused}) {
          return host(
            PlAnimateTyping(
              'Hi',
              speed: 10,
              delay: const Duration(milliseconds: 1000),
              paused: paused,
              caret: false,
            ),
            width: 400,
          );
        }

        await tester.pumpWidget(typing(paused: false));
        await tester.pump(const Duration(milliseconds: 600));
        await pauseAndLetGo(tester, typing);
        await tester.pump(const Duration(milliseconds: 399));

        // 400ms of the wait was left. It used to wait a character's time.
        expect(visibleOf(tester), '');

        await tester.pump(const Duration(milliseconds: 1));

        expect(visibleOf(tester), 'H');
      });

      testWidgets('waits out only what was left of the wait for the next character', (
        WidgetTester tester,
      ) async {
        Widget typing({required bool paused}) {
          return host(PlAnimateTyping('Hi', speed: 1, paused: paused, caret: false), width: 400);
        }

        await tester.pumpWidget(typing(paused: false));
        // The first character on this frame, and the next a second after it.
        await tester.pump(Duration.zero);

        expect(visibleOf(tester), 'H');

        await tester.pump(const Duration(milliseconds: 400));
        await pauseAndLetGo(tester, typing);
        await tester.pump(const Duration(milliseconds: 599));

        expect(visibleOf(tester), 'H');

        await tester.pump(const Duration(milliseconds: 1));

        // 600ms of the wait was left. It used to wait the whole second again.
        expect(visibleOf(tester), 'Hi');
      });

      for (final bool erase in <bool>[true, false]) {
        testWidgets(
          'waits out only what was left of the wait after a pass it ${erase ? 'erased' : 'cleared'}',
          (WidgetTester tester) async {
            // Typed a character a second after a 3s delay and held for 100ms,
            // and an erased line is deleted at 10ms a character, so the line is
            // gone at 4,110ms when it is erased and at 4,100ms when it is
            // cleared. The next pass types its first character a second after
            // that.
            Widget typing({required bool paused}) {
              return host(
                PlAnimateTyping(
                  'Hi',
                  speed: 1,
                  eraseSpeed: 100,
                  delay: const Duration(milliseconds: 3000),
                  hold: const Duration(milliseconds: 100),
                  erase: erase,
                  repeat: 2,
                  paused: paused,
                  caret: false,
                ),
                width: 400,
              );
            }

            await tester.pumpWidget(typing(paused: false));
            await tester.pump(Duration(milliseconds: erase ? 4110 : 4100));

            expect(visibleOf(tester), '');

            await tester.pump(const Duration(milliseconds: 400));
            await pauseAndLetGo(tester, typing);
            await tester.pump(const Duration(milliseconds: 599));

            // 600ms of the wait was left. It used to wait a whole character's
            // time again.
            expect(visibleOf(tester), '');

            await tester.pump(const Duration(milliseconds: 1));

            expect(visibleOf(tester), 'H');
          },
        );
      }
    });

    testWidgets('is simply there where the platform has asked for less movement', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const PlAnimateTyping('Hello', caret: false), width: 400, disableAnimations: true),
      );

      expect(visibleOf(tester), 'Hello');
    });

    testWidgets('leaves the tree with its caret where the platform has asked for less movement', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const PlAnimateTyping('Hello'), width: 400, disableAnimations: true),
      );

      // Unmounted with the default caret, which does not blink here. Letting it
      // go must not be the first thing that builds its blink.
      await tester.pumpWidget(host(const SizedBox(), width: 400, disableAnimations: true));

      expect(tester.takeException(), isNull);
    });
  });
}
