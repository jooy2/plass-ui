import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// What a sighted reader sees right now.
String _drawn(WidgetTester tester) {
  return tester.widget<Text>(find.byType(Text)).data!;
}

Future<void> _pump(WidgetTester tester, Widget child, {bool disableAnimations = false}) async {
  await tester.pumpWidget(
    host(child, width: 240, height: 120, disableAnimations: disableAnimations),
  );
  await tester.pump();
}

void main() {
  group('PlAnimateCounter', () {
    testWidgets('sits on the number it counts from until it is started', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const PlAnimateCounter(value: 4812, trigger: PlassAnimateTrigger.manual));

      // Not started is the first frame, exactly as it is for every other effect
      // here.
      expect(_drawn(tester), '0');
    });

    testWidgets('starts from where it was told', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlAnimateCounter(from: 4000, value: 4812, trigger: PlassAnimateTrigger.manual),
      );

      expect(_drawn(tester), '4000');
    });

    testWidgets('lands on the number it was given', (WidgetTester tester) async {
      await _pump(
        tester,
        const PlAnimateCounter(
          value: 4812,
          trigger: PlassAnimateTrigger.manual,
          play: true,
          duration: Duration(milliseconds: 100),
        ),
      );

      await tester.pumpAndSettle();

      expect(_drawn(tester), '4812');
    });

    testWidgets('writes the figure the way it was told to', (WidgetTester tester) async {
      await _pump(
        tester,
        PlAnimateCounter(
          value: 48120,
          trigger: PlassAnimateTrigger.manual,
          play: true,
          duration: const Duration(milliseconds: 100),
          formatValue: (double value) => '£${value.round()}',
        ),
      );

      await tester.pumpAndSettle();

      expect(_drawn(tester), '£48120');
    });

    testWidgets('waits out only what is left of its delay when it is let go', (
      WidgetTester tester,
    ) async {
      Widget waiting({required bool paused}) {
        return PlAnimateCounter(
          value: 100,
          trigger: PlassAnimateTrigger.manual,
          play: true,
          delay: const Duration(milliseconds: 400),
          duration: const Duration(milliseconds: 200),
          curve: Curves.linear,
          paused: paused,
        );
      }

      await _pump(tester, waiting(paused: false));
      await tester.pump(const Duration(milliseconds: 200));

      // Half of the wait has gone by, so what is held is the wait itself.
      expect(_drawn(tester), '0');

      await _pump(tester, waiting(paused: true));
      await tester.pump(const Duration(milliseconds: 500));

      expect(_drawn(tester), '0');

      await _pump(tester, waiting(paused: false));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // 200ms of the wait was left, so the count is only now beginning. Letting
      // go of the rest of the wait instead would have it halfway up by here.
      expect(_drawn(tester), '0');

      await tester.pump(const Duration(milliseconds: 100));

      expect(_drawn(tester), '50');

      await tester.pumpAndSettle();

      expect(_drawn(tester), '100');
    });

    group('a new value', () {
      Widget counter(double value) {
        return PlAnimateCounter(
          value: value,
          trigger: PlassAnimateTrigger.mount,
          duration: const Duration(milliseconds: 200),
          curve: Curves.linear,
        );
      }

      testWidgets('counts on from the figure the last count landed on', (
        WidgetTester tester,
      ) async {
        await _pump(tester, counter(100));
        await tester.pumpAndSettle();

        expect(_drawn(tester), '100');

        await tester.pumpWidget(host(counter(200), width: 240, height: 120));

        // The frame the value arrives in, before its run has begun. Handed the
        // last run's progress, it drew the new value and then dropped back.
        expect(_drawn(tester), '100');

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Halfway, from 100 to 200, rather than from 0.
        expect(_drawn(tester), '150');

        await tester.pumpAndSettle();

        expect(_drawn(tester), '200');
      });

      testWidgets('counts on from the frame a running count had got to', (
        WidgetTester tester,
      ) async {
        await _pump(tester, counter(100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(_drawn(tester), '50');

        await tester.pumpWidget(host(counter(300), width: 240, height: 120));

        expect(_drawn(tester), '50');

        await tester.pump();

        expect(_drawn(tester), '50');

        await tester.pump(const Duration(milliseconds: 100));

        // Halfway, over the whole duration, from 50 to 300.
        expect(_drawn(tester), '175');

        await tester.pumpAndSettle();

        expect(_drawn(tester), '300');
      });

      testWidgets('leaves a replay to count from where it was told', (WidgetTester tester) async {
        Widget played(double value, {required bool play}) {
          return PlAnimateCounter(
            value: value,
            trigger: PlassAnimateTrigger.manual,
            play: play,
            duration: const Duration(milliseconds: 200),
            curve: Curves.linear,
          );
        }

        await _pump(tester, played(100, play: true));
        await tester.pumpAndSettle();
        await _pump(tester, played(200, play: true));
        await tester.pumpAndSettle();

        expect(_drawn(tester), '200');

        await _pump(tester, played(200, play: false));
        await _pump(tester, played(200, play: true));
        await tester.pump(const Duration(milliseconds: 100));

        // A new `play` is the first count again, from `from`, rather than the
        // last one, from 100.
        expect(_drawn(tester), '100');

        await tester.pumpAndSettle();

        expect(_drawn(tester), '200');
      });
    });

    testWidgets('shows the number it counts from while it is off screen with once off', (
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
                PlAnimateCounter(
                  value: 500,
                  from: 7,
                  once: false,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.linear,
                ),
                SizedBox(height: 2000),
              ],
            ),
          ),
          width: 240,
          height: 400,
        ),
      );
      await tester.pumpAndSettle();

      expect(_drawn(tester), '500');

      page.jumpTo(1000);
      await tester.pump();
      await tester.pump();

      // Waiting to be seen again is the first frame, as it is before the first
      // count. Held where it was, it showed the answer.
      expect(_drawn(tester), '7');

      page.jumpTo(0);
      await tester.pump();

      // The first frame back on screen. Held where it was, it drew the answer
      // here and dropped back to 7 on the next.
      expect(_drawn(tester), '7');

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(_drawn(tester), '254');

      await tester.pumpAndSettle();

      expect(_drawn(tester), '500');
    });

    testWidgets('is simply the number where the platform asked for less motion', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const PlAnimateCounter(value: 4812, trigger: PlassAnimateTrigger.manual),
        disableAnimations: true,
      );

      expect(_drawn(tester), '4812');
    });

    testWidgets('tells a screen reader the answer rather than the count', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await _pump(tester, const PlAnimateCounter(value: 4812, trigger: PlassAnimateTrigger.manual));

      // A number changing sixty times a second in the semantics tree is either
      // silence or sixty announcements, and neither is the figure.
      expect(find.bySemanticsLabel('4812'), findsOneWidget);
      expect(_drawn(tester), '0');

      handle.dispose();
    });
  });
}
