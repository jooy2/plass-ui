import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class OverlayHero extends StatefulWidget {
  const OverlayHero({super.key});

  @override
  State<OverlayHero> createState() => _OverlayHeroState();
}

class _OverlayHeroState extends State<OverlayHero> {
  bool _open = false;
  Timer? _finish;

  @override
  void dispose() {
    _finish?.cancel();
    super.dispose();
  }

  void _save() {
    setState(() => _open = true);
    _finish?.cancel();
    _finish = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() => _open = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final family = PlassTheme.of(context).family(PlassColor.primary);

    // A preview is as tall as its content, and a sheet takes away whatever it is
    // inside. This is the page for it to take.
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: <Widget>[
          PlButton(onPressed: _save, child: const Text('Save and wait')),
          PlOverlay(
            open: _open,
            label: 'Saving your changes',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: <Widget>[
                _Spinner(color: family.accent),
                PlTypography(
                  'Saving your changes…',
                  color: PlassColor.primary,
                  weight: PlTypographyWeight.medium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A turning ring, drawn here rather than imported.
///
/// The library ships no spinner, in either package: an app already has one, and
/// a design system that shipped a second would be asking every screen which of
/// the two it meant. The React gallery draws its own out of an `<svg>` for the
/// same reason this draws its own out of an arc.
class _Spinner extends StatefulWidget {
  const _Spinner({required this.color});

  final Color color;

  /// One size, because the demo only ever asks for one.
  static const double size = 32;

  @override
  State<_Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<_Spinner> with SingleTickerProviderStateMixin {
  late final AnimationController _turn = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _turn,
      child: CustomPaint(
        size: const Size.square(_Spinner.size),
        painter: _RingPainter(widget.color),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width / 8;
    final ring = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(ring.center, ring.width / 2, paint..color = color.withValues(alpha: 0.25));
    canvas.drawArc(ring, -math.pi / 2, math.pi / 2, false, paint..color = color);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.color != color;
}
