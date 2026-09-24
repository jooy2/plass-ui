/// Work against time — a row per thing, a bar per stretch of it.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/chart.dart';
import 'package:plass_ui/src/internal/chart_frame.dart';
import 'package:plass_ui/src/internal/date.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// Work against time — a row per thing, a bar per stretch of it.
///
/// The two axes are a set of rows and a calendar, which makes this a
/// `PlBarChart` turned on its side with the baseline taken away: every bar
/// starts where its own data says rather than at zero, so what the chart is
/// about is *when* rather than *how much*.
///
/// Not to be confused with [PlTimeline], which is a list of steps and draws no
/// axis at all. That one is for a sequence of events; this one is for how long
/// each of them took.
///
/// ```dart
/// PlTimelineChart(
///   series: <PlassTimelineSeries>[
///     PlassTimelineSeries(name: 'Design', data: <PlassTimelinePoint>[…]),
///   ],
/// )
/// ```
class PlTimelineChart extends StatelessWidget {
  /// Creates a timeline chart.
  const PlTimelineChart({
    required this.series,
    this.min,
    this.max,
    this.barSize,
    this.rounded = true,
    this.xAxis = const PlChartAxis(),
    this.yAxis = const PlChartAxis(),
    this.reference = const <PlassChartReference>[],
    this.tooltip = const PlChartTooltip(),
    this.height,
    this.semanticLabel,
    this.empty,
    this.size,
    this.density,
    super.key,
  });

  /// One row per series, and the spans on it. A row's name is what the axis
  /// says down the starting edge.
  final List<PlassTimelineSeries> series;

  /// Where the time axis starts. Taken from the spans otherwise, and rounded
  /// outward to a date a calendar has a name for.
  final PlassChartCategory? min;

  /// And where it ends.
  final PlassChartCategory? max;

  /// How thick a bar may get, in pixels. Below the cap the bars fill their
  /// share of the row; above it the leftover stays as air.
  final double? barSize;

  /// Cuts the corners off a span.
  ///
  /// Both ends, unlike a `PlBarChart`, where the baseline end stays square. A
  /// span grows from nothing: neither of its ends is a zero, so neither is the
  /// one the reader is measuring from.
  final bool rounded;

  /// The axis the rows are named down.
  final PlChartAxis xAxis;

  /// The time axis.
  final PlChartAxis yAxis;

  /// Lines drawn across the plot at a value — a target, an average, a limit.
  ///
  /// Not data, and drawn as if they know it: dashed, in the muted ink, under
  /// the marks. They sit on the **value** axis, so one runs across a vertical
  /// chart and down a horizontal one. Each is written into the reading a screen
  /// reader is given with the chart.
  final List<PlassChartReference> reference;

  /// The readout under the pointer.
  final PlChartTooltip tooltip;

  /// How tall the plot is.
  final double? height;

  /// What the whole drawing is called.
  final String? semanticLabel;

  /// What is drawn when there is nothing to draw.
  final Widget? empty;

  /// Type scale, plot height and the bar thickness cap.
  final PlassSize? size;

  /// How much of a row's slot the bars on it may take. Never the height.
  final PlassDensity? density;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final PlDateNames names = PlassTheme.defaultsOf(context).names ?? PlDateNames.english;
    final PlassSize step = size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;

    /* The rows, as instants, in lanes. Done once here rather than in the marks
       builder, because the axis has to be solved before anything can be placed
       on it — and because the lane a span sits in is a fact about the data
       rather than about the pixels. */
    final List<_Row> rows = <_Row>[for (final PlassTimelineSeries row in series) _pack(row)];

    double low = double.infinity;
    double high = double.negativeInfinity;
    bool seen = false;

    for (final _Row row in rows) {
      for (final _Span? one in row.spans) {
        if (one == null) {
          continue;
        }

        seen = true;
        low = math.min(low, one.from);
        high = math.max(high, one.to);
      }
    }

    final TimeScale scale = timeScale(
      seen ? ChartExtent(low, high) : null,
      min: categoryNumber(min),
      max: categoryNumber(max),
      tickCount: yAxis.tickCount,
    );

    final List<String> tickTexts = formatTimeTicks(scale.ticks, scale.unit, names);
    // An axis of hours over two days has to say which day each span is on, and
    // the tooltip and the summary have to say it the same way.
    final bool withDate = timeNeedsDate(scale.ticks, scale.unit);
    final ticksByValue = <double, String>{
      for (int i = 0; i < scale.ticks.length; i += 1) scale.ticks[i]: tickTexts[i],
    };

    final List<String> rowNames = <String>[
      for (int i = 0; i < series.length; i += 1) series[i].name ?? '${i + 1}',
    ];
    final List<Color> colors = <Color>[
      for (int i = 0; i < series.length; i += 1)
        seriesColor(
          series[i].color == null ? null : tokens.family(series[i].color!).accent,
          i,
          tokens.chart,
        ),
    ];

