/// A line with the space under it filled — which changes what the chart is about.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/chart.dart';
import 'package:plass_ui/src/internal/chart_frame.dart';
import 'package:plass_ui/src/internal/chart_line.dart';
import 'package:plass_ui/src/types.dart';

/// How the bands are stacked, if they are.
enum PlAreaStacking {
  /// Not at all. Each band starts from the baseline and they overlap.
  none,

  /// Absolute totals. The top edge is the sum, which is the thing a stacked
  /// area is usually drawn to show.
  total,

  /// Every category normalised to 100%, so the chart is about *share* and stops
  /// being about size. The value axis becomes a percentage and says so.
  full,
}

/// A line with the space under it filled — which changes what the chart is
/// about.
///
/// A line says where a value went. An area says how much of something there
/// was, and stacked it says how that amount was made up. That is the whole test
/// for reaching for this instead of a `PlLineChart`: if the quantity does not
/// add up to anything — a temperature, a rate, a score — the fill under it is
/// decoration, and a chart with two of them is two washes fighting.
///
/// Unstacked bands are a wash fading out downward, so two of them overlapping
/// stay readable. Stacked bands are opaquer, because there the fill *is* the
/// mark rather than a hint at the line above it.
///
/// ```dart
/// PlAreaChart(
///   series: traffic,
///   categories: months,
///   stacking: PlAreaStacking.total,
/// )
/// ```
class PlAreaChart extends StatelessWidget {
  /// Creates an area chart.
  const PlAreaChart({
    required this.series,
    this.categories,
    this.curve = PlChartCurve.linear,
    this.stacking = PlAreaStacking.none,
    this.markers = PlChartMarkers.none,
    this.valueLabels = PlassChartValueLabels.none,
    this.connectNulls = false,
    this.xAxis = const PlChartAxis(),
    this.yAxis = const PlChartAxis(),
    this.legend = const PlChartLegend(),
    this.tooltip = const PlChartTooltip(),
    this.height,
    this.format,
    this.semanticLabel,
    this.empty,
    this.size,
    super.key,
  });

  /// The data.
  final List<PlassChartSeries> series;

  /// What the category axis says.
  final List<PlassChartCategory>? categories;

  /// How the edge of the band gets from one point to the next. The same three
  /// shapes a `PlLineChart` offers, and they mean the same things.
  final PlChartCurve curve;

  /// Whether the bands ride on the totals of those below them.
  ///
  /// A single enum rather than React's `boolean | 'full'`, because Dart has no
  /// union type — and three named states read better than a boolean with an
  /// exception bolted onto it.
  final PlAreaStacking stacking;

  /// Dots on the points.
  ///
  /// [PlChartMarkers.none] by default rather than `auto`: a filled band already
  /// has a visible edge, and a row of dots on it is ink that says nothing the
  /// fill did not.
  final PlChartMarkers markers;

  /// Which values are written on the bands.
  final PlassChartValueLabels valueLabels;

  /// Draws the band straight through a gap instead of breaking at it.
  ///
  /// Off, and on an area it matters more than on a line: a fill that closes
  /// across a missing month paints a made-up number over a larger part of the
  /// chart.
  final bool connectNulls;

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

  /// Type scale, plot height, line weight and marker radius.
  final PlassSize? size;

  bool get _stacked => stacking != PlAreaStacking.none;

  /// The series a full-height stack actually draws.
  ///
  /// 100% stacking is a change to the *data*, not to the drawing: each category
  /// is renormalised to add up to a hundred. Doing it here rather than in the
  /// painter is what lets the axis, the tooltip and the summary all agree that
  /// the number is a share — they read the series they were given.
  List<PlassChartSeries> get _shown {
    if (stacking != PlAreaStacking.full) {
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
                    // The tooltip and the summary keep the number the caller
                    // passed, which is the one they actually have. A
                    // stacked-to-full chart that can only tell you percentages
                    // has thrown the data away.
                    label: values[s][i].label ?? _write(values[s][i].value!),
                  ),
                ),
          ],
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool full = stacking == PlAreaStacking.full;

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
      stacked: _stacked,
      inset: true,
      // Unlike a line, an area's *fill* is its magnitude, so the baseline has to
      // be zero or the band's thickness stops meaning anything.
      includeZero: true,
      headroom: valueLabels == PlassChartValueLabels.none ? 0 : 10,
      paint: (Canvas canvas, PlassChartLayout layout) => paintLineSeries(
        canvas,
        layout,
        curve: curve,
        filled: true,
        stacked: _stacked,
        markers: markers,
        valueLabels: valueLabels,
        connectNulls: connectNulls,
        write: (double value) => format?.call(value) ?? _write(value),
      ),
    );
  }

  /// The fallback for a chart that named no format.
  String _write(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }
}
