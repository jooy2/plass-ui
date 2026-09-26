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

/// Six 100 by 20 boxes in a row, which wrap onto more rows the narrower the
/// popup is held.
const Widget wrapping = Wrap(
  key: popupKey,
  children: <Widget>[
    SizedBox(width: 100, height: 20),
    SizedBox(width: 100, height: 20),
    SizedBox(width: 100, height: 20),
    SizedBox(width: 100, height: 20),
    SizedBox(width: 100, height: 20),
    SizedBox(width: 100, height: 20),
  ],
);

/// A window of [size] with [child] in it: the view the tree is drawn into, and
/// the `MediaQuery` that says how big it is, as a real window's does.
Widget window(WidgetTester tester, Size size, Widget child) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;

  return Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: MediaQueryData(size: size),
      child: Overlay.wrap(child: child),
    ),
  );
}

/// Where the anchor and the popup are once [size] has been laid out and every
/// measure it set off has run.
Future<({Rect anchor, Rect popup})> resize(WidgetTester tester, Size size, Widget child) async {
  await tester.pumpWidget(window(tester, size, child));
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

    group('placed again', () {
      testWidgets('flips a popup that the window has left no room for on its side', (
        WidgetTester tester,
      ) async {
        addTearDown(tester.view.reset);

        Widget anchored({required bool open}) {
          return Padding(
            padding: const EdgeInsets.only(top: 300),
            child: Align(
              alignment: Alignment.topCenter,
              child: PlassAnchoredPortal(
                open: open,
                side: PlassSide.bottom,
                offset: 0,
                popup: const SizedBox(key: popupKey, width: 200, height: 80),
                child: const SizedBox(key: anchorKey, width: 100, height: 40),
              ),
            ),
          );
        }

        final Widget tree = anchored(open: true);

        // Closed at first, so the popup starts watching the window as it opens
        // rather than as it is built.
        await tester.pumpWidget(window(tester, const Size(800, 600), anchored(open: false)));

        final tall = await resize(tester, const Size(800, 600), tree);

        expect(tall.popup.top, tall.anchor.bottom);

        // 40 below the anchor, where the popup needs 80.
        final short = await resize(tester, const Size(800, 380), tree);

        expect(short.popup.bottom, short.anchor.top);

        final again = await resize(tester, const Size(800, 600), tree);

        expect(again.popup.top, again.anchor.bottom);
      });

      testWidgets('holds a popup to the room the window has left it', (WidgetTester tester) async {
        addTearDown(tester.view.reset);

        const Widget tree = Padding(
          padding: EdgeInsets.only(left: 100),
          child: Align(
            alignment: Alignment.topLeft,
            child: PlassAnchoredPortal(
              open: true,
              side: PlassSide.bottom,
              align: PlassAlign.start,
              offset: 8,
              fitWidth: true,
              popup: SizedBox(key: popupKey, width: 600, height: 40),
              child: SizedBox(key: anchorKey, width: 100, height: 40),
            ),
          ),
        );

        final wide = await resize(tester, const Size(800, 600), tree);

        expect(wide.popup.width, 600);

        final narrow = await resize(tester, const Size(500, 600), tree);

        expect(narrow.popup.left, narrow.anchor.left);
        expect(narrow.popup.right, 500);

        final again = await resize(tester, const Size(800, 600), tree);

        expect(again.popup.width, 600);
      });

      testWidgets('turns a popup beside the anchor to the side the window has made room on', (
        WidgetTester tester,
      ) async {
        addTearDown(tester.view.reset);

        // 300 from the right edge, so the popup held to that side stays 292
        // wide however wide the window grows. It has to move to be any wider.
        const Widget tree = Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 300),
            child: PlassAnchoredPortal(
              open: true,
              side: PlassSide.right,
              align: PlassAlign.start,
              offset: 8,
              fitWidth: true,
              popup: SizedBox(key: popupKey, width: 600, height: 40),
              child: SizedBox(key: anchorKey, width: 100, height: 40),
            ),
          ),
        );

        // Room for 600 on neither side, so it stays on the one asked for.
        final cramped = await resize(tester, const Size(800, 600), tree);

        expect(cramped.popup.left, cramped.anchor.right + 8);
        expect(cramped.popup.width, 292);

        final roomy = await resize(tester, const Size(1200, 600), tree);

        expect(roomy.popup.right, roomy.anchor.left - 8);
        expect(roomy.popup.width, 600);
      });

      testWidgets('flips a popup that its room has made too tall for its side', (
        WidgetTester tester,
      ) async {
        addTearDown(tester.view.reset);

        // 30 below the anchor: room for one row, and 200 across it, which
        // wraps the popup onto three.
        final placed = await resize(
          tester,
          const Size(800, 600),
          const Padding(
            padding: EdgeInsets.only(left: 600, top: 530),
            child: Align(
              alignment: Alignment.topLeft,
              child: PlassAnchoredPortal(
                open: true,
                side: PlassSide.bottom,
                align: PlassAlign.start,
                offset: 0,
                fitWidth: true,
                popup: wrapping,
                child: SizedBox(key: anchorKey, width: 100, height: 40),
              ),
            ),
          ),
        );

        expect(placed.popup.size, const Size(200, 60));
        expect(placed.popup.bottom, placed.anchor.top);
      });

      testWidgets('flips a popup that the anchor\'s width has made too tall for its side', (
        WidgetTester tester,
      ) async {
        addTearDown(tester.view.reset);

        // 110 below the anchor: room for five rows, and the anchor's 100
        // across, which wraps the popup onto six.
        final placed = await resize(
          tester,
          const Size(800, 600),
          const Padding(
            padding: EdgeInsets.only(top: 450),
            child: Align(
              alignment: Alignment.topCenter,
              child: PlassAnchoredPortal(
                open: true,
                side: PlassSide.bottom,
                offset: 0,
                anchorWidth: PlassAnchorWidth.exact,
                popup: wrapping,
                child: SizedBox(key: anchorKey, width: 100, height: 40),
              ),
            ),
          ),
        );

        expect(placed.popup.size, const Size(100, 120));
        expect(placed.popup.bottom, placed.anchor.top);
      });
    });
  });
}
