import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

double opacityOf(WidgetTester tester) {
  return tester
      .widget<Opacity>(
        find.descendant(of: find.byType(PlAnimateBlink), matching: find.byType(Opacity)),
      )
      .opacity;
}

void main() {
  group('PlAnimateBlink', () {
    testWidgets('starts full, so a run that ends leaves the widget as it found it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const PlAnimateBlink(child: Text('Recording'))));

      expect(opacityOf(tester), 1);
    });

    testWidgets('is at its floor halfway through the cycle', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlAnimateBlink(
            min: 0.25,
            repeat: 1,
            curve: Curves.linear,
            duration: Duration(milliseconds: 400),
            child: Text('Recording'),
          ),
        ),
      );

      // The first pump is what starts the ticker's clock; the second is what
      // moves it.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(opacityOf(tester), closeTo(0.25, 0.01));
    });

    testWidgets('comes back to full where the count runs out', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlAnimateBlink(
            repeat: 1,
            duration: Duration(milliseconds: 200),
            child: Text('Recording'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(opacityOf(tester), 1);
    });

    testWidgets('holds where it is when paused', (WidgetTester tester) async {
      await tester.pumpWidget(host(const PlAnimateBlink(paused: true, child: Text('Recording'))));

      await tester.pump(const Duration(milliseconds: 600));

      expect(opacityOf(tester), 1);
    });

    testWidgets('is simply there where the platform has asked for less movement', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const PlAnimateBlink(min: 0.2, child: Text('Recording')), disableAnimations: true),
      );

      expect(opacityOf(tester), 1);
    });
  });
}
