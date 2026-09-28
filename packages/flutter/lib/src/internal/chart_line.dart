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
  required PlassChartLabelColor valueLabelColor,
  required PlassChartNulls nulls,
  required String Function(double value) write,
}) {
  final double stroke = lineWidths[layout.size]!;
  final double radius = markerRadii[layout.size]!;

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

  // The markers each series draws, by series, empty for one switched off. They
  // are drawn after every band and every line, so they are worked out in the
  // first pass and drawn in the second.
  final marks = <List<_Marker>>[];

  for (int s = 0; s < layout.values.length; s += 1) {
    if (!layout.visible[s]) {
      marks.add(const <_Marker>[]);
      continue;
    }

    final List<ChartValue> one = layout.values[s];
    // Counted by the series' own points, as the React markers are, so a short
    // series on a long chart keeps its dots.
    final bool dots =
        markers == PlChartMarkers.all ||
        (markers == PlChartMarkers.auto && one.length <= _autoMarkerLimit);
    // Whole whatever alpha the colour carries: a fade is the layer's.
    final Color color = layout.colors[s].withValues(alpha: 1);
    // Faded while the legend points at another series, and eased there.
    final double alpha = _openFade(canvas, layout, s);

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

    // `connect` drops the gaps rather than bridging them in the path builder: a
    // bridged segment and a real one have to be the same shape, and the only
    // way to guarantee that is for the builder never to know the difference.
    //
    // The other two need nothing here. `gap` is what the builder does with the
    // nulls it is handed, and `zero` was settled before the frame was ever
    // given the data — see `zeroNulls`, which is why a zeroed gap moves the
    // axis and fills the table row as well as the line.
    final bool bridged = nulls == PlassChartNulls.connect;
    final List<Offset?> line = bridged
        ? tops.where((Offset? point) => point != null).toList()
        : tops;
    final List<Offset?> floor = bridged
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
                  colors: <Color>[color.withValues(alpha: 0.28), color.withValues(alpha: 0.02)],
                ).createShader(
                  Rect.fromLTWH(
                    layout.plot.left,
                    layout.plot.top,
                    layout.plot.width,
                    layout.plot.height,
                  ),
                )
          ..color = stacked ? color.withValues(alpha: 0.7) : const Color(0xFF000000),
      );
    }

    // A stacked band's fill *is* its mark, so it does not also get a line drawn
    // along the top: the band above would then be separated from it by a
    // coloured stroke, and a stroke between two marks is ink that is not data.
    final bool banded = filled && stacked;

    if (!banded) {
      final Path path = linePath(line, curve);

      canvas.drawPath(
        // A `dashed` series is cut into pieces here rather than at the paint,
        // because a `Paint` has no dash pattern. The round cap is kept, so each
        // dash is a rounded stroke of its own and the rhythm reads at 2px.
        layout.dashed[s] ? dashedPath(path) : path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = color,
      );
    }

    // A stacked band has no line, but its points still get their dots, on the
    // band's top at the running total, as the React markers are.
    final List<_Marker> own = <_Marker>[
      if (dots || layout.activeIndex != null)
        for (int i = 0; i < tops.length; i += 1)
          // Whatever `markers` says, the point under the pointer gets a dot:
          // that is what tells the reader which column the tooltip is about.
          if (tops[i] != null && (dots || i == layout.activeIndex))
            (
              index: i,
              at: tops[i]!,
              // A pixel bigger under the crosshair, as the React marker's `r`
              // is, and eased there with its column. A dot drawn only because
              // its column is being read has nothing to grow from, so it
              // arrives at that size, as a React marker put under the
              // crosshair does.
              r: radius + (dots ? layout.columnLit(i) : 1),
            ),
    ];

    marks.add(own);

    if (alpha < 1) {
      // A faded series' markers fade in a layer of their own, drawn after
      // every band, where its own band and line would show through them. So
      // they are cut out of this layer, out to the edge of the ring. At full
      // strength a marker covers them whole, and there is no layer.
      for (final _Marker marker in own) {
        canvas.drawCircle(marker.at, marker.r + markGap / 2, Paint()..blendMode = BlendMode.clear);
      }

      canvas.restore();
    }
  }

  // The markers go on after every band and every line, so the band above a
  // stacked one does not wash over their top half, and no line crosses
  // another series' marker, as in the React build.
  for (int s = 0; s < marks.length; s += 1) {
    if (marks[s].isEmpty) {
      continue;
    }

    final List<ChartValue> one = layout.values[s];
    final Color color = layout.colors[s];
    final double alpha = _openFade(canvas, layout, s);

    for (final _Marker marker in marks[s]) {
      // The ring is the surface showing through, `markGap` wide and centred on
      // the marker's edge, which is where the React marker's stroke lies over
      // its fill: the dot is half the gap inside `r` and the ring runs to half
      // the gap outside it, two discs with the dot on top.
      canvas
        ..drawCircle(
          marker.at,
          marker.r + markGap / 2,
          Paint()..color = layout.tokens.surface.withValues(alpha: 1),
        )
        ..drawCircle(
          marker.at,
          marker.r - markGap / 2,
          Paint()..color = (one[marker.index].color ?? color).withValues(alpha: 1),
        );
    }

    if (alpha < 1) {
      canvas.restore();
    }
  }

  if (valueLabels != PlassChartValueLabels.none) {
    _paintValueLabels(canvas, layout, stacked, baselines, valueLabels, valueLabelColor, write);
  }
}

/// A marker a series draws: the point it stands for, where it stands, and its
/// radius.
typedef _Marker = ({int index, Offset at, double r});

/// Opens a layer faded to the opacity [series] is drawn at, when that is less
/// than whole, and returns the opacity.
///
/// A faded series is drawn into layers and each layer is faded, as the React
/// series' groups are, rather than each part on its own paint, which would let
/// the line show through its markers. A series at full strength needs no
/// layer. A layer takes the clip the frame has put round the plot.
double _openFade(Canvas canvas, PlassChartLayout layout, int series) {
  final double alpha = layout.seriesOpacity(series);

  if (alpha < 1) {
    canvas.saveLayer(null, Paint()..color = const Color(0xFF000000).withValues(alpha: alpha));
  }

  return alpha;
}

/// The numbers written on the marks.
///
/// Drawn after every band and every marker, so a label is never crossed by a
/// series drawn later — which on a three-series chart is most of them.
void _paintValueLabels(
  Canvas canvas,
  PlassChartLayout layout,
  bool stacked,
  List<List<double>> baselines,
  PlassChartValueLabels which,
  PlassChartLabelColor ink,
  String Function(double value) write,
) {
  final double radius = markerRadii[layout.size]!;
  final double fontSize = chartFontSizes[layout.size]!;

  for (int s = 0; s < layout.values.length; s += 1) {
    if (!layout.visible[s]) {
      continue;
    }

    final List<ChartValue> one = layout.values[s];
    final bool Function(int) labelled = labelledPoints(one, which);

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
            fontWeight: FontWeight.w600,
            // In the line's own colour, so a plot with four labelled series
            // says which number belongs to which line without the reader
            // tracing it back. A point carrying a colour of its own is labelled
            // in that: the label names the mark it is sitting on.
            color: ink == PlassChartLabelColor.ink
                ? layout.tokens.fg
                : one[i].color ?? layout.colors[s],
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
