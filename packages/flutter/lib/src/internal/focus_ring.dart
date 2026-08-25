/// The focus ring.
///
/// An outline and not a border, in the CSS sense: it is drawn **outside** the
/// control's box, it takes no space, and it does not move anything on the page.
/// Flutter has no such primitive, so it is painted — a stroked rounded
/// rectangle a few pixels wider than the widget that owns it, on a
/// [CustomPaint] that is allowed to draw past its own bounds.
///
/// The offset also grows the radius, which is what CSS does and what stops the
/// ring from cutting the corners of the control it is around.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';

/// Paints a focus ring around a box of the painter's size.
class PlassFocusRingPainter extends CustomPainter {
  /// Creates a ring in [color] around a shape with [borderRadius].
  const PlassFocusRingPainter({required this.color, required this.borderRadius});

  /// The family's own ring colour.
  final Color color;

  /// The control's corner radius, which the ring follows.
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    // The stroke is centred on the path, so the path sits half a stroke outside
    // the offset — which puts the ring's *inner* edge exactly `offset` away
    // from the control, as `outline-offset` specifies.
    final spread = focusRingOffset + focusRingWidth / 2;
    final shape = (borderRadius + BorderRadius.circular(spread)).toRRect(
      (Offset.zero & size).inflate(spread),
    );

    canvas.drawRRect(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = focusRingWidth
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(PlassFocusRingPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.borderRadius != borderRadius;
  }
}
