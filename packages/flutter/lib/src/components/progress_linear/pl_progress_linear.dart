/// A bar that fills.
library;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/progress.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// A bar that fills.
///
/// ```dart
/// PlProgressLinear(label: const Text('Uploading'), value: 62, showValue: true)
/// ```
///
/// The workhorse of the indicators: it is the only one that can show *how much*
/// is left at a glance, because length is the one quantity a reader can compare
/// without counting.
///
/// The groove is [PlassTokens.track], the same neutral ink a `PlSlider`'s rail
/// and a `PlSwitch`'s off state are cut in, and the segment over it is the
/// family's gradient — so the filled part of the run is made of exactly the same
/// material as the button that submits the form it is in.
///
/// Both the groove and the segment are fully rounded, and that is the one place
/// the library's rule about pills does not apply. The rule protects the flat run
/// along a control's edge that a line of text sits on; at six logical pixels
/// tall there is no flat run left to protect, and a square-ended bar reads as a
/// rendering fault rather than as a cut edge.
///
/// There is no `variant`, no `density` and no `elevation`: an indicator is one
/// material, it has nothing to pad, and it is cut **into** the surface it sits
/// on the way a groove is — and a groove does not float.
class PlProgressLinear extends StatefulWidget {
  /// Creates a bar. With no [value] it is indeterminate and sweeps.
  const PlProgressLinear({
    this.value,
    this.min = 0,
    this.max = 100,
    this.label,
    this.showValue = false,
    this.formatValue,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    super.key,
  });

  /// How far along, between [min] and [max].
  ///
  /// `null` — the default — is the indeterminate case: something is happening
  /// and nobody knows how much of it is left. That is the default on purpose.
  /// An indicator that has not been told a value should say so rather than draw
  /// an empty bar, which is a claim that no progress has been made.
  ///
  /// A value outside the range is clamped rather than drawn: it usually arrives
  /// from a division somewhere, and a bar that renders 140% wide because one
  /// request finished twice is a worse bug than a bar that sits full.
  final double? value;

  /// The bottom of the range.
  final double min;

  /// The top of it.
  final double max;

  /// A name for what is loading. Read out with the value by a screen reader.
  final Widget? label;

  /// Shows the value as text beside the bar. A percentage of [min]…[max] unless
  /// [formatValue] says otherwise.
  final bool showValue;

  /// How to write the value when it is shown, given the raw [value].
  ///
  /// A callback rather than an options object, which is the one place this
  /// parts company with the React build: there is no `Intl.NumberFormat` in the
  /// framework to hand options to, and a package that pulled `package:intl` in
  /// to provide one would be making a dependency decision on its consumer's
  /// behalf. Whatever formats numbers in the app already can format this one.
  ///
  /// Without it the value is a percentage of the range, which is the only
  /// formatting that holds for a range nobody described.
  final String Function(double value)? formatValue;

  /// Thickness of the groove. Nothing else on a bar has a size.
  final PlassSize size;

  /// Semantic colour role. It becomes the gradient of the filled part.
  final PlassColor color;

  @override
  State<PlProgressLinear> createState() => _PlProgressLinearState();
}

class _PlProgressLinearState extends State<PlProgressLinear> with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(vsync: this, duration: sweepDuration);

  double? get _fraction => progressFraction(widget.value, widget.min, widget.max);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSweep();
  }

  @override
  void didUpdateWidget(PlProgressLinear oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSweep();
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  /// The segment runs only while there is nothing to say, and it is slowed
  /// rather than stopped where the platform has asked for less movement: an
  /// indeterminate indicator that holds still says the opposite of what it is
  /// for.
  void _syncSweep() {
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final wanted = still ? pulseDuration : sweepDuration;

    if (_sweep.duration != wanted) {
      _sweep.duration = wanted;

      if (_sweep.isAnimating) {
        _sweep
          ..stop()
          ..repeat();
      }
    }

    if (_fraction == null) {
      if (!_sweep.isAnimating) {
        _sweep.repeat();
      }
    } else if (_sweep.isAnimating) {
      _sweep.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(widget.color);
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final fraction = _fraction;
    final thickness = barThickness[widget.size]!;
    final radius = BorderRadius.circular(thickness);
    final meta = metaText[widget.size]!;

    final text = fraction == null
        ? null
        : widget.formatValue != null && widget.value != null
        ? widget.formatValue!(widget.value!)
        : progressText(fraction);

    final groove = ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: thickness,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(color: tokens.track),
          child: fraction == null
              ? _Sweep(gradient: family.fill, radius: radius, animation: _sweep, still: still)
              : Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AnimatedFractionallySizedBox(
                    duration: still ? Duration.zero : fillDuration,
                    curve: PlassTokens.ease,
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: fraction,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(gradient: family.fill, borderRadius: radius),
                    ),
                  ),
                ),
        ),
      ),
    );

    final head = widget.label != null || (widget.showValue && text != null)
        ? Padding(
            padding: EdgeInsets.only(bottom: stackGap[widget.size]!),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              // Only reached with no label, where the value is on its own and
              // belongs at the end of the run it measures.
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                if (widget.label != null)
                  Expanded(
                    child: DefaultTextStyle.merge(
                      style: TextStyle(color: tokens.fg, fontSize: meta),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      child: widget.label!,
                    ),
                  ),
                if (widget.showValue && text != null) ...<Widget>[
                  if (widget.label != null) const SizedBox(width: 8),
                  // Drawn, not read: the same string is already on the node
                  // below as its value, and a screen reader should hear it once.
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
              ],
            ),
          )
        : null;

    // Merged, so the label and the bar are one node rather than a name floating
    // beside an unnamed progress bar.
    return MergeSemantics(
      child: Semantics(
        // `null` is not an omission: with no value the platform is told to
        // announce indeterminate progress rather than a number.
        role: fraction == null ? SemanticsRole.loadingSpinner : SemanticsRole.progressBar,
        value: progressSemanticValue(fraction, widget.formatValue, widget.value),
        container: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[?head, groove],
        ),
      ),
    );
  }
}

/// The travelling segment.
///
/// It moves on an alignment rather than on a transform, which is the same trade
/// the React package makes with `inset-inline-start`: the layout pass it costs
/// is confined to a box with nothing in it, and it runs the other way under RTL
/// without being told, because the alignment is directional.
///
/// Under a reduced-motion preference it stops travelling, fills the groove and
/// breathes instead — the colour axis every other state in the library uses.
class _Sweep extends StatelessWidget {
  const _Sweep({
    required this.gradient,
    required this.radius,
    required this.animation,
    required this.still,
  });

  final Gradient gradient;
  final BorderRadius radius;
  final Animation<double> animation;
  final bool still;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          if (still) {
            // 0 → 1 → 0 across the cycle, which is the pulse's shape.
            final breath = 1 - (animation.value * 2 - 1).abs();

            return Opacity(opacity: 0.4 + breath * 0.6, child: child);
          }

          final eased = PlassTokens.ease.transform(animation.value);

          return FractionallySizedBox(
            // -1 is off the leading edge and 1 is off the trailing one, which is
            // what an `Alignment`'s x runs between — so the segment enters and
            // leaves rather than appearing at the edges.
            alignment: AlignmentDirectional(-1 + eased * 2, 0),
            widthFactor: sweepWidth,
            heightFactor: 1,
            child: child,
          );
        },
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: gradient, borderRadius: radius),
        ),
      ),
    );
  }
}
