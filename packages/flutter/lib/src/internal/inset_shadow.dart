/// The one CSS shadow Flutter has no box for.
///
/// `BoxShadow` only casts outward. Plass uses two shadows that fall *inside* a
/// shape — the hairline of light along the top edge of a glass sheet, and the
/// well a filled field is cut into — and both of them are load-bearing: without
/// the first, a glass surface loses the cut edge that says it is a pane rather
/// than a translucent rectangle.
///
/// Reproduced exactly rather than approximated. An inset shadow is the shape
/// filled with the colour, minus the same shape moved by the offset and shrunk
/// by the spread, clipped back to the shape. With a zero blur and a 1px
/// downward offset that leaves precisely the sliver along the top inner edge
/// that CSS draws, corner curves and all.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// An inset shadow, as a [CustomPainter].
///
/// Painted between the surface and its content, which is where a CSS inset
/// shadow sits in the painting order.
@immutable
class PlassInsetShadow {
  /// Creates an inset shadow. [blur] is a CSS `blur-radius`.
  const PlassInsetShadow({
    required this.color,
    this.offset = Offset.zero,
    this.blur = 0,
    this.spread = 0,
  });

  /// The shadow's colour, alpha included.
  final Color color;

  /// How far the shadow is displaced, in logical pixels.
  final Offset offset;

  /// The CSS `blur-radius`, in logical pixels. `0` gives a hard edge.
  final double blur;

  /// How far the shadow's shape is shrunk before it is subtracted.
  final double spread;

  @override
  bool operator ==(Object other) {
    return other is PlassInsetShadow &&
        other.color == color &&
        other.offset == offset &&
        other.blur == blur &&
        other.spread == spread;
  }

  @override
  int get hashCode => Object.hash(color, offset, blur, spread);
}

/// Paints [shadows] inside [borderRadius].
class PlassInsetShadowPainter extends CustomPainter {
  /// Creates a painter for a stack of inset shadows.
  const PlassInsetShadowPainter({required this.shadows, required this.borderRadius});

  /// Painted in order, first one underneath.
  final List<PlassInsetShadow> shadows;

  /// The shape they are clipped to — the surface's own corner radius.
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    if (shadows.isEmpty) {
      return;
    }

    final shape = borderRadius.toRRect(Offset.zero & size);

    canvas.save();
    canvas.clipRRect(shape);

    for (final shadow in shadows) {
      // A `MaskFilter` takes the standard deviation directly, which is what
      // CSS's blur-radius is twice of. No conversion table needed here — that
      // is `cssBlur`'s job, and it exists because `BoxShadow` does *not* take a
      // sigma.
      final sigma = shadow.blur / 2;
      final hole = shape.shift(shadow.offset).deflate(shadow.spread);

      // Wide enough that the ring is never cut short by its own bounds: the
      // clip above is what gives it its outer edge.
      final margin = size.longestSide + shadow.blur * 3 + shadow.spread.abs() + 16;
      final outer = Path()..addRect(shape.outerRect.inflate(margin));
      final ring = Path.combine(PathOperation.difference, outer, Path()..addRRect(hole));

      final paint = Paint()..color = shadow.color;

      if (sigma > 0) {
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);
      }

      canvas.drawPath(ring, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(PlassInsetShadowPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius || !listEquals(oldDelegate.shadows, shadows);
  }
}
