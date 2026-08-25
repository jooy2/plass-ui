import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ButtonIcons extends StatelessWidget {
  const ButtonIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        PlButton(startIcon: const _Plus(), onPressed: () {}, child: const Text('New project')),
        PlButton(
          variant: PlassVariant.glass,
          endIcon: const _Arrow(),
          onPressed: () {},
          child: const Text('Continue'),
        ),
        PlButton(semanticLabel: 'Add', startIcon: const _Plus(), onPressed: () {}),
        PlButton(
          variant: PlassVariant.ghost,
          semanticLabel: 'Add',
          startIcon: const _Plus(),
          onPressed: () {},
        ),
      ],
    );
  }
}

/// A glyph that takes its size and its ink from the button around it.
///
/// `IconTheme` is how a button says "1.2em" to something that is not text — the
/// same job `[&_svg]:size-[1.2em]` does in the React package's stylesheet.
class _Glyph extends StatelessWidget {
  const _Glyph(this.draw);

  final void Function(Canvas canvas, Paint paint) draw;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final size = theme.size ?? 16;

    return CustomPaint(
      size: Size.square(size),
      painter: _GlyphPainter(
        draw: draw,
        color: theme.color ?? const Color(0xFF000000),
        scale: size / 16,
      ),
    );
  }
}

class _Plus extends StatelessWidget {
  const _Plus();

  @override
  Widget build(BuildContext context) {
    return _Glyph((Canvas canvas, Paint paint) {
      canvas
        ..drawLine(const Offset(8, 3.5), const Offset(8, 12.5), paint)
        ..drawLine(const Offset(3.5, 8), const Offset(12.5, 8), paint);
    });
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow();

  @override
  Widget build(BuildContext context) {
    return _Glyph((Canvas canvas, Paint paint) {
      canvas
        ..drawLine(const Offset(3.5, 8), const Offset(12.5, 8), paint)
        ..drawPath(
          Path()
            ..moveTo(9, 4.5)
            ..lineTo(12.5, 8)
            ..lineTo(9, 11.5),
          paint,
        );
    });
  }
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter({required this.draw, required this.color, required this.scale});

  final void Function(Canvas canvas, Paint paint) draw;
  final Color color;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    // Drawn in the same 16-unit box the React package's SVGs use, so the two
    // are the same drawing rather than two attempts at one.
    canvas.save();
    canvas.scale(scale);

    draw(
      canvas,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlyphPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.scale != scale;
  }
}
