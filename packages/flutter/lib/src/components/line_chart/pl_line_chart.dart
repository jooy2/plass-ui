/// A value against time, or against anything else with an order to it.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/chart.dart';
import 'package:plass_ui/src/internal/chart_frame.dart';
import 'package:plass_ui/src/types.dart';

export 'package:plass_ui/src/internal/chart.dart' show PlChartCurve;
export 'package:plass_ui/src/internal/chart_frame.dart'
    show PlChartAxis, PlChartLegend, PlChartTooltip;

/// Whether a point gets a dot on it.
enum PlChartMarkers {
  /// Never.
  none,

  /// While there are few enough points for a dot to mean something. The
  /// default, and it stops at fourteen.
  auto,

  /// Always.
  all,
}

/// Past this many points a dot per point is a row of dots, not a series.
const int _autoMarkerLimit = 14;

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
    final double width = lineWidths[layout.size]!;
    final double radius = markerRadii[layout.size]!;
    final bool dots =
        markers == PlChartMarkers.all ||
        (markers == PlChartMarkers.auto && layout.count <= _autoMarkerLimit);

    for (int s = 0; s < layout.values.length; s += 1) {
      if (!layout.visible[s]) {
        continue;
      }

      final List<ChartValue> one = layout.values[s];
      final Color color = layout.colors[s];
      // A hovered legend entry is what dims the *others*, not what lights this
      // one: a chart where the hovered series changes colour is a chart whose
      // legend lies for as long as the pointer is on it. And only when the
      // series being hovered is actually on the plot — pointing at an entry
      // that is switched off would otherwise fade every visible series to make
      // room for one that is not there.
      final int? hovered = layout.hovered;
      final double alpha = hovered == null || hovered == s || !layout.visible[hovered] ? 1.0 : 0.25;

      final points = <Offset?>[
        for (int i = 0; i < layout.count; i += 1)
          if (i < one.length && one[i].value != null)
            layout.point(i, one[i].value!)
          else if (connectNulls)
            null
          else
            null,
      ];

      // `connectNulls` drops the gaps rather than marking them, which is what
      // makes the path run straight through.
      final List<Offset?> path = connectNulls
          ? points.where((Offset? point) => point != null).toList()
          : points;

      canvas.drawPath(
        linePath(path, curve),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = color.withValues(alpha: alpha),
      );

      if (!dots && layout.activeIndex == null) {
        continue;
      }

      for (int i = 0; i < layout.count; i += 1) {
        if (i >= one.length || one[i].value == null) {
          continue;
        }

        // Whatever `markers` says, the point under the pointer gets a dot:
        // that is what tells the reader which column the tooltip is about.
        if (!dots && i != layout.activeIndex) {
          continue;
        }

        final Offset at = layout.point(i, one[i].value!);
        final Color ink = one[i].color ?? color;

        canvas
          ..drawCircle(
            at,
            radius + 1.5,
            Paint()..color = layout.tokens.surface.withValues(alpha: alpha),
          )
          ..drawCircle(at, radius, Paint()..color = ink.withValues(alpha: alpha));
      }
    }

    if (valueLabels != PlassChartValueLabels.none) {
      _paintValueLabels(canvas, layout);
    }
  }

  /// The numbers written on the marks.
  ///
  /// Drawn after every line, so a label is never crossed by a series drawn
  /// later — which on a three-series chart is most of them.
  void _paintValueLabels(Canvas canvas, PlassChartLayout layout) {
    final double radius = markerRadii[layout.size]!;
    final double fontSize = chartFontSizes[layout.size]!;

    for (int s = 0; s < layout.values.length; s += 1) {
      if (!layout.visible[s]) {
        continue;
      }

      final List<ChartValue> one = layout.values[s];
      final bool Function(int) labelled = _labelled(one, valueLabels);

      for (int i = 0; i < layout.count && i < one.length; i += 1) {
        final double? value = one[i].value;

        if (value == null || !labelled(i)) {
          continue;
        }

        final Offset at = layout.point(i, value);
        final String text = one[i].label ?? (format?.call(value) ?? _write(value));

        final painter = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: layout.tokens.fg,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        // Anchored inward at the two ends, so the first and last labels are on
        // the plot rather than half off it.
        final double dx = at.dx > layout.plot.right - 24
            ? at.dx - painter.width
            : at.dx < layout.plot.left + 24
            ? at.dx
            : at.dx - painter.width / 2;

        painter.paint(canvas, Offset(dx, at.dy - radius - 5 - painter.height));
      }
    }
  }

  /// Which points of a series get a label, decided once for the whole series.
  ///
  /// Once and not per point, which is the only thing worth saying about it:
  /// asking "is this the last non-null" per point is a scan per point, and the
  /// number of points on a chart being hovered is every frame.
  bool Function(int) _labelled(List<ChartValue> one, PlassChartValueLabels which) {
    if (which == PlassChartValueLabels.all) {
      return (int _) => true;
    }

    if (which == PlassChartValueLabels.last) {
      int last = -1;

      for (int i = one.length - 1; i >= 0; i -= 1) {
        if (one[i].value != null) {
          last = i;
          break;
        }
      }

      return (int index) => index == last;
    }

    // `extremes`. A series that is entirely a gap has no high and no low, and
    // the comparison below is false for every point of it either way.
    double min = double.infinity;
    double max = double.negativeInfinity;

    for (final ChartValue entry in one) {
      if (entry.value == null) {
        continue;
      }

      min = math.min(min, entry.value!);
      max = math.max(max, entry.value!);
    }

    return (int index) {
      final double? value = one[index].value;

      return value != null && (value == min || value == max);
    };
  }

  /// The fallback for a chart that named no format.
  String _write(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }
}
