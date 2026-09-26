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

/// An open popup 600 wide, twice as wide as the room anywhere round a 100-wide
/// anchor put at [at] on an 800-wide screen, asked to keep to its room or not.
Future<({Rect anchor, Rect popup})> placeWide(
  WidgetTester tester, {
  required AlignmentGeometry at,
  required PlassSide side,
  PlassAlign align = PlassAlign.start,
  TextDirection direction = TextDirection.ltr,
  bool fitWidth = true,
}) async {
  await tester.pumpWidget(
    host(
      Align(
        alignment: at,
        child: PlassAnchoredPortal(
          open: true,
          side: side,
          align: align,
          offset: 8,
          fitWidth: fitWidth,
          popup: const SizedBox(key: popupKey, width: 600, height: 40),
          child: const SizedBox(key: anchorKey, width: 100, height: 40),
        ),
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

    group('held to its room', () {
      testWidgets('runs a popup below to the edge the line runs towards', (
        WidgetTester tester,
      ) async {
        // At the end of the line, so the room is the anchor's own width and
        // the popup hangs from its start.
        final ltr = await placeWide(
          tester,
          at: AlignmentDirectional.topEnd,
          side: PlassSide.bottom,
        );

        expect(ltr.popup.left, ltr.anchor.left);
        expect(ltr.popup.right, 800);

        final rtl = await placeWide(
          tester,
          at: AlignmentDirectional.topEnd,
          side: PlassSide.bottom,
          direction: TextDirection.rtl,
        );

        expect(rtl.popup.right, rtl.anchor.right);
        expect(rtl.popup.left, 0);
      });

      testWidgets('and from the end of the anchor back to the start of the line', (
        WidgetTester tester,
      ) async {
        for (final TextDirection direction in TextDirection.values) {
          final placed = await placeWide(
            tester,
            at: AlignmentDirectional.topStart,
            side: PlassSide.top,
            align: PlassAlign.end,
            direction: direction,
          );

          expect(placed.popup.width, placed.anchor.width, reason: '$direction');
        }
      });

      testWidgets('centres a popup in twice the room to the nearer edge', (
        WidgetTester tester,
      ) async {
        final placed = await placeWide(
          tester,
          at: const Alignment(-0.5, 1),
          side: PlassSide.top,
          align: PlassAlign.center,
        );

        expect(placed.popup.center.dx, placed.anchor.center.dx);
        expect(placed.popup.left, 0);
      });

      testWidgets('keeps a popup beside the anchor off the edge on its side', (
        WidgetTester tester,
      ) async {
        // In the middle, where neither side has 600, so neither is flipped to.
        final right = await placeWide(tester, at: Alignment.center, side: PlassSide.right);

        expect(right.popup.left, right.anchor.right + 8);
        expect(right.popup.right, 800);

        final left = await placeWide(tester, at: Alignment.center, side: PlassSide.left);

        expect(left.popup.right, left.anchor.left - 8);
        expect(left.popup.left, 0);
      });

      testWidgets('measures the room on the side it flipped to', (WidgetTester tester) async {
        // Against the right edge, with 700 on the left: the popup goes there
        // and keeps its own width.
        final placed = await placeWide(tester, at: Alignment.centerRight, side: PlassSide.right);

        expect(placed.popup.right, placed.anchor.left - 8);
        expect(placed.popup.width, 600);
      });

      testWidgets('leaves a popup that does not ask at its own width', (WidgetTester tester) async {
        final placed = await placeWide(
          tester,
          at: AlignmentDirectional.topEnd,
          side: PlassSide.bottom,
          fitWidth: false,
        );

        expect(placed.popup.width, 600);
      });
    });
  });
}
