/// One figure, and what has happened to it.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/skeleton/pl_skeleton.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

/// Which way a change has to go to be good news.
enum PlStatDirection {
  /// Up. Revenue, sign-ups, uptime.
  up,

  /// Down. Churn, a bounce rate, a p95 latency, a cost.
  down,
}

/// The figure's own ladder. It is the biggest thing in the box and is meant to
/// be.
const Map<PlassSize, double> _valueSize = <PlassSize, double>{
  PlassSize.xs: 20,
  PlassSize.sm: 24,
  PlassSize.md: 30,
  PlassSize.lg: 36,
  PlassSize.xl: 44,
};

/// One figure, and what has happened to it.
///
/// A row of these is the top of every dashboard, and the whole of what makes
/// them worth a widget rather than three `Text`s is the **change**: a number on
/// its own says what things are, and a number with a movement beside it says
/// whether that is going anywhere.
///
/// The colour of that movement is decided by [improvesWhen] and not by the sign,
/// which is the one thing a naive version of this gets wrong. Churn going up is
/// not good news, and a green arrow on it is a dashboard lying to somebody.
///
/// It draws **no surface**. A figure sits in a [PlCard] or in a row of them, and
/// a sheet inside a sheet is two sheets.
///
/// ```dart
/// PlStat(
///   label: const Text('Revenue'),
///   value: const Text('£48,120'),
///   change: 12.4,
///   description: const Text('vs last month'),
/// )
/// ```
class PlStat extends StatelessWidget {
  /// Creates a figure.
  const PlStat({
    this.label,
    this.value,
    this.description,
    this.icon,
    this.change,
    this.changeLabel,
    this.improvesWhen = PlStatDirection.up,
    this.loading = false,
    this.size,
    this.color,
    this.density,
    super.key,
  });

  /// What the figure is of. The line above it.
  final Widget? label;

  /// The figure itself, already formatted.
  ///
  /// A widget rather than a number, and deliberately: how a figure is written —
  /// the currency, the grouping, the decimals, the locale — is the screen's
  /// decision, and `package:intl`'s `NumberFormat` already makes it. A widget
  /// that took a number would have to guess at all four, and this package has no
  /// dependencies to guess with.
  final Widget? value;

  /// A line under the figure. What it is compared with, usually.
  final Widget? description;

  /// A glyph beside the label.
  final Widget? icon;

  /// How much it moved, as a percentage.
  final double? change;

  /// What the change says instead of the formatted percentage. For a figure that
  /// moved by a count rather than by a proportion.
  final Widget? changeLabel;

  /// Which way is good news.
  final PlStatDirection improvesWhen;

  /// Draws a skeleton where the figure will be.
  final bool loading;

  /// The type scale of the figure and the words around it.
  final PlassSize? size;

  /// The family the icon takes.
  final PlassColor? color;

  /// The space between the three lines, and nothing else.
  final PlassDensity? density;

  /// How the percentage is written when [changeLabel] does not say.
  ///
  /// One decimal at most, and a sign on a rise — `+12.4%`, `-3%`. Written here
  /// rather than through `NumberFormat` because the package has no dependencies;
  /// anything more particular is what `changeLabel` is for.
  static String formatChange(double change) {
    final rounded = (change * 10).roundToDouble() / 10;
    final text = rounded == rounded.roundToDouble()
        ? rounded.toStringAsFixed(0)
        : rounded.toStringAsFixed(1);

    return '${rounded > 0 ? '+' : ''}$text%';
  }

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final color = this.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
    final density = this.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

    final tokens = PlassTheme.of(context);
    final family = tokens.family(color);
    final space = density == PlassDensity.compact ? 2.0 : stackGap[size]!;

    final moved = change != null && change != 0;
    final up = (change ?? 0) > 0;
    // Good news rather than a positive number. The two are the same thing for
    // revenue and the opposite for churn.
    final good = moved && (improvesWhen == PlStatDirection.up ? up : !up);
    final hasChange = change != null || changeLabel != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (label != null || icon != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                ExcludeSemantics(
                  child: IconTheme.merge(
                    data: IconThemeData(color: family.accent, size: metaText[size]! * 1.15),
                    child: icon!,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              if (label != null)
                DefaultTextStyle.merge(
                  style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!),
                  child: label!,
                ),
            ],
          ),
        if (label != null || icon != null) SizedBox(height: space),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (loading)
              PlSkeleton(size: size, color: color, width: _valueSize[size]! * 3)
            else if (value != null)
              // `Flexible`, because a figure long enough to fill its card is a
              // figure that should truncate rather than one that should paint a
              // yellow-and-black overflow bar across the dashboard.
              Flexible(
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    color: tokens.fg,
                    fontWeight: FontWeight.w600,
                    fontSize: _valueSize[size]!,
                    height: 1.1,
                    leadingDistribution: TextLeadingDistribution.even,
                    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                    overflow: TextOverflow.ellipsis,
                  ),
                  child: value!,
                ),
              ),
            if (hasChange && !loading) ...<Widget>[
              const SizedBox(width: 8),
              DefaultTextStyle.merge(
                style: TextStyle(
                  color: !moved
                      ? tokens.mutedFg
                      : good
                      ? tokens.family(PlassColor.success).accent
                      : tokens.family(PlassColor.danger).accent,
                  fontWeight: FontWeight.w500,
                  fontSize: metaText[size]!,
                  fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // The arrow is `aria-hidden`'s equivalent and the sign is in
                    // the text, so colour is never the only thing carrying the
                    // direction.
                    if (moved) ExcludeSemantics(child: Text(up ? '▲' : '▼')),
                    if (moved) const SizedBox(width: 2),
                    changeLabel ?? Text(formatChange(change!)),
                  ],
                ),
              ),
            ],
          ],
        ),
        if (description != null) ...<Widget>[
          SizedBox(height: space),
          DefaultTextStyle.merge(
            style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!),
            child: description!,
          ),
        ],
      ],
    );
  }
}
