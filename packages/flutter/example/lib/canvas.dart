import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

/// The ground a preview is drawn on.
///
/// This is `.plass-demo-canvas` from the documentation site's stylesheet, in
/// Dart, and it is here rather than left to the page for a reason that is not
/// cosmetic: a Flutter preview is an `<iframe>`, and a `BackdropFilter` can only
/// blur what is painted **behind it inside the same app**. Left transparent,
/// every `glass` surface in the gallery would have nothing to be in front of and
/// would come out looking opaque — which is exactly the impression the library
/// is trying not to give.
///
/// So the wash and the grid are painted here, from the library's own tokens, and
/// the page hands its padding over to the frame.
class PlassCanvas extends StatelessWidget {
  /// Wraps [child] in the canvas.
  const PlassCanvas({
    required this.child,
    this.align = Alignment.topLeft,
    this.lead = 0,
    super.key,
  });

  /// What is drawn on it.
  final Widget child;

  /// `Alignment.topCenter` for a single control that would look lost against a
  /// left edge.
  final Alignment align;

  /// Empty canvas held above the content, in logical pixels.
  ///
  /// Room for a popup that opened *upwards*, and it has to be room rather than
  /// a taller frame: an `<iframe>` cannot draw above itself, so the only way to
  /// bring a popup that reaches above the demo back into view is to push the
  /// demo down. `room.dart` measures how much. Zero for a preview with nothing
  /// open, which is nearly all of them nearly all of the time.
  final double lead;

  /// The padding the documentation site's canvas would otherwise apply.
  ///
  /// Top-heavy, and the page's own canvas matches it: the site floats a badge
  /// naming the framework in the top-left corner, over this frame, and it needs
  /// a band of its own to sit in. The bottom gives the room back.
  static const EdgeInsets padding = EdgeInsets.fromLTRB(24, 40, 24, 20);

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return DecoratedBox(
      // The same two-stop wash a Plass screen lays its sheets on.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // 160° in CSS terms, near enough to top-to-bottom that the corner
          // form is what reads.
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[tokens.bgFrom, tokens.bgTo],
        ),
      ),
      child: CustomPaint(
        painter: _CanvasPainter(tokens),
        // Scrollable rather than clipped: the page sizes the frame from what
        // this reports, and between the first paint and that message arriving
        // the viewport is whatever height the page reserved. Overflowing it
        // should be a scroll, not a broken preview.
        child: SingleChildScrollView(
          child: Padding(
            padding: padding + EdgeInsets.only(top: lead),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: align == Alignment.topCenter
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: <Widget>[child],
            ),
          ),
        ),
      ),
    );
  }
}

/// The two colour blooms and the faint grid over the wash.
class _CanvasPainter extends CustomPainter {
  const _CanvasPainter(this.tokens);

  final PlassTokens tokens;

  /// `2.5rem` in the stylesheet.
  static const double _cell = 40;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    _bloom(
      canvas,
      rect,
      colour: tokens.family(PlassColor.primary).accent.withValues(alpha: 0.12),
      at: const Offset(0.08, -0.2),
      radii: const Size(512, 320),
    );
    _bloom(
      canvas,
      rect,
      colour: tokens.family(PlassColor.info).accent.withValues(alpha: 0.1),
      at: const Offset(0.96, 0),
      radii: const Size(448, 288),
    );

    // A faint grid, so a blurred backdrop has something to be blurred. Without
    // structure behind it a 22px blur has nothing to smear and the glass reads
    // as a flat translucent panel.
    final line = Paint()..color = tokens.fg.withValues(alpha: 0.04);

    for (double y = 0; y < size.height; y += _cell) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), line);
    }

    for (double x = 0; x < size.width; x += _cell) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 1, size.height), line);
    }
  }

  /// One `radial-gradient(<w> <h> at <x> <y>, colour, transparent 70%)`.
  void _bloom(
    Canvas canvas,
    Rect rect, {
    required Color colour,
    required Offset at,
    required Size radii,
  }) {
    final centre = Offset(rect.width * at.dx, rect.height * at.dy);
    // An ellipse rather than a circle, so it is squeezed onto the shorter axis
    // the same way the CSS two-radius form is.
    final bounds = Rect.fromCenter(
      center: centre,
      width: radii.width * 2,
      height: radii.height * 2,
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[colour, colour.withValues(alpha: 0)],
          stops: const <double>[0, 0.7],
        ).createShader(bounds),
    );
  }

  @override
  bool shouldRepaint(_CanvasPainter oldDelegate) => oldDelegate.tokens != tokens;
}
