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
    this.nulls,
    @Deprecated(
      'Use nulls. connectNulls: true is PlassChartNulls.connect. '
      'Will be removed in 2.0.0.',
    )
    this.connectNulls = false,
    this.valueLabels = PlassChartValueLabels.none,
    this.valueLabelColor = PlassChartLabelColor.series,
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

  /// What a gap in a series does to the line.
  ///
  /// - [PlassChartNulls.gap] — it breaks at the missing value. The default, and
  ///   the only answer that claims nothing the data did not: the blank says the
  ///   reading is missing.
  /// - [PlassChartNulls.connect] — the two sides are joined. Only when the gap
  ///   is an artefact of how the data was collected; otherwise the segment is a
  ///   number the chart made up.
  /// - [PlassChartNulls.zero] — the gap is read as a zero, everywhere: on the
  ///   axis, in the readout and in the table as well as under the line.
  ///
  /// `null` means "not said", which is when the deprecated [connectNulls] is
  /// read instead.
  final PlassChartNulls? nulls;

  /// Draws the line straight through a gap instead of breaking at it.
  ///
  /// Only read when [nulls] says nothing, so a chart that has moved across is
  /// not overruled by a `connectNulls` left behind beside it.
  @Deprecated(
    'Use nulls. connectNulls: true is PlassChartNulls.connect, and nulls also '
    'has the third answer — reading the gap as a zero — which a boolean cannot '
    'express. Will be removed in 2.0.0.',
  )
  final bool connectNulls;

  /// [nulls], with the deprecated boolean read where it says nothing.
  PlassChartNulls get _nulls =>
      nulls ??
      // ignore: deprecated_member_use_from_same_package
      (connectNulls ? PlassChartNulls.connect : PlassChartNulls.gap);

  /// What colour those numbers are written in.
  ///
  /// [PlassChartLabelColor.series] — the default — gives each label the colour
  /// of the line it is sitting on, so a plot with four labelled series says
  /// which number belongs to which without the reader tracing it back.
  /// [PlassChartLabelColor.ink] writes them all in the page's own foreground:
  /// the chart palette clears 4:1 against the sheet, which is the floor a
  /// *mark* is held to rather than the 4.5:1 body text wants, so reach for it
  /// where the labels have to meet the text contrast rule on their own.
  final PlassChartLabelColor valueLabelColor;

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
      // A zeroed gap is a change to the *data*, not to the drawing, which is
      // what lets the axis, the readout and the table all agree that the month
      // was a nought rather than a blank.
      series: _nulls == PlassChartNulls.zero ? zeroNulls(series) : series,
      categories: categories,
      xAxis: xAxis,
      yAxis: yAxis,
      reference: reference,
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
      valueLabelColor: valueLabelColor,
      nulls: _nulls,
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
