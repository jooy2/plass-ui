import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../support/host.dart';

/// The opacity the fade under test is painting with.
double opacityOf(WidgetTester tester) {
  return tester
      .widget<Opacity>(
        find.descendant(of: find.byType(PlAnimateFade), matching: find.byType(Opacity)),
      )
      .opacity;
}

void main() {
  group('the hover trigger', () {
    testWidgets('adds no stop to the tab order around content that takes no focus', (
      WidgetTester tester,
    ) async {
      final FocusNode before = FocusNode();
      final FocusNode after = FocusNode();

      addTearDown(before.dispose);
      addTearDown(after.dispose);

      await tester.pumpWidget(
        host(
          afterFocusStop(
            before,
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const PlAnimateFade(
                  trigger: PlassAnimateTrigger.hover,
                  child: SizedBox.square(dimension: 40),
                ),
                Focus(focusNode: after, child: const SizedBox.square(dimension: 1)),
              ],
            ),
          ),
        ),
      );

      before.requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // A picture with a hover effect is still a picture. One Tab goes past it.
      expect(after.hasPrimaryFocus, isTrue);
    });

    testWidgets('puts no focusable node on the semantics tree', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          const PlAnimateFade(
            trigger: PlassAnimateTrigger.hover,
            child: SizedBox.square(dimension: 40),
          ),
        ),
      );

      // A focusable node with nothing inside to name it is read out as an
      // unlabelled stop.
      expect(find.semantics.byFlag(SemanticsFlag.isFocusable), findsNothing);

      handle.dispose();
    });

    testWidgets('starts when the focus lands on something inside it', (WidgetTester tester) async {
      final FocusNode inside = FocusNode();

      addTearDown(inside.dispose);

      await tester.pumpWidget(
        host(
          PlAnimateFade(
            trigger: PlassAnimateTrigger.hover,
            duration: const Duration(milliseconds: 200),
            child: Focus(focusNode: inside, child: const SizedBox.square(dimension: 40)),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 400));

      expect(opacityOf(tester), 0);

      inside.requestFocus();
      await tester.pumpAndSettle();

      expect(opacityOf(tester), 1);
    });

    testWidgets('still starts under a mouse', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const PlAnimateFade(
            trigger: PlassAnimateTrigger.hover,
            duration: Duration(milliseconds: 200),
            child: SizedBox.square(dimension: 40),
          ),
        ),
      );

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

      addTearDown(mouse.removePointer);

      await mouse.addPointer(location: Offset.zero);
      await tester.pump();

      expect(opacityOf(tester), 0);

      await mouse.moveTo(tester.getCenter(find.byType(PlAnimateFade)));
      await tester.pumpAndSettle();

      expect(opacityOf(tester), 1);
    });
  });
}
