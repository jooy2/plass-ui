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

import 'package:plass_ui/src/types.dart';

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

/// One of the drawings more than one component needs.
///
/// Every one is written in the same 16-unit box the React package's SVGs are,
/// so the two are the same drawing rather than two drawings that resemble each
/// other. What a shape means is fixed: an × is dismissal everywhere in the
/// library, and a component that wants a different × is a component that has
/// got dismissal wrong.
enum PlassGlyphShape {
  /// Two chevrons, for a stepper that jumps to an end rather than by one page.
  doubleChevron,

  /// The disclosure chevron, drawn pointing **down**.
  ///
  /// One drawing for every direction — an accordion's header, a select's
  /// trigger and a pagination stepper all want the same wedge turned a
  /// different way, and [PlassGlyph.quarterTurns] is how it turns.
  chevron,

  /// The arrow, drawn pointing **right**. One of the two marks a trail can put
  /// between its steps, and the one that says "and then" out loud.
  arrowRight,

  /// Three dots: the middle of something that has been folded away.
  ellipsis,

  /// The tick: a chosen option, a ticked row, a checked box.
  check,

  /// Two ticks overlapping by a third of their width — a message that arrived.
  ///
  /// The one glyph in the library a single component has any use for, and the
  /// overlap is the whole of it: a delivered message and a sent one have to be
  /// told apart at 12px, side by side, in a column of forty.
  doubleCheck,

  /// A stepper's decrement. Drawn at the same weight as [plus], because a minus
  /// a quarter-point lighter than the plus beside it reads as two toolkits in
  /// one control.
  minus,

  /// A stepper's increment. See [minus].
  plus,

  /// The ×, and the one drawing for every dismissal in the library.
  close,

  /// The clock: something that has been started and has not finished.
  clock,

  /// The chain: a link that stays on this page.
  link,

  /// The arrow leaving its box: a link that opens somewhere else.
  externalLink,

  /// A circled `i`, without the serif problem an `i` has at 16px. The mark for
  /// every family with no severity of its own.
  note,

  /// A circled tick. `success`.
  successMark,

  /// The triangle. `warning`.
  warningMark,

  /// A circled ×. `danger`.
  dangerMark,
}

/// The mark that goes with a colour family.
///
/// A piece of the design language rather than a convenience: an alert that says
/// "this went wrong" only in red says it only to some readers, so the shape has
/// to carry the meaning too — and that only holds if every component reaches for
/// the same shape for the same family.
///
/// `primary` and `secondary` have no severity to draw, so they take the note the
/// informational one uses. Three shapes for six families, because the three that
/// mean something are the three worth telling apart.
PlassGlyphShape severityGlyph(PlassColor color) {
  switch (color) {
    case PlassColor.success:
      return PlassGlyphShape.successMark;
    case PlassColor.warning:
      return PlassGlyphShape.warningMark;
    case PlassColor.danger:
      return PlassGlyphShape.dangerMark;
    case PlassColor.primary:
    case PlassColor.secondary:
    case PlassColor.info:
      return PlassGlyphShape.note;
  }
}

/// One of the library's own glyphs, drawn at [size] in [color].
///
/// Takes its size and colour from the surrounding [IconTheme] the way an [Icon]
/// does, so a glyph inside a control picks up the 1.2× the control set without
/// being told.
class PlassGlyph extends StatelessWidget {
  /// Creates a glyph.
  const PlassGlyph(this.shape, {this.size, this.color, this.quarterTurns = 0, super.key});

  /// Which drawing.
  final PlassGlyphShape shape;

  /// The box it is drawn in. Falls back to the ambient [IconTheme].
  final double? size;

  /// The ink. Falls back to the ambient [IconTheme].
  final Color? color;

