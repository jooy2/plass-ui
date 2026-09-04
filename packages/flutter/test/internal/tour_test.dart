import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/src/internal/tour.dart';
import 'package:plass_ui/src/types.dart';

const Size view = Size(1000, 800);

void main() {
  group('inflate', () {
    test('grows a rectangle on every side', () {
      expect(
        inflate(const Rect.fromLTWH(200, 100, 50, 20), 6),
        const Rect.fromLTWH(194, 94, 62, 32),
      );
    });

    test('never shrinks past nothing', () {
      // A negative padding on a hairline target would otherwise ask for a
      // rectangle with a negative width, which draws inside out.
      expect(inflate(const Rect.fromLTWH(0, 0, 4, 4), -10).width, 0);
    });
  });

  group('spotlightPath', () {
    test('covers the whole screen when there is nothing to cut out', () {
      // A welcome step: the screen dims and nothing is spotlit.
      final path = spotlightPath(view, null, 10);

      expect(path.contains(const Offset(500, 400)), isTrue);
      expect(path.getBounds(), Offset.zero & view);
    });

    test('leaves the light out of the shape entirely', () {
      final path = spotlightPath(view, const Rect.fromLTWH(100, 100, 200, 80), 8);

      // Inside the hole is outside the scrim, which is what makes the control
      // under it reachable: a clipped-away region is not hit tested.
      expect(path.contains(const Offset(200, 140)), isFalse);
      expect(path.contains(const Offset(50, 50)), isTrue);
    });

    test('rounds the corners of the hole', () {
      final path = spotlightPath(view, const Rect.fromLTWH(100, 100, 200, 80), 20);

      // The very corner of the rectangle is still scrim, because the hole is
      // rounded away from it.
      expect(path.contains(const Offset(101, 101)), isTrue);
      expect(path.contains(const Offset(200, 140)), isFalse);
    });

    test('cuts nothing out of a target with no area', () {
      final path = spotlightPath(view, const Rect.fromLTWH(10, 10, 0, 40), 8);

      expect(path.contains(const Offset(500, 400)), isTrue);
    });
  });

  group('cardOffset', () {
    const Size card = Size(300, 120);
    const Rect middle = Rect.fromLTWH(400, 300, 200, 60);

    Offset place({
      Rect spot = middle,
      PlassSide side = PlassSide.bottom,
      PlassAlign align = PlassAlign.center,
    }) {
      return cardOffset(
        view: view,
        spot: spot,
        card: card,
        side: side,
        align: align,
        gap: 10,
        margin: 12,
      );
    }

    test('puts the card under the light, centred on it', () {
      expect(place(), const Offset(350, 370));
    });

    test('lines it up with either end of the light', () {
      expect(place(align: PlassAlign.start).dx, 400);
      expect(place(align: PlassAlign.end).dx, 300);
    });

    test('stands it off the other three sides', () {
      expect(place(side: PlassSide.top).dy, 170);
      expect(place(side: PlassSide.left).dx, 90);
      expect(place(side: PlassSide.right).dx, 610);
    });

    test('flips to the opposite side when the one asked for has no room', () {
      // The light is at the top of the screen, so a card above it would be off.
      final Offset at = place(spot: const Rect.fromLTWH(400, 20, 200, 60), side: PlassSide.top);

      expect(at.dy, 90);
    });

    test('stays where it was asked when neither side has room', () {
      // A light taller than the screen: flipping buys nothing, so the side that
      // was asked for is the one that is honoured.
      final Offset at = place(spot: const Rect.fromLTWH(400, -50, 200, 900), side: PlassSide.top);

      expect(at.dy, lessThan(0));
    });

    test('keeps the card on screen along the edge it is on', () {
      // Lined up with a light in the corner, the card would run off the side.
      final Offset at = place(spot: const Rect.fromLTWH(940, 300, 40, 60), align: PlassAlign.start);

      expect(at.dx, 1000 - 300 - 12);
    });

    test('centres a card wider than the screen rather than pushing it off', () {
      final Offset at = cardOffset(
        view: const Size(200, 800),
        spot: middle,
        card: card,
        side: PlassSide.bottom,
        align: PlassAlign.center,
        gap: 10,
        margin: 12,
      );

      expect(at.dx, 12);
    });
  });
}
