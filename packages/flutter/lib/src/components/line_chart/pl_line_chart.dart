/// A value against time, or against anything else with an order to it.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/chart.dart';
import 'package:plass_ui/src/internal/chart_frame.dart';
import 'package:plass_ui/src/internal/chart_line.dart';
import 'package:plass_ui/src/types.dart';

export 'package:plass_ui/src/internal/chart.dart' show PlChartCurve;
export 'package:plass_ui/src/internal/chart_frame.dart'
    show PlChartAxis, PlChartLegend, PlChartTooltip;
export 'package:plass_ui/src/internal/chart_line.dart' show PlChartMarkers;

/// A value against time, or against anything else with an order to it.
///
/// The line is the mark that says *change*: it claims the space between two
/// points is a journey rather than two separate facts, which is true of a
/// temperature and false of four product categories. Reach for a `PlBarChart`
/// when the categories could be shuffled without losing anything.
///
/// Everything around the line — the axes, the grid, the crosshair, the legend,
/// the tooltip and the words a screen reader gets instead of the picture —
/// comes from the shared frame, which is what makes two different charts on one
/// dashboard read as one drawing rather than two.
///
/// ```dart
/// PlLineChart(
///   series: <PlassChartSeries>[
///     PlassChartSeries(
///       name: 'Revenue',
///       data: <PlassChartDatum>[
///         PlassChartDatum(12), PlassChartDatum(19), PlassChartDatum(15),
///       ],
///     ),
///   ],
///   categories: <PlassChartCategory>[
///     PlassChartCategory.text('Jan'),
///     PlassChartCategory.text('Feb'),
///     PlassChartCategory.text('Mar'),
///   ],
/// )
/// ```
class PlLineChart extends StatelessWidget {
  /// Creates a line chart.
  const PlLineChart({
    required this.series,
    this.categories,
    this.curve = PlChartCurve.linear,
    this.markers = PlChartMarkers.auto,
    this.connectNulls = false,
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
    super.key,
  });

  /// The data.
  final List<PlassChartSeries> series;

  /// What the category axis says.
  final List<PlassChartCategory>? categories;

  /// How the line gets from one point to the next.
  ///
  /// [PlChartCurve.linear] is the default and the only one that claims nothing
  /// the data did not say. [PlChartCurve.smooth] is a monotone cubic — curved,
  /// but it will not dip below a value that both of its neighbours are above.
  /// [PlChartCurve.step] is what a rate, a tier or a setting actually did
  /// between two readings, rather than a diagonal pretending it drifted.
  final PlChartCurve curve;

  /// Dots on the points.
  ///
  /// Whatever this says, the point under the pointer always gets one: that is
  /// what tells the reader which column the tooltip is about.
  final PlChartMarkers markers;

  /// Draws the line straight through a gap instead of breaking at it.
  ///
  /// Off, and it should stay off unless the gap is an artefact of how the data
  /// was collected. A bridged gap is a number the chart made up.
  final bool connectNulls;

  /// Which values are written on the line.
  ///
  /// [PlassChartValueLabels.last] is the one to reach for — it names where each
  /// series ended up, which is the question a line chart is usually being
  /// asked.
  final PlassChartValueLabels valueLabels;

  /// The category axis.
  final PlChartAxis xAxis;

  /// The value axis.
  final PlChartAxis yAxis;

  /// The legend.
  final PlChartLegend legend;

  /// The tooltip.
  final PlChartTooltip tooltip;

  /// How tall the plot is. Falls back to the size ladder.
  final double? height;

  /// How a value is written.
  final String Function(double value)? format;

  /// What the whole drawing is called.
  final String? semanticLabel;

  /// What is drawn when there is nothing to draw.
  final Widget? empty;

  /// Type scale, plot height, line weight and marker radius.
  final PlassSize? size;

  @override
  Widget build(BuildContext context) {
    return PlassCartesianChart(
      series: series,
      categories: categories,
      xAxis: xAxis,
      yAxis: yAxis,
      legend: legend,
      tooltip: tooltip,
      height: height,
      format: format,
      semanticLabel: semanticLabel,
      empty: empty,
      size: size,
      // A line sits *on* its category tick, not in the middle of a band — the
      // first point belongs against the axis, not a half-step off it.
      inset: true,
      // The value axis is free to leave zero out here, and a bar chart's is
      // not. What a line encodes is a *position*, so cropping the scale moves
      // every point by the same amount and the shape survives; what a bar
      // encodes is a length, which stops meaning anything the moment it starts
      // from 98.
      includeZero: false,
      headroom: valueLabels == PlassChartValueLabels.none ? 0 : 10,
      paint: _paint,
    );
  }

  void _paint(Canvas canvas, PlassChartLayout layout) {
    paintLineSeries(
      canvas,
      layout,
      curve: curve,
      filled: false,
      stacked: false,
      markers: markers,
      valueLabels: valueLabels,
      connectNulls: connectNulls,
      write: (double value) => format?.call(value) ?? _write(value),
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
