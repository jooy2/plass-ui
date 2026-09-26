/// Lengths, compared.
library;

import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/chart.dart';
import 'package:plass_ui/src/internal/chart_frame.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

/// How the series sit relative to each other.
enum PlBarStacking {
  /// Beside each other, sharing the band. Comparing series within a category.
  grouped,

  /// On top of each other. The bar's whole length is the total, and the
  /// segments are what it is made of.
  stacked,

  /// Every bar the same length, so the chart is about share rather than size.
  /// The value axis becomes a percentage.
  full,
}

/// Lengths, compared.
///
/// A bar says *how much*, and it says it by being longer — which is the whole
/// reason its axis starts at zero and cannot be talked out of it. Crop the
/// scale and a bar twice as long stops meaning twice as much, and the reader
/// has no way to know it happened. Reach for a `PlLineChart` when what matters
/// is the shape of a change rather than the size of each value.
///
/// Grouped bars answer "which series is bigger here"; stacked bars answer "what
/// is this total made of". They are different questions and the chart should be
/// asked only one of them at a time.
///
/// ```dart
/// PlBarChart(
///   series: revenue,
///   categories: regions,
///   orientation: PlassOrientation.horizontal,
/// )
/// ```
class PlBarChart extends StatelessWidget {
  /// Creates a bar chart.
  const PlBarChart({
    required this.series,
    this.categories,
    this.orientation = PlassOrientation.vertical,
    this.stacking = PlBarStacking.grouped,
    this.rounded = true,
    this.barSize,
    this.valueLabels = PlassChartValueLabels.none,
    this.valueLabelColor = PlassChartLabelColor.series,
    this.sort = PlassChartSort.none,
    this.maxCategories,
    this.otherLabel,
    this.xAxis = const PlChartAxis(),
    this.yAxis = const PlChartAxis(),
    this.reference = const <PlassChartReference>[],
    this.legend = const PlChartLegend(),
    this.tooltip = const PlChartTooltip(),
    this.height,
    this.format,
    this.semanticLabel,
    this.empty,
    this.size,
    this.density,
    super.key,
  });

  /// The data.
  final List<PlassChartSeries> series;

  /// What the category axis says.
  final List<PlassChartCategory>? categories;

  /// Which way the bars run.
  ///
  /// [PlassOrientation.vertical] grows them up from the bottom, which is what
  /// most people mean by a bar chart. [PlassOrientation.horizontal] grows them
  /// out from the starting edge, and it is the right answer whenever the
  /// category names are words: a horizontal chart has a whole column for them,
  /// and a vertical one has the width of one bar.
  final PlassOrientation orientation;

  /// How the series sit relative to each other.
  final PlBarStacking stacking;

  /// Cuts the corners off the data end of each bar.
  ///
  /// The baseline end stays square — that is where the value starts from, and a
  /// rounded foot makes the axis look scalloped.
  final bool rounded;

  /// How thick a bar may get. Below the cap the bars fill their share of the
  /// band; above it the leftover stays as air.
  final double? barSize;

  /// Which values are written on the bars.
  ///
  /// [PlassChartValueLabels.all] is defensible here in a way it is not on a
  /// line chart: eight bars with their numbers on them is a chart and a table
  /// at once. Past about a dozen it stops being either.
  final PlassChartValueLabels valueLabels;

  /// What colour those numbers are written in.
  ///
  /// [PlassChartLabelColor.series] — the default — gives each label the colour
  /// of the bar it is sitting past, so a group of four labelled bars says which
  /// number belongs to which series without the reader counting along the
  /// group. [PlassChartLabelColor.ink] writes them all in the page's own
  /// foreground: the chart palette clears 4:1 against the sheet, which is the
  /// floor a *mark* is held to rather than the 4.5:1 body text wants, so reach
  /// for it where the labels have to meet the text contrast rule on their own.
  final PlassChartLabelColor valueLabelColor;

  /// Puts the categories in order of size rather than leaving them in the order
  /// they were given.
  ///
  /// A bar chart is the one shape whose categories can be shuffled without
  /// losing anything — that is the test for reaching for it over a line chart —
  /// so sorting them is free, and it is what turns a wall of bars into a
  /// ranking a reader can scan down. Leave it alone where the order already
  /// means something: months, sizes, a funnel's steps.
  ///
  /// With more than one series the size of a category is the **total** across
  /// all of them, and each series' magnitude rather than its signed value — a
  /// category whose two series are +50 and −50 is a hundred units of chart, not
  /// nothing. A series hidden from the legend is still counted, because a chart
  /// whose columns rearranged themselves when an entry was pressed is one a
  /// reader cannot use.
  final PlassChartSort sort;

