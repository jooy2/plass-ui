/// A chart with everything taken away except the shape.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/chart.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

/// Which mark a sparkline is drawn with.
enum PlSparklineShape {
  /// A trend.
  line,

  /// A quantity.
  area,

  /// A count of discrete things.
  bar,
}

/// A chart with everything taken away except the shape.
///
/// No axes, no grid, no legend, no readout — it is not a small chart, it is a
/// different thing: a word-sized picture that goes inside a sentence, beside a
/// `PlStat`, or in a table cell, and says which way something has been going.
/// Every number it could label is one the surrounding text already has, which
/// is why it labels none of them.
///
/// It scales itself to its own range, so the strip is always full. That is what
/// makes it readable this small and it is also the trap: two sparklines side by
/// side are drawn on two different scales unless they are given the same [min]
/// and [max].
///
/// ```dart
/// PlSparkline(
///   data: const <PlassChartDatum>[
///     PlassChartDatum(12),
///     PlassChartDatum(19),
///     PlassChartDatum(15),
///   ],
///   endDot: true,
/// )
/// ```
class PlSparkline extends StatelessWidget {
  /// Creates a sparkline.
  const PlSparkline({
    required this.data,
    this.shape = PlSparklineShape.line,
    this.curve = PlChartCurve.linear,
    this.size,
    this.color,
    this.tint,
    this.endDot = false,
    this.baseline,
    this.min,
    this.max,
    this.width,
    this.semanticLabel,
    super.key,
  });

  /// The values. A gap is a gap here too, and the line breaks at it.
  final List<PlassChartDatum> data;

  /// Which mark.
  final PlSparklineShape shape;

  /// How the line gets from one point to the next.
  final PlChartCurve curve;

  /// How tall the strip is. Sized against the line of text it sits beside
  /// rather than against the page.
  final PlassSize? size;

  /// The mark's colour family.
  ///
  /// A sparkline has exactly one series and no legend, so there is nothing for
  /// a palette to hand out and the colour is named directly. Left out, it is
  /// the first chart slot.
  final PlassColor? color;

  /// An exact colour, for a strip that is not one of the families.
  ///
  /// Two props where React takes `PlassColor | (string & {})`, because Dart has
  /// no union: [color] names a family and this names a [Color].
  final Color? tint;

  /// Puts a dot on the last point — the one direct label a strip this small has
  /// room for.
  final bool endDot;

  /// Draws a rule across the strip at this value: a target, a budget, last
  /// year's average.
  final double? baseline;

  /// The bottom of the scale, when a row of strips has to share one.
  final double? min;

  /// And the top of it.
  final double? max;

  /// How wide. Fills its container by default.
  final double? width;

  /// A name for the strip, read out in place of it.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final PlassSize step = size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final double height = sparklineHeights[step]!;

    final List<ChartValue> values = toValues(<PlassChartSeries>[
      PlassChartSeries(data: data),
    ]).first;

    final Color paint = tint ?? (color == null ? tokens.chart.first : tokens.family(color!).accent);

