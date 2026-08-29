import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

/// A ring with a gap, drawn rather than imported: the package ships no icons.
class _RefreshGlyph extends StatelessWidget {
  const _RefreshGlyph();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size.square(24), painter: _RefreshPainter());
  }
}

class _RefreshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF2C49D6);

    canvas.drawArc(Rect.fromLTWH(2, 2, size.width - 4, size.height - 4), -0.6, 5.2, false, stroke);
  }

  @override
  bool shouldRepaint(_RefreshPainter oldDelegate) => false;
}

class AnimateRotateHero extends StatelessWidget {
  const AnimateRotateHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 40,
      children: <Widget>[
        PlAnimateRotate(
          from: 0,
          to: 360,
          duration: Duration(milliseconds: 2400),
          curve: Curves.linear,
          repeat: null,
          fade: false,
          child: _RefreshGlyph(),
        ),
        PlAnimateRotate(
          from: -180,
          duration: Duration(milliseconds: 1600),
          repeat: null,
          alternate: true,
          fade: false,
          child: _RefreshGlyph(),
        ),
      ],
    );
  }
}
