/// Two numbers per point, and whether they move together.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/chart.dart';
import 'package:plass_ui/src/internal/chart_frame.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

/// How many series the palette can tell apart on a plot where any two marks may
/// end up side by side.
///
/// Measured against this library's own eight slots rather than assumed. A
/// scatter has no reading order, so every pair has to clear the colour-vision
/// check and not only the pairs that happen to touch — and run that way the
/// palette separates three. Taking the first three, the closest pair under
/// deuteranopia is ΔE 64 on the light sheet and 51 on the dark one; add the
/// fourth and those fall to 4.9 and 2.8, which is no difference at all.
const int _separableSeries = 3;

/// Nothing smaller than this, or a small-but-real value disappears.
const double _minBubble = 2;

/// What each mark is drawn as.
///
/// One enum where React takes `MarkShape | 'varied' | 'auto'`, because Dart has
/// no union to flatten: the two policies and the five shapes are the same
/// choice made once.
enum PlScatterShape {
  /// A circle while colour alone can carry identity, and a shape per series
  /// from the fourth on. The default.
  auto,

  /// A shape per series always, in the fixed order below. Reach for it when the
  /// chart will be printed or read in greyscale.
  varied,

  /// Every mark a circle.
  circle,

  /// Every mark a square.
  square,

  /// Every mark a triangle.
  triangle,

  /// Every mark a diamond.
  diamond,

  /// Every mark a cross.
  cross,
}

