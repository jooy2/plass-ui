import 'package:flutter/widgets.dart';

/// The drawings the demos use.
///
/// Flutter ships no icon set outside Material, and the library depends on
/// neither Material nor an icon package — so the gallery draws the handful of
/// glyphs its examples need, the same way an app would hand `PlIcon` whatever
/// its own set gave it.
///
/// Each one takes its size and its colour from the surrounding [IconTheme],
/// which is what an [Icon] does and what `PlIcon` sets.
class _Glyph extends StatelessWidget {
  const _Glyph({required this.trace});

  final void Function(Path path) trace;

  /// The weight every demo glyph is drawn at. One number, because two glyphs at
  /// two weights in the same row read as two icon sets.
  static const double strokeWidth = 1.6;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);

    return CustomPaint(
      size: Size.square(theme.size ?? 24),
      painter: _GlyphPainter(trace: trace, color: theme.color ?? const Color(0xFF000000)),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter({required this.trace, required this.color});

  final void Function(Path path) trace;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    trace(path);

    canvas
      ..save()
      // Every drawing below is written in the 24-unit box its SVG uses.
      ..scale(size.shortestSide / 24)
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _Glyph.strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = color,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_GlyphPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.trace != trace;
  }
}

/// A lightning bolt.
class BoltGlyph extends StatelessWidget {
  /// Creates the bolt.
  const BoltGlyph({super.key});

  static void _trace(Path path) {
    path
      ..moveTo(13, 2)
      ..lineTo(4, 14)
      ..lineTo(11, 14)
      ..lineTo(10, 22)
      ..lineTo(19, 10)
      ..lineTo(12, 10)
      ..close();
  }

  @override
  Widget build(BuildContext context) => const _Glyph(trace: _trace);
}

/// A bell.
class BellGlyph extends StatelessWidget {
  /// Creates the bell.
  const BellGlyph({super.key});

  static void _trace(Path path) {
    path
      ..moveTo(18, 8)
      ..arcToPoint(const Offset(6, 8), radius: const Radius.circular(6), largeArc: true)
      ..cubicTo(6, 14, 4, 15, 4, 15)
      ..lineTo(20, 15)
      ..cubicTo(20, 15, 18, 14, 18, 8)
      ..moveTo(13.7, 20)
      ..arcToPoint(const Offset(10.3, 20), radius: const Radius.circular(2));
  }

  @override
  Widget build(BuildContext context) => const _Glyph(trace: _trace);
}

/// A heart.
class HeartGlyph extends StatelessWidget {
  /// Creates the heart.
  const HeartGlyph({super.key});

  static void _trace(Path path) {
    path
      ..moveTo(12, 20.5)
      ..lineTo(4.2, 13)
      ..arcToPoint(const Offset(10.8, 6.4), radius: const Radius.circular(4.7))
      ..lineTo(12, 7.6)
      ..lineTo(13.2, 6.4)
      ..arcToPoint(const Offset(19.8, 13), radius: const Radius.circular(4.7), largeArc: true)
      ..close();
  }

  @override
  Widget build(BuildContext context) => const _Glyph(trace: _trace);
}
