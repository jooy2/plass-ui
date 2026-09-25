import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/src/internal/anchored.dart';
import 'package:plass_ui/src/types.dart';

import '../support/host.dart';

const Key anchorKey = Key('anchor');
const Key popupKey = Key('popup');

/// An open popup twice as wide and tall as its anchor, in the middle of the
/// screen, where every side has room for it.
Future<({Rect anchor, Rect popup})> place(
  WidgetTester tester, {
  required PlassSide side,
  required PlassAlign align,
  required TextDirection direction,
}) async {
  await tester.pumpWidget(
    host(
      PlassAnchoredPortal(
        open: true,
        side: side,
        align: align,
        offset: 0,
        popup: const SizedBox(key: popupKey, width: 200, height: 80),
        child: const SizedBox(key: anchorKey, width: 100, height: 40),
      ),
      overlay: true,
      textDirection: direction,
    ),
  );
  await tester.pumpAndSettle();

  return (
    anchor: tester.getRect(find.byKey(anchorKey)),
    popup: tester.getRect(find.byKey(popupKey)),
  );
}

void main() {
  group('PlassAnchoredPortal', () {
    group('above and below the anchor', () {
      for (final PlassSide side in <PlassSide>[PlassSide.top, PlassSide.bottom]) {
        testWidgets('hangs a $side popup from the start of the line in either direction', (
          WidgetTester tester,
        ) async {
          final ltr = await place(
            tester,
            side: side,
            align: PlassAlign.start,
            direction: TextDirection.ltr,
          );

          expect(ltr.popup.left, ltr.anchor.left);

          // The start is the reader's, which is the right under RTL, as it is
          // for everything else `PlassAlign` places.
          final rtl = await place(
            tester,
            side: side,
            align: PlassAlign.start,
            direction: TextDirection.rtl,
          );

          expect(rtl.popup.right, rtl.anchor.right);
        });

        testWidgets('and a $side popup from the end of it', (WidgetTester tester) async {
          final ltr = await place(
            tester,
            side: side,
            align: PlassAlign.end,
            direction: TextDirection.ltr,
          );

          expect(ltr.popup.right, ltr.anchor.right);

          final rtl = await place(
            tester,
            side: side,
            align: PlassAlign.end,
            direction: TextDirection.rtl,
          );

          expect(rtl.popup.left, rtl.anchor.left);
        });

        testWidgets('centres a $side popup the same way in both', (WidgetTester tester) async {
          for (final TextDirection direction in TextDirection.values) {
            final placed = await place(
              tester,
              side: side,
              align: PlassAlign.center,
              direction: direction,
            );

            expect(placed.popup.center.dx, placed.anchor.center.dx, reason: '$direction');
          }
        });
      }
    });

    group('beside the anchor', () {
      testWidgets('hangs a popup from the top at the start and the bottom at the end', (
        WidgetTester tester,
      ) async {
        // A side edge runs down the screen, and down is down in every writing
        // direction.
        for (final TextDirection direction in TextDirection.values) {
          for (final PlassSide side in <PlassSide>[PlassSide.left, PlassSide.right]) {
            final start = await place(
              tester,
              side: side,
              align: PlassAlign.start,
              direction: direction,
            );

            expect(start.popup.top, start.anchor.top, reason: '$side, $direction');

            final end = await place(
              tester,
              side: side,
              align: PlassAlign.end,
              direction: direction,
            );

            expect(end.popup.bottom, end.anchor.bottom, reason: '$side, $direction');
          }
        }
      });
    });
  });
}
