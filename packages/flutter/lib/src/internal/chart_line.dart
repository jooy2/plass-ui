/// The marks a [PlLineChart] and a [PlAreaChart] draw.
///
/// They are one picture with one part switched off, which is exactly the case
/// `internal/` exists for: an area is a line with the space under it filled,
/// and a stacked area is that with each band sitting on the one below. Writing
/// the path arithmetic twice would mean a `smooth` that curves differently
/// depending on which of the two widgets a caller reached for.
///
/// A sparkline deliberately does *not* come through here. It has no axes, no
/// legend and no stacking, and what it needs from `internal/chart.dart` is two
/// calls — routing it through a painter built for a full plot would cost it the
/// thing that makes it a sparkline.
///
/// It is not exported from `plass_ui.dart`.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/chart.dart';
import 'package:plass_ui/src/internal/chart_frame.dart';
import 'package:plass_ui/src/types.dart';

/// Whether a point gets a dot on it.
enum PlChartMarkers {
  /// Never.
  none,

  /// While there are few enough points for a dot to mean something. Stops at
  /// fourteen.
  auto,

  /// Always.
  all,
}

/// Past this many points a dot per point is a row of dots, not a series.
const int _autoMarkerLimit = 14;

/// Draws the lines, the bands, the markers and the value labels.
///
/// One function rather than a widget, because what the frame hands out is a
/// `Canvas` and everything here is paint. The two charts that call it differ by
/// three booleans.
void paintLineSeries(
  Canvas canvas,
  PlassChartLayout layout, {
  required PlChartCurve curve,
  required bool filled,
  required bool stacked,
  required PlChartMarkers markers,
  required PlassChartValueLabels valueLabels,
  required bool connectNulls,
  required String Function(double value) write,
}) {
  final double stroke = lineWidths[layout.size]!;
  final double radius = markerRadii[layout.size]!;
  final bool dots =
      markers == PlChartMarkers.all ||
      (markers == PlChartMarkers.auto && layout.count <= _autoMarkerLimit);

  // The running total each band sits on. Only the visible series contribute:
  // hiding one from the legend has to close the gap it left, or a stacked chart
  // with a series turned off reads as a chart with a hole in it.
  final baselines = <List<double>>[];
  final running = <int, double>{};

  for (int s = 0; s < layout.values.length; s += 1) {
    final List<ChartValue> one = layout.values[s];

    baselines.add(<double>[for (int i = 0; i < one.length; i += 1) running[i] ?? 0]);

    if (!stacked || !layout.visible[s]) {
      continue;
    }

    for (int i = 0; i < one.length; i += 1) {
      running[i] = (running[i] ?? 0) + (one[i].value ?? 0);
    }
  }

  for (int s = 0; s < layout.values.length; s += 1) {
    if (!layout.visible[s]) {
      continue;
    }

    final List<ChartValue> one = layout.values[s];
    final Color color = layout.colors[s];
    // A hovered legend entry dims the *others* — but only when the series being
    // hovered is actually on the plot. Pointing at an entry that is switched off
    // would otherwise fade every visible series to make room for one that is
    // not there.
    final int? hovered = layout.hovered;
    final double alpha = hovered == null || hovered == s || !layout.visible[hovered] ? 1.0 : 0.28;

    final tops = <Offset?>[
      for (int i = 0; i < layout.count; i += 1)
        if (i >= one.length || one[i].value == null)
          null
        else
          layout.point(i, stacked ? baselines[s][i] + one[i].value! : one[i].value!),
    ];

    final unders = <Offset?>[
      for (int i = 0; i < layout.count; i += 1)
        if (i >= one.length || one[i].value == null)
          null
        else if (stacked)
          layout.point(i, baselines[s][i])
        else
          Offset(layout.point(i, one[i].value!).dx, layout.zeroPx),
    ];

    // `connectNulls` drops the gaps rather than bridging them in the path
    // builder: a bridged segment and a real one have to be the same shape, and
    // the only way to guarantee that is for the builder never to know the
    // difference.
    final List<Offset?> line = connectNulls
        ? tops.where((Offset? point) => point != null).toList()
        : tops;
    final List<Offset?> floor = connectNulls
        ? unders.where((Offset? point) => point != null).toList()
        : unders;

    if (filled) {
      canvas.drawPath(
        areaPath(line, floor, curve),
        Paint()
          // A wash and not a block: an area that is a saturated slab hides
          // whatever it overlaps and makes the line on top of it redundant.
          // Stacked bands take a flatter, opaquer tint, because there the fill
          // *is* the mark and a band that fades out has no bottom edge.
          ..shader = stacked
              ? null
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    color.withValues(alpha: 0.28 * alpha),
                    color.withValues(alpha: 0.02 * alpha),
                  ],
                ).createShader(
                  Rect.fromLTWH(
                    layout.plot.left,
                    layout.plot.top,
                    layout.plot.width,
                    layout.plot.height,
                  ),
                )
          ..color = stacked ? color.withValues(alpha: 0.7 * alpha) : const Color(0xFF000000),
      );
    }

    // A stacked band's fill *is* its mark, so it does not also get a line drawn
    // along the top: the band above would then be separated from it by a
    // coloured stroke, and a stroke between two marks is ink that is not data.
    final bool banded = filled && stacked;

    if (!banded) {
      canvas.drawPath(
        linePath(line, curve),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = color.withValues(alpha: alpha),
      );
    }

    if (!banded && (dots || layout.activeIndex != null)) {
      for (int i = 0; i < layout.count; i += 1) {
        final Offset? at = i < tops.length ? tops[i] : null;

        // Whatever `markers` says, the point under the pointer gets a dot: that
        // is what tells the reader which column the tooltip is about.
        if (at == null || (!dots && i != layout.activeIndex)) {
          continue;
        }

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
  }

  if (valueLabels != PlassChartValueLabels.none) {
    _paintValueLabels(canvas, layout, stacked, baselines, valueLabels, write);
  }
}

/// The numbers written on the marks.
///
/// Drawn after every band, so a label is never crossed by a series drawn later
/// — which on a three-series chart is most of them.
void _paintValueLabels(
  Canvas canvas,
  PlassChartLayout layout,
  bool stacked,
  List<List<double>> baselines,
  PlassChartValueLabels which,
  String Function(double value) write,
) {
  final double radius = markerRadii[layout.size]!;
  final double fontSize = chartFontSizes[layout.size]!;

  for (int s = 0; s < layout.values.length; s += 1) {
    if (!layout.visible[s]) {
      continue;
    }

    final List<ChartValue> one = layout.values[s];
    final bool Function(int) labelled = _labelled(one, which);

    for (int i = 0; i < layout.count && i < one.length; i += 1) {
      final double? value = one[i].value;

      if (value == null || !labelled(i)) {
        continue;
      }

      final Offset at = layout.point(i, stacked ? baselines[s][i] + value : value);
      final String text = one[i].label ?? write(value);

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

  // `extremes`. A series that is entirely a gap has no high and no low, and the
  // comparison below is false for every point of it either way.
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
