/// A quantity inside a range, drawn as a bar.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/progress.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/threshold.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// Where a band starts, and what the bar is made of from there up.
///
/// The library's own [PlassThreshold] under the name this widget shipped it as.
/// A gauge reads the same bands, so the shape moved to `types.dart` and this
/// stayed as the name a caller already writes.
typedef PlMeterThreshold = PlassThreshold;

/// A quantity inside a range, drawn as a bar.
///
/// ```dart
/// PlMeter(
///   value: 82,
///   label: const Text('Disk used'),
///   showValue: true,
///   thresholds: const <PlMeterThreshold>[
///     PlMeterThreshold(from: 75, color: PlassColor.warning),
///     PlMeterThreshold(from: 90, color: PlassColor.danger),
///   ],
/// )
/// ```
///
/// It looks like a [PlProgressLinear] and it is not one, and the difference is
/// worth stating because it decides which to reach for. **Progress is something
/// advancing; a meter is something already known.** Disk used, seats taken, a
/// password's strength, how full a battery is — none of them is going anywhere
/// on its own, and none of them has an indeterminate state. So [value] is
/// required here and there is no sweep.
///
/// [thresholds] is the prop it exists for. A quota bar that turns amber at three
/// quarters and red at ninety percent says something a fixed colour cannot, and
/// the colour is derived from the value rather than chosen by the caller at the
/// moment they happened to be looking. It is never the *only* thing saying so:
/// [showValue] writes the number out beside it.
///
/// The groove is [PlassTokens.track] and the fill is the family's gradient, both
/// the same as a progress bar's — one material, two meanings.
///
/// There is no `variant`, no `density` and no `elevation`: a meter is one
/// material, it has nothing to pad, and it is cut **into** the surface it sits
/// on the way a groove is.
class PlMeter extends StatelessWidget {
  /// Creates a meter. [value] is required, which is the whole difference from a
  /// [PlProgressLinear].
  const PlMeter({
    required this.value,
    this.min = 0,
    this.max = 100,
    this.label,
    this.showValue = false,
    this.formatValue,
    this.thresholds,
    this.size,
    this.color,
    super.key,
  });

  /// How much there is.
  ///
  /// Required, and that is the whole difference from a [PlProgressLinear]: a
  /// meter reports a quantity that is already known, so there is no
  /// indeterminate case for it to have a default for.
  ///
  /// A value outside the range is clamped rather than drawn, for the reason a
  /// bar's is: it usually arrives from a division somewhere.
  final double value;

  /// The bottom of the range.
  final double min;

  /// The top of it.
  final double max;

  /// A name for what is being measured. Read out with the value.
  final Widget? label;

  /// Shows the value as text beside the bar. A percentage of [min]…[max] unless
  /// [formatValue] says otherwise.
  final bool showValue;

  /// How to write the value when it is shown, given the raw [value].
  ///
  /// A callback rather than an options object, for [PlProgressLinear]'s reason:
  /// there is no `Intl.NumberFormat` in the framework, and a package that pulled
  /// `package:intl` in to provide one would be making a dependency decision on
  /// its consumer's behalf.
  final String Function(double value)? formatValue;

  /// Bands that change the bar's family as the value climbs.
  ///
  /// The band with the highest [PlMeterThreshold.from] at or below the value
  /// wins, and [color] is what the bar is made of below all of them. Order does
  /// not matter; the list is read, not walked.
  final List<PlMeterThreshold>? thresholds;

  /// Thickness of the groove. Nothing else on a meter has a size.
  final PlassSize? size;

  /// The family the bar takes where no threshold applies.
  final PlassColor? color;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final color = this.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;

    final tokens = PlassTheme.of(context);
    final family = tokens.family(bandColor(value, color, thresholds));
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    // `null` only when the range is empty, which is a caller's mistake rather
    // than a state: the bar sits at nothing and the value is still announced.
    final fraction = progressFraction(value, min, max) ?? 0;
    final text = formatValue != null ? formatValue!(value) : progressText(fraction)!;

    final thickness = barThickness[size]!;
    final radius = BorderRadius.circular(thickness);
    final meta = metaText[size]!;

    final groove = ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: thickness,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(color: tokens.track),
          child: Align(
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

    final head = label != null || showValue
        ? Padding(
            padding: EdgeInsets.only(bottom: stackGap[size]!),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              // Only reached with no label, where the value is on its own and
              // belongs at the end of the run it measures.
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                if (label != null)
                  Expanded(
                    child: DefaultTextStyle.merge(
                      style: TextStyle(color: tokens.fg, fontSize: meta),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      child: label!,
                    ),
                  ),
                if (showValue) ...<Widget>[
                  if (label != null) const SizedBox(width: 8),
                  // Drawn, not read: the same string is already the node's
                  // value below, and a screen reader should hear it once.
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
    // beside an unnamed value.
    //
    // No `role`, and that is not an omission: `SemanticsRole` has no `meter`,
    // and claiming `progressBar` would be announcing the one thing this widget
    // exists to say it is not. A named node carrying a value is what the
    // platforms actually read out either way.
    return MergeSemantics(
      child: Semantics(
        value: text,
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
