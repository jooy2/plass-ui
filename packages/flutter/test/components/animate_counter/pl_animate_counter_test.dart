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