    /* One synthetic series, with an entry per row. The frame counts
       *categories* along the band axis and stacks series within each one; a
       Gantt has the opposite shape — one row per entity, and several marks
       along each row. So the rows are handed over as the categories, and this
       stands in for the series the frame expects to find them under. A row with
       no spans is a gap, which is what makes an empty chart empty. */
    final filler = <PlassChartSeries>[
      PlassChartSeries(
        data: <PlassChartDatum>[
          for (final _Row row in rows)
            if (row.spans.any((_Span? one) => one != null))
              const PlassChartDatum(1)
            else
              const PlassChartDatum.gap(),
        ],
      ),
    ];

    final double thickness = barSize ?? barMaxThickness[step]!;

    List<PlassChartMark> marks(PlassChartLayout layout) {
      final list = <PlassChartMark>[];

      for (int index = 0; index < rows.length; index += 1) {
        final _Row row = rows[index];

        /* A row's lanes share its band, exactly as grouped bars share a
           category's: each takes an equal cut with the 2px of surface between
           them, and the whole group stays centred on the row's own tick. A row
           with one lane is unchanged, which is the point of packing at all. */
        final double lane = math.min(
          thickness,
          math.max(1, (layout.band.band - markGap * (row.lanes - 1)) / row.lanes),
        );
        final double group = lane * row.lanes + markGap * (row.lanes - 1);
        final double top = layout.plot.top + layout.categoryPx(index) - group / 2 + lane / 2;

        for (int at = 0; at < row.spans.length; at += 1) {
          final _Span? one = row.spans[at];

          if (one == null || !_inWindow(one, layout.scale)) {
            continue;
          }

          /* Cut to the plot rather than to the data. A caller who pinned `min`
             to this quarter still has work that began last one, and a bar that
             stops at the edge says there is more of it off the side; one drawn
             past the edge says the axis is wrong. The mark is cut with the bar,
             so the pointer and the readout stay on what is drawn. */
          final double from = layout.valuePx(math.max(one.from, layout.scale.min));
          final double to = layout.valuePx(math.min(one.to, layout.scale.max));

          list.add(
            PlassChartMark(
              series: index,
              index: at,
              centre: Offset((from + to) / 2, top + one.lane * (lane + markGap)),
              r: lane / 2,
              // A box and not a disc: a fortnight is two hundred pixels of bar
              // whose centre the pointer may never go near.
              rx: math.max(0, (to - from) / 2),
              ry: lane / 2,
            ),
          );
        }
      }

      return list;
    }

    _Span? spanAt(PlassChartMark mark) {
      final List<_Span?> row = rows[mark.series].spans;

      return mark.index < row.length ? row[mark.index] : null;
    }

    return PlassCartesianChart(
      series: filler,
      categories: <PlassChartCategory>[
        for (final String name in rowNames) PlassChartCategory.text(name),
      ],
      size: size,
      density: density,
      // The rows run down the side and time runs along the bottom, which is a
      // bar chart on its side. `xAxis` is still the category axis and `yAxis`
      // still the value one, exactly as on every other chart.
      horizontal: true,
      scale: scale,
      xAxis: xAxis,
      reference: reference,
      yAxis: PlChartAxis(
        hidden: yAxis.hidden,
        label: yAxis.label,
        min: yAxis.min,
        max: yAxis.max,
        tickCount: yAxis.tickCount,
        scale: yAxis.scale,
        grid: yAxis.grid,
        thickness: yAxis.thickness,
        format: yAxis.format ?? (double value) => ticksByValue[value] ?? '',
      ),
      // A Gantt's rows are its axis; a legend would restate them one per line.
      legend: const PlChartLegend(hidden: true),
      tooltip: tooltip,
      height: height,
      semanticLabel: semanticLabel,
      empty: empty,
      marks: marks,
      markReadout: (PlassChartMark mark) {
        final _Span? one = spanAt(mark);

        if (one == null) {
          return '';
        }

        return '${formatTimeValue(one.from, scale.unit, names, withDate: withDate)} – '
            '${formatTimeValue(one.to, scale.unit, names, withDate: withDate)}';
      },
      // The span names itself when it can, and the row is then the second line
      // rather than a repeat of the first.
      markHeading: (PlassChartMark mark) => spanAt(mark)?.span.label ?? rowNames[mark.series],
      // So the row is beside the swatch only under a span's own name. Under
      // the row's, it would be written twice and read twice, "Design, Design".
      markName: (PlassChartMark mark) =>
          spanAt(mark)?.span.label == null ? null : rowNames[mark.series],
      // The colour the bar is painted in, so the card's swatch matches it. A
      // mark's series is its row here, and the frame's own colours are for the
      // one stand-in series above rather than for the rows.
      markColor: (PlassChartMark mark) {
        final PlassColor? own = spanAt(mark)?.color;

        return own == null ? colors[mark.series] : tokens.family(own).accent;
      },
      semanticValue: (_) => _summary(rows, rowNames, scale, names, withDate),
      paint: (Canvas canvas, PlassChartLayout layout) =>
          _paint(canvas, layout, rows, colors, tokens),
    );
  }

  /// Every span on the plot, row by row, as the two instants it runs between.
  String _summary(
    List<_Row> rows,
    List<String> rowNames,
    TimeScale scale,
    PlDateNames names,
    bool withDate,
  ) {
    final parts = <String>[];

    for (int i = 0; i < rows.length; i += 1) {
      final spans = <String>[];

      for (final _Span? one in rows[i].spans) {
        if (one == null || !_inWindow(one, scale)) {
          continue;
        }

        final String when =
            '${formatTimeValue(one.from, scale.unit, names, withDate: withDate)} – '
            '${formatTimeValue(one.to, scale.unit, names, withDate: withDate)}';

        spans.add(one.span.label == null ? when : '${one.span.label} $when');
      }

      if (spans.isNotEmpty) {
        parts.add('${rowNames[i]}: ${spans.join('; ')}');
      }
    }

    return parts.join('. ');
  }

  /// The bars, and the only part of a timeline chart that is not the frame.
  ///
  /// Drawn as rectangles rather than through [barPath], which is the one place
  /// this differs from a bar chart and is not an omission: `barPath` rounds the
  /// data end and leaves the baseline end square, because a bar that is soft
  /// where it meets the axis has lost the exact moment it starts. A span meets
  /// no axis. Both of its ends are data, so both of them round.
  void _paint(
    Canvas canvas,
    PlassChartLayout layout,
    List<_Row> rows,
    List<Color> colors,
    PlassTokens tokens,
  ) {
    final double radius = rounded ? barRadius : 0;

    for (final PlassChartMark mark in layout.marks) {
      final List<_Span?> row = rows[mark.series].spans;
      final _Span? one = mark.index < row.length ? row[mark.index] : null;

      if (one == null) {
        continue;
      }

      final bool active =
          layout.activeMark?.series == mark.series && layout.activeMark?.index == mark.index;
      final double half = mark.rx ?? mark.r;
      final double thickness = (mark.ry ?? mark.r) * 2;

      // The mark is already cut to the plot. A zero-width span keeps a hairline,
      // so a milestone is still something on the row.
      final double width = math.max(1, half * 2);
      final Rect box = Rect.fromLTWH(
        mark.centre.dx - half,
        mark.centre.dy - thickness / 2,
        width,
        thickness,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          box,
          Radius.circular(math.min(radius, math.min(width / 2, thickness / 2))),
        ),
        Paint()
          ..color = (one.color == null ? colors[mark.series] : tokens.family(one.color!).accent)
              .withValues(alpha: active ? 1 : 0.92),
      );
    }
  }
}