/// Two numbers per point, and whether they move together.
///
/// Both axes measure, which is what makes this the only chart in the library
/// with no categories: there is no column a mark belongs to and no order the
/// points could be shuffled out of. A point with a `z` is drawn as a bubble and
/// one without it as a dot, so a scatter and a bubble chart are the same widget
/// reading the same data — the third number is simply present or not.
///
/// `x` must be a number or a date. Text has no place on a number line, and a
/// chart of named things against one measure is a `PlBarChart`.
///
/// ```dart
/// PlScatterChart(
///   series: <PlassChartSeries>[
///     PlassChartSeries(name: 'Q1', data: readings),
///   ],
///   xAxis: const PlChartAxis(label: 'Spend'),
///   yAxis: const PlChartAxis(label: 'Revenue'),
/// )
/// ```
class PlScatterChart extends StatelessWidget {
  /// Creates a scatter chart.
  const PlScatterChart({
    required this.series,
    this.categories,
    this.shape = PlScatterShape.auto,
    this.pointRadius,
    this.maxRadius,
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

  /// The data. Every point needs an `x`, or an index stands in for one.
  final List<PlassChartSeries> series;

  /// What the points sit against, when they do not carry their own `x`.
  final List<PlassChartCategory>? categories;

  /// What each mark is drawn as.
  final PlScatterShape shape;

  /// The radius of a mark with no `z`, in pixels. Falls back to the size
  /// ladder.
  final double? pointRadius;

  /// The radius of the largest bubble, in pixels. Everything else is scaled
  /// under it by area. Falls back to a twelfth of the chart's height.
  final double? maxRadius;

  /// The x axis, which measures here rather than naming.
  final PlChartAxis xAxis;

  /// The value axis.
  final PlChartAxis yAxis;

  /// The legend.
  final PlChartLegend legend;

  /// The readout under the pointer.
  final PlChartTooltip tooltip;

  /// How tall the plot is.
  final double? height;

  /// How a value is written.
  final String Function(double value)? format;

  /// What the whole drawing is called.
  final String? semanticLabel;

  /// What is drawn when there is nothing to draw.
  final Widget? empty;

  /// Type scale, plot height and the default mark radius.
  final PlassSize? size;

  String _write(double value) {
    if (format != null) {
      return format!(value);
    }

    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final PlassSize step = size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final double dot = pointRadius ?? markerRadii[step]!;

    // Unpacked once and closed over. The readout runs on every frame the
    // pointer moves, and unpacking the whole chart to answer "what is this one
    // dot" would be the series walked again per frame.
    final List<List<ChartValue>> values = toValues(series);

    /* How much room the biggest mark needs, which is also how big it is allowed
       to get. One number for both, and measured off the chart's *height* rather
       than off the laid-out plot, because the two would otherwise chase each
       other: the plot is only that size once the room has been taken out of it.
       The height is known before anything is measured, which breaks the loop
       and makes the reserve exactly the radius rather than a guess at it. */
    final double reserve = maxRadius ?? math.max(dot + 2, (height ?? plotHeights[step]!) / 12);

    /* Only the series taking a palette slot count against the ceiling: a caller
       who gave every series a colour of their own has already answered the
       question the ceiling exists to ask. */
    int palettes = 0;

    for (final PlassChartSeries one in series) {
      if (one.color == null) {
        palettes += 1;
      }
    }

    final bool varied =
        shape == PlScatterShape.varied ||
        (shape == PlScatterShape.auto && palettes > _separableSeries);

    // By its place in the list it was passed, exactly as the colour is, so
    // hiding a series from the legend cannot reshape the ones that are left.
    PlChartMarkShape shapeOf(int index) => varied
        ? markShapes[index % markShapes.length]
        : switch (shape) {
            PlScatterShape.square => PlChartMarkShape.square,
            PlScatterShape.triangle => PlChartMarkShape.triangle,
            PlScatterShape.diamond => PlChartMarkShape.diamond,
            PlScatterShape.cross => PlChartMarkShape.cross,
            _ => PlChartMarkShape.circle,
          };

    List<PlassChartMark> marks(PlassChartLayout layout) {
      final list = <PlassChartMark>[];

      /* One `z` scale for the whole chart rather than one per series, and taken
         over every series rather than the visible ones. Two bubbles the same
         size have to mean the same number wherever they are, and a size that
         changes when a legend is pressed is the same broken promise as a colour
         that does. */
      double biggest = 0;

      for (final List<ChartValue> one in layout.values) {
        for (final ChartValue value in one) {
          final double? z = value.z;

          if (value.value != null && z != null && !z.isNaN && !z.isInfinite) {
            biggest = math.max(biggest, z);
          }
        }
      }

      for (int i = 0; i < layout.values.length; i += 1) {
        if (!layout.visible[i]) {
          continue;
        }

        final List<ChartValue> one = layout.values[i];

        for (int at = 0; at < one.length; at += 1) {
          final double? y = one[at].value;

          if (y == null) {
            continue;
          }

          final double? x = pointX(one[at], at, categories);

          if (x == null) {
            continue;
          }

          list.add(
            PlassChartMark(
              series: i,
              index: at,
              centre: Offset(layout.categoryValuePx(x), layout.valuePx(y)),
              r: one[at].z == null ? dot : bubbleRadius(one[at].z!, biggest, reserve, _minBubble),
            ),
          );
        }
      }

      return list;
    }

    return PlassCartesianChart(
      series: series,
      categories: categories,
      xScale: PlassChartAxisScale.value,
      xAxis: xAxis,
      yAxis: yAxis,
      legend: legend,
      tooltip: tooltip,
      height: height,
      format: format,
      semanticLabel: semanticLabel,
      empty: empty,
      size: size,
      marks: marks,
      markInset: reserve,
      // Neither axis is forced to zero. What a position encodes is a *place*,
      // so cropping a scale slides every mark by the same amount and the shape
      // of the cloud — which is the whole of what a scatter says — survives. A
      // bar's length is the case where that is not true, and this is not one.
      includeZero: false,
      swatch: (int index, Color color) => SizedBox(
        width: 10,
        height: 10,
        child: CustomPaint(painter: _SwatchPainter(shapeOf(index), color)),
      ),
      markReadout: (PlassChartMark mark) => _readout(values[mark.series][mark.index], mark.index),
      semanticValue: () => _summary(values),
      paint: (Canvas canvas, PlassChartLayout layout) => _paint(canvas, layout, shapeOf),
    );
  }

  /// What one point is worth, as the tooltip and the reader both hear it.
  String _readout(ChartValue value, int index) {
    final double? x = pointX(value, index, categories);
    final String pair = '${x == null ? '' : '${_write(x)}, '}${_write(value.value ?? 0)}';

    return value.z == null ? pair : '$pair (${_write(value.z!)})';
  }

  /// Every point, because a cloud has no "where it ended up".
  String _summary(List<List<ChartValue>> values) {
    final parts = <String>[];

    for (int i = 0; i < values.length; i += 1) {
      if (series[i].hidden) {
        continue;
      }

      final name = series[i].name ?? 'Series ${i + 1}';
      final points = <String>[];

      for (int at = 0; at < values[i].length; at += 1) {
        final double? y = values[i][at].value;

        if (y == null) {
          continue;
        }

        final double? x = pointX(values[i][at], at, categories);

        points.add('${x == null ? '' : '${_write(x)}, '}${_write(y)}');
      }

      parts.add('$name: ${points.join('; ')}');
    }

    return parts.join('. ');
  }

  /// The marks, painted largest first.
  ///
  /// Which is the whole of what keeps a bubble chart readable: a small bubble
  /// sitting inside a big one is invisible if the big one is drawn on top of
  /// it, and the usual fix — dropping every fill to half alpha — would undo the
  /// contrast the palette was solved for. Paint order costs nothing and takes
  /// nothing away.
  void _paint(Canvas canvas, PlassChartLayout layout, PlChartMarkShape Function(int) shapeOf) {
    final List<PlassChartMark> painted = List<PlassChartMark>.from(layout.marks)
      ..sort((PlassChartMark a, PlassChartMark b) => b.r.compareTo(a.r));

    for (final PlassChartMark mark in painted) {
      final ChartValue value = layout.values[mark.series][mark.index];
      final bool dimmed = layout.hovered != null && layout.hovered != mark.series;
      final bool active =
          layout.activeMark?.series == mark.series && layout.activeMark?.index == mark.index;
      final double r = active && mark.r > 0 ? mark.r + 1 : mark.r;
      final Path path = markPath(shapeOf(mark.series), mark.centre.dx, mark.centre.dy, r);

      // The ring is the surface showing through, not a stroke drawn around the
      // mark — which is what keeps two overlapping dots two dots.
      canvas
        ..drawPath(
          path,
          Paint()
            ..color = layout.tokens.surface
            ..style = PaintingStyle.stroke
            ..strokeWidth = markGap * 2,
        )
        ..drawPath(
          path,
          Paint()
            ..color = (value.color ?? layout.colors[mark.series]).withValues(
              alpha: dimmed ? 0.28 : 1,
            ),
        );
    }
  }
}

/// One mark's shape, drawn small enough to sit beside a word.
class _SwatchPainter extends CustomPainter {
  const _SwatchPainter(this.shape, this.color);

  final PlChartMarkShape shape;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      markPath(shape, size.width / 2, size.height / 2, size.width * 0.4),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_SwatchPainter old) => old.shape != shape || old.color != color;
}