  /// Keeps the largest this many categories and sums the rest into one.
  ///
  /// The answer to a chart of ninety countries: a bar too short to see is a bar
  /// costing width without saying anything, and eighty of them is a chart of
  /// nothing but noise. What is folded is decided by size and never by [sort],
  /// so [PlassChartSort.ascending] shows the small ones it kept rather than
  /// keeping the small ones — and the fold is always last, wherever the sort
  /// would otherwise have put it, because it is not a category but what is
  /// left.
  ///
  /// A fold of nothing but gaps stays a gap rather than becoming a zero.
  final int? maxCategories;

  /// What that fold is called. Falls back to the label pack's own word, which
  /// is 'Other' in English.
  final String? otherLabel;

  /// The category axis.
  final PlChartAxis xAxis;

  /// The value axis.
  final PlChartAxis yAxis;

  /// Lines drawn across the plot at a value — a target, an average, a limit.
  ///
  /// Not data, and drawn as if they know it: dashed, in the muted ink, under
  /// the marks. They sit on the **value** axis, so one runs across a vertical
  /// chart and down a horizontal one. Each is written into the reading a screen
  /// reader is given with the chart.
  final List<PlassChartReference> reference;

  /// The legend.
  final PlChartLegend legend;

  /// The tooltip.
  final PlChartTooltip tooltip;

  /// How tall the plot is.
  final double? height;

  /// How a value is written.
  final String Function(double value)? format;

  /// What the whole drawing is called.
  final String? semanticLabel;

  /// What is drawn when there is nothing to draw.
  final Widget? empty;

  /// Type scale, plot height and the bar thickness cap.
  final PlassSize? size;

  /// How much of a category's slot the bars in it may take. Never the height.
  final PlassDensity? density;

  bool get _stacked => stacking != PlBarStacking.grouped;

  @override
  Widget build(BuildContext context) {
    final bool full = stacking == PlBarStacking.full;
    final bool horizontal = orientation == PlassOrientation.horizontal;

    /* The order and the fold come first, because a full-length stack has to
       normalise what is actually going to be drawn: a category folded away
       afterwards would have taken its share of every other bar with it. Both
       are changes to the *data*, which is what lets the axis, the readout and
       the reading agree with the picture about which categories there are. */
    final ranked = rankCategories(
      series,
      categories,
      sort: sort,
      max: maxCategories,
      other: otherLabel ?? PlassTheme.labelsOf(context).chartOther,
    );

    final List<PlassChartSeries> shown = full
        ? stackToFull(ranked.series, (double value) => format?.call(value) ?? compactNumber(value))
        : ranked.series;

    return PlassCartesianChart(
      series: shown,
      categories: ranked.categories,
      xAxis: xAxis,
      reference: reference,
      yAxis: full
          ? PlChartAxis(
              hidden: yAxis.hidden,
              label: yAxis.label,
              min: 0,
              max: 100,
              tickCount: yAxis.tickCount,
              scale: yAxis.scale,
              grid: yAxis.grid,
              thickness: yAxis.thickness,
              format: yAxis.format ?? (double value) => '${value.toInt()}%',
            )
          : yAxis,
      legend: legend,
      tooltip: tooltip,
      height: height,
      format: format,
      semanticLabel: semanticLabel,
      empty: empty,
      size: size,
      density: density,
      stacked: _stacked,
      horizontal: horizontal,
      // A bar's length is its value, so zero is not optional.
      includeZero: true,
      headroom: valueLabels == PlassChartValueLabels.none ? 0 : 12,
      paint: _paint,
    );
  }