    final Widget strip = SizedBox(
      width: width,
      height: height,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double measured =
              width ?? (constraints.maxWidth.isFinite ? constraints.maxWidth : height * 4);

          if (measured <= 0 || values.isEmpty) {
            return const SizedBox.shrink();
          }

          return CustomPaint(
            size: Size(measured, height),
            painter: _SparklinePainter(
              values: values,
              shape: shape,
              curve: curve,
              step: step,
              ink: paint,
              endDot: endDot,
              baseline: baseline,
              min: min,
              max: max,
              gap: tokens.surface,
              rule: tokens.chartBaseline,
            ),
          );
        },
      ),
    );

    if (semanticLabel == null) {
      return ExcludeSemantics(child: strip);
    }

    // The numbers, for the readers the strip does not reach. A sparkline is a
    // picture of a trend and nothing else, so what it owes is the values — not
    // a description of the shape they happen to make.
    return Semantics(
      label: semanticLabel,
      value: values
          .map((ChartValue one) => one.value == null ? '—' : _write(one.value!))
          .join(', '),
      excludeSemantics: true,
      child: strip,
    );
  }

  String _write(double value) => value == value.roundToDouble() && value.abs() < 1e15
      ? value.toInt().toString()
      : value.toStringAsFixed(2);
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({
    required this.values,
    required this.shape,
    required this.curve,
    required this.step,
    required this.ink,
    required this.endDot,
    required this.baseline,
    required this.min,
    required this.max,
    required this.gap,
    required this.rule,
  });

  final List<ChartValue> values;
  final PlSparklineShape shape;
  final PlChartCurve curve;
  final PlassSize step;
  final Color ink;
  final bool endDot;
  final double? baseline;
  final double? min;
  final double? max;
  final Color gap;
  final Color rule;

  @override
  void paint(Canvas canvas, Size size) {
    final double stroke = lineWidths[step]!;
    final double radius = markerRadii[step]!;

    final ChartExtent? extent = extentOf(<List<ChartValue>>[values], stacked: false);
    final double low = min ?? (extent == null ? 0 : math.min(extent.min, baseline ?? extent.min));
    final double high = max ?? (extent == null ? 1 : math.max(extent.max, baseline ?? extent.max));
    final double span = high - low == 0 ? 1 : high - low;

    // The stroke straddles the path, so the drawable band comes in by half of
    // it at both ends — otherwise the highest and lowest points are shaved off
    // by the edge of the box.
    final double inset = shape == PlSparklineShape.bar ? 0 : stroke / 2 + (endDot ? radius : 0);
    final double usable = math.max(1, size.height - inset * 2);

    double y(double value) => inset + (1 - (value - low) / span) * usable;

    final double across = values.length > 1 ? size.width / (values.length - 1) : size.width;
    final List<Offset?> points = <Offset?>[
      for (int i = 0; i < values.length; i += 1)
        if (values[i].value == null) null else Offset(i * across, y(values[i].value!)),
    ];

    /* The strip's own height, and room to either side. A value outside a
       pinned `min` or `max` is cut at the edge rather than drawn past it — a
       bar for 2 under a `min` of 5 is not seen at all. Only the height is held:
       the round ends of the line are meant to reach past the two sides, and a
       range left to itself never reaches past the top or the bottom, so nothing
       inside it is cut. */
    canvas
      ..save()
      ..clipRect(Rect.fromLTRB(-size.width, 0, size.width * 2, size.height));

    _paintMarks(canvas, size, points, y, low, high, stroke);

    canvas.restore();

    if (!endDot || shape == PlSparklineShape.bar) {
      return;
    }

    // Outside the cut, because its ring may reach a pixel past the strip at its
    // extremes and that pixel is not a value; the value itself is held to the
    // strip here. A last value outside a pinned end is cut away with the rest,
    // and a dot left standing past the edge would be the one part of it seen.
    for (int i = points.length - 1; i >= 0; i -= 1) {
      final Offset? last = points[i];

      if (last == null) {
        continue;
      }

      final double value = values[i].value!;

      if (value >= low && value <= high) {
        canvas
          ..drawCircle(last, radius + markGap, Paint()..color = gap)
          ..drawCircle(last, radius, Paint()..color = ink);
      }

      return;
    }
  }

  /// The area, the baseline and the line or the bars, inside the cut.
  void _paintMarks(
    Canvas canvas,
    Size size,
    List<Offset?> points,
    double Function(double value) y,
    double low,
    double high,
    double stroke,
  ) {
    if (shape == PlSparklineShape.area) {
      canvas.drawPath(
        areaPath(points, <Offset?>[
          for (final Offset? point in points)
            if (point == null) null else Offset(point.dx, size.height),
        ], curve),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[ink.withValues(alpha: 0.32), ink.withValues(alpha: 0.02)],
          ).createShader(Offset.zero & size),
      );
    }

    if (baseline != null) {
      canvas.drawLine(
        Offset(0, y(baseline!)),
        Offset(size.width, y(baseline!)),
        Paint()
          ..color = rule
          ..strokeWidth = 1,
      );
    }

    if (shape == PlSparklineShape.bar) {
      final double slot = size.width / math.max(1, values.length);
      final double thick = math.min(barMaxThickness[step]! / 2, math.max(1, slot - markGap));
      // Where a bar grows from: zero, or the end of the scale nearest zero when
      // the whole scale is on one side of it, so bars that are all below zero
      // hang from the top of the strip instead of from a zero above it.
      final double foot = y(math.min(math.max(low, 0), high));

      for (int i = 0; i < values.length; i += 1) {
        final double? value = values[i].value;

        if (value == null) {
          continue;
        }

        // A value at the foot is still drawn a pixel tall, and that pixel stays
        // inside the strip: below the foot, or above it when the foot is the
        // bottom edge, as it is under the lowest value of a series above zero.
        final double rise = (y(value) - foot).abs();
        final double top = rise < 1
            ? math.min(math.min(y(value), foot), size.height - 1)
            : math.min(y(value), foot);

        canvas.drawPath(
          barPath(
            i * slot + (slot - thick) / 2,
            top,
            thick,
            math.max(1, rise),
            barRadius / 2,
            value >= 0 ? PlBarEnd.up : PlBarEnd.down,
          ),
          Paint()..color = values[i].color ?? ink,
        );
      }

      return;
    }

    canvas.drawPath(
      linePath(points, curve),
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.values != values ||
      old.shape != shape ||
      old.curve != curve ||
      old.step != step ||
      old.ink != ink ||
      old.endDot != endDot ||
      old.baseline != baseline ||
      old.min != min ||
      old.max != max ||
      old.gap != gap ||
      old.rule != rule;
}