/// A span, once its two ends are numbers and it knows which lane it is in.
class _Span {
  _Span({required this.from, required this.to, required this.span, this.color});

  final double from;
  final double to;
  final PlassTimelinePoint span;
  final PlassColor? color;

  /// Which sub-lane of its row, for a row that does two things at once.
  int lane = 0;
}

/// One row's spans, placed, with the overlapping ones on lanes of their own.
class _Row {
  const _Row(this.spans, this.lanes);

  final List<_Span?> spans;
  final int lanes;
}

/// Packs one row.
///
/// A row that is doing two things at once is the ordinary case on a Gantt, and
/// drawing the second bar on top of the first turns two facts into one smudge.
/// The packing is the greedy one every scheduler uses: walk the spans in start
/// order and drop each into the first lane whose last one has finished. It is
/// optimal for intervals, and it leaves a row with no overlaps in a single lane
/// — so the common row is exactly as thick as it was.
///
/// Lanes are assigned in *start* order and stored against the span's original
/// index, because the order the data was written in is the order a reader hears
/// and that must not be reshuffled by a layout decision.
_Row _pack(PlassTimelineSeries row) {
  final spans = <_Span?>[for (final PlassTimelinePoint span in row.data) _place(span)];

  final ends = <double>[];
  final ordered = <_Span>[for (final _Span? one in spans) ?one]
    ..sort((_Span a, _Span b) => a.from.compareTo(b.from));

  for (final _Span one in ordered) {
    int free = -1;

    for (int i = 0; i < ends.length; i += 1) {
      if (ends[i] <= one.from) {
        free = i;
        break;
      }
    }

    final int lane = free == -1 ? ends.length : free;

    if (free == -1) {
      ends.add(one.to);
    } else {
      ends[lane] = one.to;
    }

    one.lane = lane;
  }

  return _Row(spans, math.max(1, ends.length));
}

/// One span with its ends as numbers, or `null` when either is not a time.
_Span? _place(PlassTimelinePoint span) {
  final double? from = categoryNumber(span.start);
  final double? to = categoryNumber(span.end);

  // Either way round. A span the caller wrote backwards is a typo, and drawing
  // it as a bar of negative width is a blank row.
  if (from == null || to == null) {
    return null;
  }

  return _Span(from: math.min(from, to), to: math.max(from, to), span: span, color: span.color);
}

/// Whether any of a span falls inside the axis.
///
/// A span wholly before `min` or after `max` is not on the chart: it is not
/// drawn, so it is not a mark the pointer can land on, and the summary does not
/// read it out either. One that crosses an edge is on the chart, cut where the
/// axis ends.
bool _inWindow(_Span one, ValueScale scale) => one.to >= scale.min && one.from <= scale.max;
