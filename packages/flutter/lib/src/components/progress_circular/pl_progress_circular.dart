/// A ring that fills.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/progress.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// A ring that fills.
///
/// ```dart
/// PlProgressCircular(label: const Text('Syncing'), value: 68, showValue: true)
/// ```
///
/// The one to reach for where there is no room for a bar — inside a table row,
/// beside a field, at the end of a line of text. The size ladder is what it is
/// for: a `md` ring is 20 logical pixels inside a 40px control, so a ring
/// dropped into a row never makes the row taller than it already was.
///
/// The arc is the family's **gradient** and not a flat colour, which is the one
/// place a `Shader` is built by hand in this package: a stroke takes a shader
/// rather than a decoration, so the sweep the rest of the library gets from
/// `PlassCssGradient` has to be asked for directly. It is worth it — a flat ring
/// beside a swept bar is two materials for one idea.
///
/// The value and the label sit *beside* the ring rather than inside it. A number
/// in the middle of a dial is the picture everyone has of this component, and it
/// works at two of the five sizes: at `xs` the ring is fourteen pixels across
/// and there is nowhere for "40%" to go.
class PlProgressCircular extends StatefulWidget {
  /// Creates a ring. With no [value] it is indeterminate and turns.
  const PlProgressCircular({
    this.value,
    this.min = 0,
    this.max = 100,
    this.label,
    this.showValue = false,
    this.formatValue,
    this.size,
    this.color,
    super.key,
  });

  /// How far along, between [min] and [max]. `null` — the default — is the
  /// indeterminate case, and a value outside the range is clamped.
  final double? value;

  /// The bottom of the range.
  final double min;

  /// The top of it.
  final double max;

  /// A name for what is loading. Read out with the value by a screen reader.
  final Widget? label;

  /// Shows the value as text beside the ring.
  final bool showValue;

  /// How to write it. A function rather than an options object, for the reason
  /// `PlProgressLinear.formatValue` gives.
  final String Function(double value)? formatValue;

  /// Diameter of the ring.
  final PlassSize? size;

  /// Semantic colour role. It becomes the gradient of the arc.
  final PlassColor? color;

  @override
  State<PlProgressCircular> createState() => _PlProgressCircularState();
}

class _PlProgressCircularState extends State<PlProgressCircular>
    with SingleTickerProviderStateMixin {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;

  late final AnimationController _spin = AnimationController(vsync: this, duration: spinDuration);

  double? get _fraction => progressFraction(widget.value, widget.min, widget.max);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSpin();
  }

  @override
  void didUpdateWidget(PlProgressCircular oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSpin();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  void _syncSpin() {
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final wanted = still ? slowSpinDuration : spinDuration;

    if (_spin.duration != wanted) {
      _spin.duration = wanted;

      if (_spin.isAnimating) {
        _spin
          ..stop()
          ..repeat();
      }
    }

    if (_fraction == null) {
      if (!_spin.isAnimating) {
        _spin.repeat();
      }
    } else if (_spin.isAnimating) {
      _spin.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(_color);
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final fraction = _fraction;
    final diameter = ringDiameter[_size]!;
    final meta = metaText[_size]!;

    final text = fraction == null
        ? null
        : widget.formatValue != null && widget.value != null
        ? widget.formatValue!(widget.value!)
        : progressText(fraction);

    final ring = RepaintBoundary(
      child: SizedBox.square(
        dimension: diameter,
        child: fraction == null
            ? AnimatedBuilder(
                animation: _spin,
                builder: (BuildContext context, Widget? child) => CustomPaint(
                  painter: _RingPainter(
                    track: tokens.track,
                    from: family.solid,
                    to: family.solidTo,
                    stroke: ringStroke[_size]!,
                    // A fixed quarter-arc, turned. Determinate holds still and
                    // lets the gap close instead; both are one arc on one
                    // circle.
                    sweep: ringArcSweep,
                    turn: _spin.value,
                  ),
                ),
              )
            : TweenAnimationBuilder<double>(
                tween: Tween<double>(end: fraction),
                duration: still ? Duration.zero : fillDuration,
                curve: PlassTokens.ease,
                builder: (BuildContext context, double value, Widget? child) => CustomPaint(
                  painter: _RingPainter(
                    track: tokens.track,
                    from: family.solid,
                    to: family.solidTo,
                    stroke: ringStroke[_size]!,
                    sweep: value,
                    turn: 0,
                  ),
                ),
              ),
      ),
    );

    return MergeSemantics(
      child: Semantics(
        role: fraction == null ? SemanticsRole.loadingSpinner : SemanticsRole.progressBar,
        value: progressSemanticValue(fraction, widget.formatValue, widget.value),
        container: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: gap[_size]!,
          children: <Widget>[
            ring,
            if (widget.label != null)
              Flexible(
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: tokens.fg, fontSize: meta),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  child: widget.label!,
                ),
              ),
            if (widget.showValue && text != null)
              // Drawn, not read: the same string is already this node's value.
              ExcludeSemantics(
                child: Text(
                  text,
                  style: TextStyle(
                    color: tokens.mutedFg,
                    fontSize: meta,
                    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The two arcs: the groove all the way round, and the family over part of it.
class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.track,
    required this.from,
    required this.to,
    required this.stroke,
    required this.sweep,
    required this.turn,
  });

  /// The groove the arc is cut into.
  final Color track;

  /// The two ends of the family's gradient, at the same 135° everything else in
  /// the library is lit from.
  final Color from;

  /// See [from].
  final Color to;

  /// How thick both arcs are.
  final double stroke;

  /// How much of the circle the family covers, `0`…`1`.
  final double sweep;

  /// How far round the whole thing has been turned, `0`…`1`. Only the
  /// indeterminate ring uses it.
  final double turn;

  @override
  void paint(Canvas canvas, Size size) {
    // The stroke straddles the path, so the radius comes in by half of it or the
    // ring is clipped by its own box.
    final radius = (size.shortestSide - stroke) / 2;
    final centre = Offset(size.width / 2, size.height / 2);
    final box = Rect.fromCircle(center: centre, radius: radius);

    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );

    if (sweep <= 0) {
      return;
    }

    // 135° across the box the ring sits in, so the arc's sweep matches the fill
    // of a bar beside it rather than being a second kind of gradient.
    final radians = 135 * math.pi / 180;
    final axis = Offset(math.sin(radians), -math.cos(radians));
    final half = axis * (size.shortestSide / 2);

    canvas.drawArc(
      box,
      // Twelve o'clock, not three: a ring that filled from the right would be
      // reading a clock nobody has.
      -math.pi / 2 + turn * 2 * math.pi,
      math.min(sweep, 1) * 2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.linear(centre - half, centre + half, <Color>[from, to]),
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.track != track ||
        oldDelegate.from != from ||
        oldDelegate.to != to ||
        oldDelegate.stroke != stroke ||
        oldDelegate.sweep != sweep ||
        oldDelegate.turn != turn;
  }
}
