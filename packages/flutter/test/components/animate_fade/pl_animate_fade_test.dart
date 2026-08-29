import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// The opacity the fade is actually painting with.
double opacityOf(WidgetTester tester) {
  return tester
      .widget<Opacity>(
        find.descendant(of: find.byType(PlAnimateFade), matching: find.byType(Opacity)),
      )
      .opacity;
}

void main() {
  group('PlAnimateFade', () {
    testWidgets('holds its child at the start opacity on the first frame', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const PlAnimateFade(child: Text('Arriving'))));

      expect(opacityOf(tester), 0);
      expect(find.text('Arriving'), findsOneWidget);
    });

    testWidgets('arrives at full opacity once the run is over', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const PlAnimateFade(duration: Duration(milliseconds: 200), child: Text('Arriving'))),
      );

      await tester.pumpAndSettle();

      expect(opacityOf(tester), 1);
    });

    testWidgets('starts from whatever floor it was given', (WidgetTester tester) async {
      await tester.pumpWidget(host(const PlAnimateFade(from: 0.4, child: Text('Arriving'))));

      expect(opacityOf(tester), 0.4);
    });

    group('mode', () {
      testWidgets('exit runs the same curve backwards and is held there', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(
            const PlAnimateFade(
              mode: PlassAnimateMode.exit,
              duration: Duration(milliseconds: 200),
              child: Text('Leaving'),
            ),
          ),
        );

        expect(opacityOf(tester), 1);

        await tester.pumpAndSettle();

        expect(opacityOf(tester), 0);
      });
    });

    group('trigger', () {
      testWidgets('waits on its own first frame until a manual play', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlAnimateFade(
              trigger: PlassAnimateTrigger.manual,
              duration: Duration(milliseconds: 200),
              child: Text('Arriving'),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 400));

        expect(opacityOf(tester), 0);

        await tester.pumpWidget(
          host(
            const PlAnimateFade(
              trigger: PlassAnimateTrigger.manual,
              play: true,
              duration: Duration(milliseconds: 200),
              child: Text('Arriving'),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(opacityOf(tester), 1);
      });

      testWidgets('holds where it is while paused', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlAnimateFade(
              paused: true,
              duration: Duration(milliseconds: 200),
              child: Text('Arriving'),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 400));

        expect(opacityOf(tester), 0);
      });
    });

    testWidgets('waits out the delay before it starts', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlAnimateFade(
            delay: Duration(milliseconds: 300),
            duration: Duration(milliseconds: 100),
            child: Text('Arriving'),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 150));

      expect(opacityOf(tester), 0);

      await tester.pumpAndSettle(const Duration(milliseconds: 400));

      expect(opacityOf(tester), 1);
    });

    testWidgets('is simply there where the platform has asked for less movement', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const PlAnimateFade(child: Text('Arriving')), disableAnimations: true),
      );

      expect(opacityOf(tester), 1);
    });
  });
}