  /// The bars themselves, and the only part of a bar chart that is not the
  /// shared frame.
  ///
  /// Two arrangements out of one loop: grouped bars split the band between the
  /// visible series, stacked ones take the whole band and are pushed along by
  /// whatever came before them. In both, the gap between two touching marks is
  /// the sheet showing through and never a stroke — a border drawn around a bar
  /// is ink that is not data.
  void _paint(Canvas canvas, PlassChartLayout layout) {
    final drawn = <int>[
      for (int i = 0; i < layout.values.length; i += 1)
        if (layout.visible[i]) i,
    ];
    final int lanes = _stacked ? 1 : math.max(1, drawn.length);
    final double cap = barSize ?? barMaxThickness[layout.size]!;
    final double laneWidth = math.min(
      cap,
      math.max(1, (layout.band.band - markGap * (lanes - 1)) / lanes),
    );
    final double groupWidth = laneWidth * lanes + markGap * (lanes - 1);
    final double radius = rounded ? (_stacked ? barRadius / 2 : barRadius) : 0;

    // Where each stacked segment starts, kept per category and per sign: a
    // negative segment grows down from zero while the positives grow up, or a
    // series that dips takes a bite out of the one above it.
    final positive = <int, double>{};
    final negative = <int, double>{};

    for (int lane = 0; lane < drawn.length; lane += 1) {
      final int s = drawn[lane];
      final List<ChartValue> one = layout.values[s];
      // Faded while the legend points at another series, and eased there.
      final double alpha = layout.seriesOpacity(s);
      final bool Function(int) labelled = labelledPoints(one, valueLabels);

      for (int category = 0; category < layout.count && category < one.length; category += 1) {
        final double? value = one[category].value;

        if (value == null) {
          continue;
        }

        final double centre = layout.categoryPx(category);
        final double offset = _stacked
            ? 0
            : lane * (laneWidth + markGap) - groupWidth / 2 + laneWidth / 2;

        final double base = _stacked
            ? (value >= 0 ? (positive[category] ?? 0) : (negative[category] ?? 0))
            : 0;
        final double from = layout.valuePx(base);
        final double to = layout.valuePx(base + value);

        if (_stacked) {
          if (value >= 0) {
            positive[category] = base + value;
          } else {
            negative[category] = base + value;
          }
        }

        // The gap between two stacked segments is taken off the far end of
        // each, so the stack still totals the right length and the seam is the
        // sheet rather than a line drawn on it.
        final double shrink = _stacked && base != 0 ? markGap : 0;
        final double length = (to - from).abs() - shrink;

        if (length <= 0) {
          continue;
        }

        final bool grows = to < from;
        final double start = math.min(from, to) + (grows ? 0 : shrink);
        final Color ink = one[category].color ?? layout.colors[s];

        final Path path = layout.horizontal
            ? barPath(
                start,
                layout.plot.top + centre + offset - laneWidth / 2,
                length,
                laneWidth,
                radius,
                value >= 0 ? PlBarEnd.right : PlBarEnd.left,
              )
            : barPath(
                layout.plot.left + centre + offset - laneWidth / 2,
                start,
                laneWidth,
                length,
                radius,
                value >= 0 ? PlBarEnd.up : PlBarEnd.down,
              );

        // A shade under whole until the crosshair reaches the column, and
        // eased up to it and back.
        canvas.drawPath(
          path,
          Paint()
            ..color = ink.withValues(
              alpha: lerpDouble(0.92, 1, layout.columnLit(category))! * alpha,
            ),
        );

        if (labelled(category)) {
          _paintLabel(canvas, layout, one[category], value, to, centre + offset, ink);
        }
      }
    }

    // The baseline, redrawn over the bars. Every bar starts here and the line is
    // what says so; under them it is half-hidden by the first pixel of each one.
    final double zero = layout.zeroPx;

    canvas.drawLine(
      layout.horizontal ? Offset(zero, layout.plot.top) : Offset(layout.plot.left, zero),
      layout.horizontal ? Offset(zero, layout.plot.bottom) : Offset(layout.plot.right, zero),
      Paint()
        ..color = layout.tokens.chartBaseline
        ..strokeWidth = 1,
    );
  }

  /// A number written just past a bar's data end, on the outside.
  ///
  /// Kept at the end rather than inside the fill so it never has to be white on
  /// one bar and ink on the next — and written in [ink], the bar's own colour,
  /// so a group of four labelled bars says which number belongs to which series
  /// without the reader counting along the group. [valueLabelColor] is what
  /// takes that back to the page's own foreground.
  void _paintLabel(
    Canvas canvas,
    PlassChartLayout layout,
    ChartValue entry,
    double value,
    double to,
    double across,
    Color ink,
  ) {
    final double fontSize = chartFontSizes[layout.size]!;
    final painter = TextPainter(
      text: TextSpan(
        text: entry.label ?? (format?.call(value) ?? compactNumber(value)),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: valueLabelColor == PlassChartLabelColor.ink ? layout.tokens.fg : ink,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final Offset at = layout.horizontal
        ? Offset(
            value >= 0 ? to + 5 : to - 5 - painter.width,
            layout.plot.top + across - painter.height / 2,
          )
        : Offset(
            layout.plot.left + across - painter.width / 2,
            value >= 0 ? to - 5 - painter.height : to + 5,
          );

    painter.paint(canvas, at);
  }

  /// The fallback for a chart that named no format.
}
