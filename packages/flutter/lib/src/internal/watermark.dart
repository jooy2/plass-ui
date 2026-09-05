/// A mark laid over a picture.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Where a watermark sits on the picture.
enum PlImageWatermarkPlacement {
  /// One mark, in the top leading corner.
  topStart,

  /// One mark, in the top trailing corner.
  topEnd,

  /// One mark, in the bottom leading corner.
  bottomStart,

  /// One mark, in the bottom trailing corner.
  bottomEnd,

  /// Repeated across the whole picture.
  tile,
}

/// A mark laid over a picture: what it says, where it goes, and how it looks.
@immutable
class PlImageWatermark {
  /// Creates a watermark.
  const PlImageWatermark(
    this.text, {
    this.placement = PlImageWatermarkPlacement.bottomEnd,
    this.opacity,
    this.angle = -24,
    this.color = const Color(0xFFFFFFFF),
    this.fontSize,
  });

  /// What it says.
  final String text;

  /// One in a corner, or [PlImageWatermarkPlacement.tile] for the whole picture.
  final PlImageWatermarkPlacement placement;

  /// How far through it the picture shows. Defaults to 0.55 in a corner and
  /// 0.14 tiled, because a mark that covers everything has to be fainter than
  /// one that covers a corner.
  final double? opacity;

  /// The turn a tiled mark is set at, in degrees.
  final double angle;

  /// The ink. White is what reads on a photograph.
  final Color color;

  /// The type size. Defaults to 13 in a corner and 15 tiled.
  final double? fontSize;

  /// Whether this is the repeating kind.
  bool get tiled => placement == PlImageWatermarkPlacement.tile;

  /// The opacity actually used.
  double get resolvedOpacity => opacity ?? (tiled ? 0.14 : 0.55);

  /// The type size actually used.
  double get resolvedFontSize => fontSize ?? (tiled ? 15 : 13);

  @override
  bool operator ==(Object other) {
    return other is PlImageWatermark &&
        other.text == text &&
        other.placement == placement &&
        other.opacity == opacity &&
        other.angle == angle &&
        other.color == color &&
        other.fontSize == fontSize;
  }

  @override
  int get hashCode => Object.hash(text, placement, opacity, angle, color, fontSize);
}

/// A mark over a picture, in a corner or across the whole of it.
///
/// It is excluded from the semantics tree and takes no pointer: a watermark is
/// a claim about the file rather than something the screen is telling a reader,
/// and a screen reader announcing "Ada & Co" between the picture and its caption
/// is reading out a stamp. The picture's own label is where it says what it is.
///
/// The tiled layer is **turned as one layer** rather than each copy being turned
/// on its own, which is what keeps the repeat seamless — turning the marks
/// inside a straight grid leaves the grid's own lines showing through. The
/// canvas is turned once and the grid is laid out on the turned canvas, oversized
/// so the corners the turn opens up are still covered.
class PlassWatermarkLayer extends StatelessWidget {
  /// Creates the layer.
  const PlassWatermarkLayer({required this.watermark, super.key});

  /// The mark to draw.
  final PlImageWatermark watermark;

  @override
  Widget build(BuildContext context) {
    if (watermark.text.isEmpty) {
      return const SizedBox.shrink();
    }

    if (watermark.tiled) {
      return Positioned.fill(
        child: IgnorePointer(
          child: ExcludeSemantics(
            child: ClipRect(
              child: CustomPaint(
                painter: _TiledWatermarkPainter(
                  text: watermark.text,
                  color: watermark.color.withValues(alpha: watermark.resolvedOpacity),
                  fontSize: watermark.resolvedFontSize,
                  angle: watermark.angle,
                  textDirection: Directionality.of(context),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final bool top =
        watermark.placement == PlImageWatermarkPlacement.topStart ||
        watermark.placement == PlImageWatermarkPlacement.topEnd;
    final bool start =
        watermark.placement == PlImageWatermarkPlacement.topStart ||
        watermark.placement == PlImageWatermarkPlacement.bottomStart;

    return PositionedDirectional(
      top: top ? 8 : null,
      bottom: top ? null : 8,
      start: start ? 8 : null,
      end: start ? null : 8,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: Opacity(
            opacity: watermark.resolvedOpacity,
            child: Text(
              watermark.text,
              style: TextStyle(
                color: watermark.color,
                fontSize: watermark.resolvedFontSize,
                fontWeight: FontWeight.w600,
                // A photograph is not a background you can predict, so the mark
                // carries its own contrast rather than trusting what is under it.
                shadows: const <Shadow>[
                  Shadow(color: Color(0x8C000000), offset: Offset(0, 1), blurRadius: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The repeating mark, painted once over the whole picture.
class _TiledWatermarkPainter extends CustomPainter {
  const _TiledWatermarkPainter({
    required this.text,
    required this.color,
    required this.fontSize,
    required this.angle,
    required this.textDirection,
  });

  final String text;
  final Color color;
  final double fontSize;
  final double angle;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w600),
      ),
      textDirection: textDirection,
    )..layout();

    // The same spacing the other package's SVG tile uses, so a tiled mark reads
    // the same density on both sides.
    final double stepX = painter.width + 48;
    final double stepY = fontSize * 4.6;

    canvas.save();
    // Turned once, about the middle, with the grid then laid out on the turned
    // canvas: the seam a per-mark rotation leaves is the grid's own lines, and
    // there is no grid left to see once the whole thing has turned.
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(angle * math.pi / 180);

    // Half again the box in both directions, so the turn never brings an
    // uncovered corner into view.
    final double reachX = size.width * 0.75 + stepX;
    final double reachY = size.height * 0.75 + stepY;

    for (double y = -reachY; y < reachY; y += stepY) {
      for (double x = -reachX; x < reachX; x += stepX) {
        painter.paint(canvas, Offset(x, y));
      }
    }

    canvas.restore();
    painter.dispose();
  }

  @override
  bool shouldRepaint(_TiledWatermarkPainter old) {
    return old.text != text ||
        old.color != color ||
        old.fontSize != fontSize ||
        old.angle != angle ||
        old.textDirection != textDirection;
  }
}