  /// Quarter turns clockwise. `1` points a [PlassGlyphShape.chevron] left, `-1`
  /// points it right.
  ///
  /// Turning a glyph is the one allowance the library's no-transform rule
  /// makes. The rule is about a control resampling its own label under the
  /// pointer; a wedge has no text in it to resample.
  final int quarterTurns;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final box = size ?? theme.size ?? 16;
    final ink = color ?? theme.color ?? const Color(0xFF000000);

    Widget glyph = CustomPaint(
      size: Size.square(box),
      painter: _GlyphPainter(shape: shape, color: ink),
    );

    if (quarterTurns % 4 != 0) {
      glyph = RotatedBox(quarterTurns: quarterTurns, child: glyph);
    }

    return ExcludeSemantics(child: glyph);
  }
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter({required this.shape, required this.color});

  final PlassGlyphShape shape;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 16;

    canvas.save();
    canvas.scale(scale);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color
      ..strokeWidth = _strokeWidth;
    final fill = Paint()..color = color;

    final line = Path();
    final solid = Path();

    _draw(line, solid);

    canvas
      ..drawPath(line, stroke)
      ..drawPath(solid, fill)
      ..restore();
  }

  double get _strokeWidth {
    switch (shape) {
      case PlassGlyphShape.check:
      case PlassGlyphShape.doubleCheck:
      case PlassGlyphShape.minus:
      case PlassGlyphShape.plus:
      case PlassGlyphShape.close:
        return 1.75;
      case PlassGlyphShape.chevron:
      case PlassGlyphShape.doubleChevron:
      case PlassGlyphShape.arrowRight:
      case PlassGlyphShape.ellipsis:
      case PlassGlyphShape.clock:
      case PlassGlyphShape.link:
      case PlassGlyphShape.externalLink:
      case PlassGlyphShape.note:
      case PlassGlyphShape.successMark:
      case PlassGlyphShape.warningMark:
      case PlassGlyphShape.dangerMark:
        return 1.5;
    }
  }

  /// The drawings, unit for unit out of the React package's SVG paths.
  void _draw(Path line, Path solid) {
    switch (shape) {
      case PlassGlyphShape.chevron:
        line
          ..moveTo(4.5, 6.5)
          ..lineTo(8, 10)
          ..lineTo(11.5, 6.5);
      case PlassGlyphShape.doubleChevron:
        // Drawn pointing **right**, unlike its single sibling: a stepper is
        // never turned a quarter, only flipped.
        line
          ..moveTo(7.5, 4.5)
          ..lineTo(11, 8)
          ..lineTo(7.5, 11.5)
          ..moveTo(3.5, 4.5)
          ..lineTo(7, 8)
          ..lineTo(3.5, 11.5);
      case PlassGlyphShape.arrowRight:
        line
          ..moveTo(3, 8)
          ..lineTo(13, 8)
          ..moveTo(9.5, 4.5)
          ..lineTo(13, 8)
          ..lineTo(9.5, 11.5);
      case PlassGlyphShape.ellipsis:
        for (final x in const <double>[3.5, 8, 12.5]) {
          solid.addOval(Rect.fromCircle(center: Offset(x, 8), radius: 1.15));
        }
      case PlassGlyphShape.check:
        line
          ..moveTo(3.5, 8.5)
          ..lineTo(6.5, 11.5)
          ..lineTo(12.5, 5.5);
      case PlassGlyphShape.doubleCheck:
        line
          ..moveTo(1.5, 8.5)
          ..lineTo(4.25, 11.25)
          ..lineTo(9.5, 6)
          ..moveTo(7, 10.75)
          ..lineTo(8.25, 12)
          ..lineTo(13.5, 6.75);
      case PlassGlyphShape.minus:
        line
          ..moveTo(3.5, 8)
          ..lineTo(12.5, 8);
      case PlassGlyphShape.plus:
        line
          ..moveTo(8, 3.5)
          ..lineTo(8, 12.5)
          ..moveTo(3.5, 8)
          ..lineTo(12.5, 8);
      case PlassGlyphShape.close:
        line
          ..moveTo(4.5, 4.5)
          ..lineTo(11.5, 11.5)
          ..moveTo(11.5, 4.5)
          ..lineTo(4.5, 11.5);
      case PlassGlyphShape.clock:
        line
          ..addOval(Rect.fromCircle(center: const Offset(8, 8), radius: 6.25))
          ..moveTo(8, 4.5)
          ..lineTo(8, 8)
          ..lineTo(10.4, 9.6);
      case PlassGlyphShape.link:
        line
          ..moveTo(6.5, 9.5)
          ..arcToPoint(const Offset(10.5, 9.75), radius: _r275, clockwise: false)
          ..lineTo(12.25, 8)
          ..arcToPoint(const Offset(8.35, 4.1), radius: _r275, clockwise: false)
          ..lineTo(7.75, 5.2)
          ..moveTo(9.5, 6.5)
          ..arcToPoint(const Offset(5.5, 6.25), radius: _r275, clockwise: false)
          ..lineTo(3.75, 8)
          ..arcToPoint(const Offset(7.65, 11.9), radius: _r275, clockwise: false)
          ..lineTo(8.25, 11.3);
      case PlassGlyphShape.externalLink:
        line
          ..moveTo(12.75, 9.25)
          ..lineTo(12.75, 11.75)
          ..arcToPoint(const Offset(11.25, 13.25), radius: _r15)
          ..lineTo(4.25, 13.25)
          ..arcToPoint(const Offset(2.75, 11.75), radius: _r15)
          ..lineTo(2.75, 4.75)
          ..arcToPoint(const Offset(4.25, 3.25), radius: _r15)
          ..lineTo(6.75, 3.25)
          ..moveTo(9.5, 2.75)
          ..lineTo(13.25, 2.75)
          ..lineTo(13.25, 6.5)
          ..moveTo(7.25, 8.75)
          ..lineTo(13, 3);
      case PlassGlyphShape.note:
        line
          ..addOval(Rect.fromCircle(center: const Offset(8, 8), radius: 6.25))
          ..moveTo(8, 7.25)
          ..lineTo(8, 11.25);
        solid.addOval(Rect.fromCircle(center: const Offset(8, 4.9), radius: 0.85));
      case PlassGlyphShape.successMark:
        line
          ..addOval(Rect.fromCircle(center: const Offset(8, 8), radius: 6.25))
          ..moveTo(5.25, 8.25)
          ..lineTo(7.15, 10.15)
          ..lineTo(10.75, 6.25);
      case PlassGlyphShape.warningMark:
        line
          ..moveTo(7.13, 2.6)
          ..lineTo(1.9, 11.7)
          ..arcToPoint(const Offset(2.77, 13.2), radius: _r1, clockwise: false)
          ..lineTo(13.23, 13.2)
          ..arcToPoint(const Offset(14.1, 11.7), radius: _r1, clockwise: false)
          ..lineTo(8.87, 2.6)
          ..arcToPoint(const Offset(7.13, 2.6), radius: _r1, clockwise: false)
          ..close();
        line
          ..moveTo(8, 6.1)
          ..lineTo(8, 9.1);
        solid.addOval(Rect.fromCircle(center: const Offset(8, 11.2), radius: 0.85));
      case PlassGlyphShape.dangerMark:
        line
          ..addOval(Rect.fromCircle(center: const Offset(8, 8), radius: 6.25))
          ..moveTo(5.9, 5.9)
          ..lineTo(10.1, 10.1)
          ..moveTo(10.1, 5.9)
          ..lineTo(5.9, 10.1);
    }
  }

  static const Radius _r1 = Radius.circular(1);
  static const Radius _r15 = Radius.circular(1.5);
  static const Radius _r275 = Radius.circular(2.75);

  @override
  bool shouldRepaint(_GlyphPainter oldDelegate) {
    return oldDelegate.shape != shape || oldDelegate.color != color;
  }
}
