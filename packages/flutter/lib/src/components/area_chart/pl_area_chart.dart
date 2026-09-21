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
    this.valueLabelColor = PlassChartLabelColor.series,
    this.nulls,
    @Deprecated(
      'Use nulls. connectNulls: true is PlassChartNulls.connect. '
      'Will be removed in 2.0.0.',
    )
    this.connectNulls = false,
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

  /// What colour those numbers are written in.
  ///
  /// [PlassChartLabelColor.series] — the default — gives each label the colour
  /// of the band it is sitting on, so a plot with four labelled series says
  /// which number belongs to which without the reader tracing it back.
  /// [PlassChartLabelColor.ink] writes them all in the page's own foreground:
  /// the chart palette clears 4:1 against the sheet, which is the floor a
  /// *mark* is held to rather than the 4.5:1 body text wants, so reach for it
  /// where the labels have to meet the text contrast rule on their own.
  final PlassChartLabelColor valueLabelColor;

  /// Which values are written on the bands.
  final PlassChartValueLabels valueLabels;

  /// What a gap in a series does to the band.
  ///
  /// - [PlassChartNulls.gap] — it breaks at the missing value. The default, and
  ///   the only answer that claims nothing the data did not. It matters more on
  ///   an area than on a line: a fill that closes across a missing month paints
  ///   the made-up number over a larger part of the chart.
  /// - [PlassChartNulls.connect] — the two sides are joined. Only when the gap
  ///   is an artefact of how the data was collected.
  /// - [PlassChartNulls.zero] — the gap is read as a zero, everywhere: on the
  ///   axis, in the readout and in the table as well as under the band.
  ///
  /// `null` means "not said", which is when the deprecated [connectNulls] is
  /// read instead.
  final PlassChartNulls? nulls;

  /// Draws the band straight through a gap instead of breaking at it.
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

  /// Type scale, plot height, line weight and marker radius.
  final PlassSize? size;

  bool get _stacked => stacking != PlAreaStacking.none;

  /// The series the chart actually draws.
  ///
  /// A zeroed gap first, so a band normalised to 100% counts the nought as a
  /// nought rather than dropping the category out of its own total. Both are
  /// changes to the *data* for the same reason: the axis, the readout and the
  /// table all read the series they were given. The React build works the
  /// second half out with the same `stackToFull`.
  List<PlassChartSeries> get _shown {
    final List<PlassChartSeries> data = _nulls == PlassChartNulls.zero ? zeroNulls(series) : series;

    return stacking == PlAreaStacking.full
        ? stackToFull(data, (double value) => format?.call(value) ?? compactNumber(value))
        : data;
  }

  @override
  Widget build(BuildContext context) {
    final bool full = stacking == PlAreaStacking.full;

    return PlassCartesianChart(
      series: _shown,
      categories: categories,
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
        valueLabelColor: valueLabelColor,
        nulls: _nulls,
        write: (double value) => format?.call(value) ?? compactNumber(value),
      ),
    );
  }

  /// The fallback for a chart that named no format.
}
