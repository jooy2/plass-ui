/// The glyphs more than one component draws.
///
/// A component that needs a shape nobody else needs draws it in its own file.
/// What lands here is what two components would otherwise each have a copy of —
/// and the reason that matters is not the duplication, it is that two copies
/// drift: a spinner in a button and a spinner in a text field have to be the
/// same object in motion, or a form that is saving looks like two things
/// loading.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The one thing in the library that moves on its own, and the only place that
/// is allowed: an indeterminate indicator that does not move is a decoration.
///
/// Sized against the label it sits beside, like every other glyph inside a
/// control, rather than carrying a size of its own.
class PlassSpinner extends StatefulWidget {
  /// Creates a spinner [size] logical pixels across, in [color].
  const PlassSpinner({required this.size, required this.color, super.key});

  /// The box the spinner is drawn in. The stroke scales with it.
  final double size;

  /// The ink. The track behind it is the same colour at a quarter alpha.
  final Color color;

  @override
  State<PlassSpinner> createState() => _PlassSpinnerState();
}

class _PlassSpinnerState extends State<PlassSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _turn = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  @override
  void initState() {
    super.initState();
    _turn.repeat();
  }

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A spinner that has stopped says the work has stopped, so reduced motion
    // does not stop it — but the platform can, and `disableAnimations` is the
    // caller asking for exactly that.
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    if (still && _turn.isAnimating) {
      _turn.stop();
    } else if (!still && !_turn.isAnimating) {
      _turn.repeat();
    }

    return RepaintBoundary(
      child: RotationTransition(
        turns: _turn,
        child: CustomPaint(size: Size.square(widget.size), painter: _SpinnerPainter(widget.color)),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // The same drawing as the React package's SVG: a 16-unit box, a ring at
    // radius 6.5 with a 2-unit stroke, and a quarter of it drawn solid.
    final scale = size.shortestSide / 16;
    final stroke = 2 * scale;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: 6.5 * scale);

    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = color.withValues(alpha: color.a * 0.25),
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi / 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter oldDelegate) => oldDelegate.color != color;
}
