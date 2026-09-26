import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui/src/internal/surface.dart';

import '../../support/host.dart';

double opacityOf(WidgetTester tester) {
  return tester
      .widget<PlassFiltered>(
        find.descendant(of: find.byType(PlAnimateBlink), matching: find.byType(PlassFiltered)),
      )
      .opacity;
}

void main() {
  group('PlAnimateBlink', () {
    testWidgets('adds no opacity layer once a finite run has ended', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlAnimateBlink(
            repeat: 2,
            duration: Duration(milliseconds: 200),
            child: Text('Recording'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Built at its last frame for as long as it is on screen, so an opacity
      // of 1 kept as a layer would be a layer for nothing.
      expect(tester.layers.whereType<OpacityLayer>(), isEmpty);
      expect(opacityOf(tester), 1);
    });

    testWidgets('adds no opacity layer while it waits for its trigger', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const PlAnimateBlink(trigger: PlassAnimateTrigger.manual, child: Text('Recording'))),
      );

      expect(tester.layers.whereType<OpacityLayer>(), isEmpty);
      expect(opacityOf(tester), 1);
    });

    testWidgets('is left out of the semantics at a floor of 0, as it was', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          const PlAnimateBlink(
            repeat: 1,
            curve: Curves.linear,
            duration: Duration(milliseconds: 400),
            child: Text('Recording'),
          ),
        ),
      );

      expect(semanticsLabels(tester), contains('Recording'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(opacityOf(tester), 0);
      expect(semanticsLabels(tester), isNot(contains('Recording')));

      await tester.pumpAndSettle();

      expect(semanticsLabels(tester), contains('Recording'));

      handle.dispose();
    });
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
