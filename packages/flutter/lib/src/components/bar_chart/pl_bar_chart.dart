/// Lengths, compared.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/chart.dart';
import 'package:plass_ui/src/internal/chart_frame.dart';
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
    this.xAxis = const PlChartAxis(),
    this.yAxis = const PlChartAxis(),
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

  /// The category axis.
  final PlChartAxis xAxis;

  /// The value axis.
  final PlChartAxis yAxis;

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

  /// The series a full-length stack actually draws.
  ///
  /// 100% stacking renormalises the data before anything is drawn, so the axis,
  /// the tooltip and the summary all agree about what the number is. The
  /// original value survives as the point's label — a chart that can only tell
  /// you percentages has thrown away what it was given.
  List<PlassChartSeries> get _shown {
    if (stacking != PlBarStacking.full) {
      return series;
    }

    final List<List<ChartValue>> values = toValues(series);
    final totals = <int, double>{};

    for (final List<ChartValue> one in values) {
      for (int i = 0; i < one.length; i += 1) {
        totals[i] = (totals[i] ?? 0) + (one[i].value ?? 0).abs();
      }
    }

    return <PlassChartSeries>[
      for (int s = 0; s < series.length; s += 1)
        PlassChartSeries(
          id: series[s].id,
          name: series[s].name,
          color: series[s].color,
          dashed: series[s].dashed,
          hidden: series[s].hidden,
          data: <PlassChartDatum>[
            for (int i = 0; i < values[s].length; i += 1)
              if (values[s][i].value == null)
                const PlassChartDatum.gap()
              else
                PlassChartDatum.point(
                  PlassChartPoint(
                    x: values[s][i].x,
                    y: (totals[i] ?? 0) == 0 ? 0 : values[s][i].value! / totals[i]! * 100,
                    color: values[s][i].color,
                    label: values[s][i].label ?? _write(values[s][i].value!),
                  ),
                ),
          ],
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool full = stacking == PlBarStacking.full;
    final bool horizontal = orientation == PlassOrientation.horizontal;

    return PlassCartesianChart(
      series: _shown,
      categories: categories,
      xAxis: xAxis,
      yAxis: full
          ? PlChartAxis(
              hidden: yAxis.hidden,
              label: yAxis.label,
              min: 0,
              max: 100,
              tickCount: yAxis.tickCount,
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
      final int? hovered = layout.hovered;
      final double alpha = hovered == null || hovered == s || !layout.visible[hovered] ? 1.0 : 0.28;

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

        canvas.drawPath(
          path,
          Paint()
            ..color = ink.withValues(alpha: (category == layout.activeIndex ? 1 : 0.92) * alpha),
        );

        if (valueLabels != PlassChartValueLabels.none && _labelled(one, category)) {
          _paintLabel(canvas, layout, one[category], value, to, centre + offset);
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
  /// one bar and ink on the next.
  void _paintLabel(
    Canvas canvas,
    PlassChartLayout layout,
    ChartValue entry,
    double value,
    double to,
    double across,
  ) {
    final double fontSize = chartFontSizes[layout.size]!;
    final painter = TextPainter(
      text: TextSpan(
        text: entry.label ?? (format?.call(value) ?? _write(value)),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: layout.tokens.fg,
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

  /// Whether this bar gets a number on it.
  bool _labelled(List<ChartValue> one, int index) {
    switch (valueLabels) {
      case PlassChartValueLabels.none:
        return false;
      case PlassChartValueLabels.all:
        return true;
      case PlassChartValueLabels.last:
        return index == one.length - 1;
      case PlassChartValueLabels.extremes:
        final double? value = one[index].value;

        if (value == null) {
          return false;
        }

        double min = double.infinity;
        double max = double.negativeInfinity;

        for (final ChartValue entry in one) {
          if (entry.value == null) {
            continue;
          }

          min = math.min(min, entry.value!);
          max = math.max(max, entry.value!);
        }

        return value == min || value == max;
    }
  }

  /// The fallback for a chart that named no format.
  String _write(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }
}
