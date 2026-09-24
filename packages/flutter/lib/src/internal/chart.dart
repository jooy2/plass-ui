/// The arithmetic every chart is made of.
///
/// Here rather than in a widget for the reason `internal/progress.dart` is:
/// several widgets draw several different marks and ask exactly the same four
/// questions first — what is the range, where does a value land in the plot,
/// what are the clean numbers to tick at, and what colour is series four. A
/// chart file that also has to answer those is a file where the drawing cannot
/// be read.
///
/// **Nothing in here knows what a `Canvas` is.** What it knows is data and
/// pixels; `internal/chart_frame.dart` is where those become paint. That split
/// is also what lets this file be the Dart half of `internal/chart.ts` almost
/// line for line — the two builds must not disagree about where a tick goes,
/// and the only way to be sure of that is for the arithmetic to be the same
/// arithmetic.
///
/// It is not exported from `plass_ui.dart`.
library;

import 'dart:math' as math;
import 'dart:ui' show Color, Offset, Path, PathFillType, PathMetric, RRect, Radius, Rect;

import 'package:plass_ui/src/internal/date.dart';
import 'package:plass_ui/src/types.dart';

/* ---------------------------------------------------------------------------
 * Scales
 * ------------------------------------------------------------------------- */

/// How tall a plot is when nobody said, in logical pixels.
///
/// A chart is one of the few things in the library with no intrinsic height —
/// it is as tall as it is given — so this ladder is what stops every chart on a
/// dashboard being a different shape. The steps climb faster than the control
/// ladder because the thing being scaled is a *picture*: at `xs` this is a
/// strip beside a number, at `xl` it is what the screen is about.
///
/// The axis band is drawn *inside* this, not added to it.
const Map<PlassSize, double> plotHeights = <PlassSize, double>{
  PlassSize.xs: 120,
  PlassSize.sm: 160,
  PlassSize.md: 220,
  PlassSize.lg: 280,
  PlassSize.xl: 360,
};

/// A sparkline's own ladder, which is a different object: it has no axes, no
/// legend and nothing to read off it but the shape, so it is sized against the
/// line of text it sits next to rather than against the screen.
const Map<PlassSize, double> sparklineHeights = <PlassSize, double>{
  PlassSize.xs: 16,
  PlassSize.sm: 20,
  PlassSize.md: 28,
  PlassSize.lg: 40,
  PlassSize.xl: 56,
};

/// The weight of a line. `md` is 2, which is the width a data line wants
/// everywhere — thin enough to stay a line where two of them cross, heavy
/// enough to hold a hue at 3:1.
const Map<PlassSize, double> lineWidths = <PlassSize, double>{
  PlassSize.xs: 1.5,
  PlassSize.sm: 1.75,
  PlassSize.md: 2,
  PlassSize.lg: 2.25,
  PlassSize.xl: 2.5,
};

/// The dash and the gap of a `dashed` series, in logical pixels.
///
/// Fixed rather than scaled by the line's weight, and the same two numbers the
/// React build writes into `stroke-dasharray`: a dash pattern is read as a
/// *rhythm*, and one that stretched with the size ladder would change what the
/// line means between an `sm` chart and an `lg` one.
const double lineDash = 6;

/// The space between two dashes. See [lineDash].
const double lineDashGap = 4;

/// [path] cut into dashes of [lineDash] with [lineDashGap] between them.
///
/// Flutter has no dash pattern on a `Paint`, so the line is walked with
/// [Path.computeMetrics] and rebuilt in pieces. Which is the honest way round:
/// a dash pattern is a fact about the *outline*, and the outline is the thing
/// that knows how long it is.
///
/// The one dash loop in the package. A dashed series, a reference line, a
/// dashed series' legend key and the edge round a `PlFilePicker` are all cut
/// here, so there is one rhythm to a dashed line wherever the library draws
/// one.
Path dashedPath(Path path) {
  final Path dashes = Path();

  for (final PathMetric metric in path.computeMetrics()) {
    double at = 0;

    while (at < metric.length) {
      dashes.addPath(metric.extractPath(at, math.min(at + lineDash, metric.length)), Offset.zero);
      at += lineDash + lineDashGap;
    }
  }

  return dashes;
}

/// The radius of a marker. `md` is 4, so the dot is 8 across before its ring —
/// the floor below which a marker stops being something a pointer can find.
const Map<PlassSize, double> markerRadii = <PlassSize, double>{
  PlassSize.xs: 3,
  PlassSize.sm: 3.5,
  PlassSize.md: 4,
  PlassSize.lg: 4.5,
  PlassSize.xl: 5,
};

/// Tick and label type, as numbers rather than as a text scale.
///
/// The room the axis reserves is measured from this, so it has to be a number
/// the layout arithmetic can also read. These are `metaText` again; keep the
/// two in step.
const Map<PlassSize, double> chartFontSizes = <PlassSize, double>{
  PlassSize.xs: 10,
  PlassSize.sm: 11,
  PlassSize.md: 12,
  PlassSize.lg: 13,
  PlassSize.xl: 14,
};

/// How thick a bar is allowed to get.
///
/// A cap and not a width: the band a bar sits in is whatever the plot divided
/// by the category count gives, and a bar that fills its band leaves the chart
/// with no air in it at all. Past this the leftover stays as space.
const Map<PlassSize, double> barMaxThickness = <PlassSize, double>{
  PlassSize.xs: 14,
  PlassSize.sm: 18,
  PlassSize.md: 24,
  PlassSize.lg: 30,
  PlassSize.xl: 36,
};

/// How much of a category's slot the marks in it may take.
///
/// The same pair as the React build's `barBandRatio`, and it has to be: a bar
/// chart of the same data at the same size is one picture, not two that are
/// nearly alike.
const Map<PlassDensity, double> barBandRatio = <PlassDensity, double>{
  PlassDensity.standard: 0.62,
  PlassDensity.compact: 0.82,
};

/// The air between two marks that share a slot.
const double markGap = 2;

/// The corner a bar's free end takes.
const double barRadius = 4;

/* ---------------------------------------------------------------------------
 * Colour
 * ------------------------------------------------------------------------- */

/// What colour a mark is, in the fixed order the palette is handed out in.
///
/// [index] is the series' place in the list it was passed in, not its place
/// among the ones currently visible. That is the whole point: filtering a
/// legend must not repaint the survivors, because a reader who learned that
/// Europe is blue has learned something a rebuild is not allowed to take back.
///
/// Past the eighth slot it wraps, and a chart that gets there should not have —
/// a ninth hue is indistinguishable from one of the first eight under colour
/// vision deficiency no matter which one is chosen. Fold the tail into an
/// "Other" series, or draw a second chart.
Color seriesColor(Color? own, int index, List<Color> palette) {
  return own ?? palette[index % palette.length];
}

/* ---------------------------------------------------------------------------
 * Legend
 * ------------------------------------------------------------------------- */

/// Whether the mark of [index] fades while the legend entry of [hovered] is
/// under the pointer.
///
/// A hovered entry dims the *others* — but only when the series it names is
/// actually on the plot. Pointing at an entry that is switched off would
/// otherwise fade every visible series to make room for one that is not there,
/// which reads as the whole chart going grey for no reason.
bool dimmedByHover(int? hovered, int index, List<bool> visible) {
  if (hovered == null || hovered == index) {
    return false;
  }

  return hovered >= 0 && hovered < visible.length && visible[hovered];
}

/* ---------------------------------------------------------------------------
 * Data
 * ------------------------------------------------------------------------- */

/// A datum unpacked into the shape the drawing code reads.
class ChartValue {
  /// Creates an unpacked datum.
  const ChartValue({this.value, this.x, this.z, this.color, this.label});

  /// The reading, or `null` for a **gap** — which is never a zero.
  final double? value;

  /// Where it sits along the category axis, when the point carries its own.
  final PlassChartCategory? x;

  /// The third dimension, for a bubble.
  final double? z;

  /// A colour for this one point, overriding the series'.
  final Color? color;

  /// What the tooltip and the table call it.
  final String? label;
}

/// A number that is a number: `NaN` and the infinities fold to `null`.
///
/// Folded here rather than at every call site because they arrive from a
/// division somewhere upstream, they mean the same thing a gap means, and a
/// scale handed one produces a path with `NaN` in it — which fails silently as
/// a blank chart rather than loudly as an error.
double? finiteOrNull(double? value) {
  if (value == null || value.isNaN || value.isInfinite) {
    return null;
  }

  return value;
}

/// One datum, whichever of the two ways it was written.
ChartValue toValue(PlassChartDatum datum) {
  final PlassChartPoint? point = datum.point;

  if (point == null) {
    return ChartValue(value: finiteOrNull(datum.value));
  }

  return ChartValue(
    value: finiteOrNull(point.y),
    x: point.x,
    z: point.z,
    color: point.color,
    label: point.label,
  );
}

/// Every series unpacked, in the order it was given.
List<List<ChartValue>> toValues(List<PlassChartSeries> series) {
  return series.map((PlassChartSeries one) => one.data.map(toValue).toList()).toList();
}

/// A chart's categories, reordered and with the tail of them folded into one.
///
/// Both are changes to the **data** rather than to the drawing, which is the
/// same rule [zeroNulls] and [stackToFull] follow and for the same reason: the
/// axis, the readout, the legend and the reading a screen reader is handed all
/// read the series they were given, so a category that has been folded away has
/// to be folded away for all of them at once. A painter that reordered the bars
/// would leave the axis naming the old order.
///
/// ## What 'size' means with more than one series
///
/// The total across every series at that category, and every series' magnitude
/// rather than its signed value — a category whose two series are +50 and −50
/// is a hundred units of chart, not nothing. `hidden` is not consulted: the
/// order is a property of the data, and a chart whose columns rearranged
/// themselves when a legend entry was pressed is one a reader cannot use.
///
/// ## The tail
///
/// [max] keeps the largest that many and sums the rest into one category, which
/// is the answer to a chart of ninety countries: a bar too short to see is a
/// bar costing width without saying anything. What is folded is decided by size
/// and never by [sort], so [PlassChartSort.ascending] shows the small ones it
/// kept rather than keeping the small ones. The fold is always last, wherever
/// the sort would otherwise have put it: it is not a category, it is what is
/// left. The React build answers with `rankCategories`.
({List<PlassChartSeries> series, List<PlassChartCategory>? categories}) rankCategories(
  List<PlassChartSeries> series,
  List<PlassChartCategory>? categories, {
  PlassChartSort sort = PlassChartSort.none,
  int? max,
  required String other,
}) {
  final int count = categoryCount(series);
  final bool folding = max != null && max > 0 && count > max;

  if (!folding && (sort == PlassChartSort.none || count == 0)) {
    return (series: series, categories: categories);
  }

  final List<List<ChartValue>> values = toValues(series);

  double size(int index) {
    double sum = 0;

    for (final List<ChartValue> one in values) {
      if (index < one.length) {
        sum += (one[index].value ?? 0).abs();
      }
    }

    return sum;
  }

  // Kept and folded, decided by size before anything is sorted.
  final List<int> order = <int>[for (int i = 0; i < count; i += 1) i];
  final List<int> kept;

  if (folding) {
    final List<int> bySize = <int>[...order]..sort((int a, int b) => size(b).compareTo(size(a)));

    kept = bySize.take(max).toList()..sort();
  } else {
    kept = order;
  }

  final List<int> folded = folding
      ? order.where((int index) => !kept.contains(index)).toList()
      : <int>[];

  final List<int> ranked = sort == PlassChartSort.none
      ? kept
      : (<int>[...kept]..sort(
          (int a, int b) => sort == PlassChartSort.ascending
              ? size(a).compareTo(size(b))
              : size(b).compareTo(size(a)),
        ));

  return (
    series: <PlassChartSeries>[
      for (int s = 0; s < series.length; s += 1)
        PlassChartSeries(
          data: <PlassChartDatum>[
            for (final int index in ranked)
              index < series[s].data.length ? series[s].data[index] : const PlassChartDatum.gap(),
            if (folded.isNotEmpty) _fold(values[s], folded, other),
          ],
          id: series[s].id,
          name: series[s].name,
          color: series[s].color,
          dashed: series[s].dashed,
          hidden: series[s].hidden,
        ),
    ],
    categories: categories == null
        ? null
        : <PlassChartCategory>[
            for (final int index in ranked)
              index < categories.length
                  ? categories[index]
                  : PlassChartCategory.number(index.toDouble()),
            if (folded.isNotEmpty) PlassChartCategory.text(other),
          ],
  );
}

/// The folded tail of one series as one datum.
///
/// A fold of nothing but gaps stays a gap: summing them to zero would invent a
/// reading for every country that reported nothing.
PlassChartDatum _fold(List<ChartValue> row, List<int> folded, String other) {
  double total = 0;
  bool found = false;

  for (final int index in folded) {
    final double? value = index < row.length ? row[index].value : null;

    if (value != null) {
      total += value;
      found = true;
    }
  }

  return PlassChartDatum.point(
    PlassChartPoint(y: found ? total : null, x: PlassChartCategory.text(other)),
  );
}

/// Every gap in every series read as a zero, for [PlassChartNulls.zero].
///
/// Done to the **data**, before the frame ever sees it, and that is the whole
/// reason it is a function here rather than a branch in the painter. A zero is
/// a value: it has to move the scale, appear in the readout, and be in the row
/// a screen reader is handed. Substituted inside the painter it would be none
/// of those — the line would touch a baseline the axis did not admit existed,
/// and the table under it would still say the month was missing.
///
/// A point that carried a label or a colour of its own keeps them, because it
/// is the same point with a number read into it.
List<PlassChartSeries> zeroNulls(List<PlassChartSeries> series) {
  return <PlassChartSeries>[
    for (final PlassChartSeries one in series)
      PlassChartSeries(
        data: <PlassChartDatum>[
          for (final PlassChartDatum datum in one.data)
            if (datum.point case final PlassChartPoint point)
              finiteOrNull(point.y) == null
                  ? PlassChartDatum.point(
                      PlassChartPoint(
                        y: 0,
                        x: point.x,
                        z: point.z,
                        color: point.color,
                        label: point.label,
                      ),
                    )
                  : datum
            else
              PlassChartDatum(finiteOrNull(datum.value) ?? 0),
        ],
        id: one.id,
        name: one.name,
        color: one.color,
        dashed: one.dashed,
        hidden: one.hidden,
      ),
  ];
}

/// Which points of a series get a value label, decided once for the whole
/// series.
///
/// Once and not per point, which is the only thing worth saying about it:
/// asking "is this the series' high" inside the loop over the points means
/// walking the series again for each of them, and a five-hundred-point line
/// then does a quarter of a million comparisons to place two labels — on every
/// build, which on a chart being hovered is every frame. `last` is the last
/// point that is there rather than the last slot, so a series that ends in a
/// gap still says where it got to.
bool Function(int) labelledPoints(List<ChartValue> one, PlassChartValueLabels which) {
  if (which == PlassChartValueLabels.none) {
    return (int _) => false;
  }

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

/// The series a stack drawn to full length actually draws.
///
/// 100% stacking is a change to the *data* and not to the drawing: each
/// category is renormalised to add up to a hundred, so the axis, the tooltip
/// and the summary all agree that the number drawn is a share. The number the
/// caller passed survives as each point's label, written by [write] the way
/// the chart writes every other value — a chart stacked to full that can only
/// tell a reader percentages has thrown away what it was given.
List<PlassChartSeries> stackToFull(
  List<PlassChartSeries> series,
  String Function(double value) write,
) {
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
                  label: values[s][i].label ?? write(values[s][i].value!),
                ),
              ),
        ],
      ),
  ];
}

/// How many categories the widest series has.
int categoryCount(List<PlassChartSeries> series) {
  return series.fold<int>(0, (int most, PlassChartSeries one) => math.max(most, one.data.length));
}

/// What the category axis says at position [index].
///
/// [categories] wins, then whatever the first series that has one calls its own
/// point, then the index. Three sources rather than one because a chart is
/// written both ways in the wild — a column of labels beside a column of
/// numbers, or points that carry their own `x` — and neither is wrong.
PlassChartCategory categoryAt(
  int index,
  List<PlassChartCategory>? categories,
  List<List<ChartValue>> values,
) {
  if (categories != null && index < categories.length) {
    return categories[index];
  }

  for (final List<ChartValue> one in values) {
    if (index < one.length && one[index].x != null) {
      return one[index].x!;
    }
  }

  return PlassChartCategory.number(index.toDouble());
}

/// A category as it is written on an axis, in a tooltip, in a legend and in a
/// summary.
///
/// A moment is its short month and its day, `Mar 1`, as the React build writes
/// one. [PlassChartCategory.toString] is the ISO timestamp, which is a value for
/// a program rather than a label for a reader.
String categoryText(PlassChartCategory category, PlDateNames names) {
  final DateTime? date = category.date;

  return date == null ? category.toString() : '${names.monthsShort[date.month - 1]} ${date.day}';
}

/// The two ends of a range, or `null` when there is nothing in it.
class ChartExtent {
  /// Creates an extent.
  const ChartExtent(this.min, this.max);

  /// The lowest value seen.
  final double min;

  /// The highest.
  final double max;
}

/// A category as a number, or `null` when it is not one.
///
/// A `Date` is its milliseconds and a number is itself; text has no place on a
/// number line and folds to `null` rather than to zero, which would put every
/// named thing on top of each other at the origin.
double? categoryNumber(PlassChartCategory? value) {
  if (value == null) {
    return null;
  }

  if (value.date != null) {
    return value.date!.millisecondsSinceEpoch.toDouble();
  }

  return finiteOrNull(value.number);
}

/// Whether the positions along a chart's x axis are moments.
///
/// Such an axis runs on milliseconds, and ticking milliseconds by 1-2-5 puts a
/// `1.7T` under every mark. A dated axis ticks where a calendar does instead.
bool categoriesAreDates(List<List<ChartValue>> values, List<PlassChartCategory>? categories) {
  if (categories != null && categories.any((PlassChartCategory one) => one.date != null)) {
    return true;
  }

  return values.any((List<ChartValue> one) => one.any((ChartValue value) => value.x?.date != null));
}

/// Where one point sits along a category axis that runs on numbers.
///
/// The same three sources [categoryAt] reads, in the same order — but per
/// *point* rather than per column, because on a scatter each series has its own
/// x at every index and there is no column for them to share.
double? pointX(ChartValue value, int index, List<PlassChartCategory>? categories) {
  final PlassChartCategory own =
      value.x ??
      (categories != null && index < categories.length
          ? categories[index]
          : PlassChartCategory.number(index.toDouble()));

  return categoryNumber(own);
}

/// The extent of the category values, for a chart whose x is a number.
///
/// Only points that have a `y` count. A point with no value is not on the plot,
/// so letting its `x` stretch the axis would leave a margin of empty plot
/// standing in for data that was never drawn.
ChartExtent? categoryExtent(List<List<ChartValue>> values, List<PlassChartCategory>? categories) {
  double min = double.infinity;
  double max = double.negativeInfinity;
  bool seen = false;

  for (final List<ChartValue> one in values) {
    for (int i = 0; i < one.length; i += 1) {
      if (one[i].value == null) {
        continue;
      }

      final double? x = pointX(one[i], i, categories);

      if (x == null) {
        continue;
      }

      seen = true;
      min = math.min(min, x);
      max = math.max(max, x);
    }
  }

  return seen ? ChartExtent(min, max) : null;
}

/// The radius a bubble gets for its `z`, in pixels.
///
/// `z` is an **area** and not a radius, which is the single most common way a
/// bubble chart lies: encode it as a radius and a value twice as large draws a
/// mark four times the size. The square root is what makes the ink on the page
/// proportional to the number behind it.
///
/// [min] is a floor rather than a scale — a bubble for a small-but-real value
/// has to stay something a pointer can find, and a zero is the only thing
/// allowed to disappear.
double bubbleRadius(double z, double maxZ, double max, double min) {
  if (!(maxZ > 0) || z.isNaN || z.isInfinite || z <= 0) {
    return z == 0 ? 0 : min;
  }

  return math.max(min, math.sqrt(math.min(z, maxZ) / maxZ) * max);
}

/// The extent of the values, with the stacking rule applied.
///
/// Stacked charts measure the *totals* and not the parts, and the two arms are
/// accumulated separately so a series that goes negative does not shorten the
/// bar above it. An all-null chart has no extent at all, which is what the
/// `null` return says — the caller draws its empty state rather than an axis
/// from infinity to negative infinity.
ChartExtent? extentOf(List<List<ChartValue>> values, {required bool stacked}) {
  double min = double.infinity;
  double max = double.negativeInfinity;
  bool seen = false;

  if (stacked) {
    final int length = values.fold<int>(
      0,
      (int most, List<ChartValue> one) => math.max(most, one.length),
    );

    for (int i = 0; i < length; i += 1) {
      double positive = 0;
      double negative = 0;

      for (final List<ChartValue> one in values) {
        final double? value = i < one.length ? one[i].value : null;

        if (value == null) {
          continue;
        }

        seen = true;

        if (value >= 0) {
          positive += value;
        } else {
          negative += value;
        }
      }

      min = math.min(min, negative);
      max = math.max(max, positive);
    }
  } else {
    for (final List<ChartValue> one in values) {
      for (final ChartValue entry in one) {
        if (entry.value == null) {
          continue;
        }

        seen = true;
        min = math.min(min, entry.value!);
        max = math.max(max, entry.value!);
      }
    }
  }

  return seen ? ChartExtent(min, max) : null;
}

/* ---------------------------------------------------------------------------
 * Ticks
 * ------------------------------------------------------------------------- */

/// 1, 2, 5, 10 — the steps a reader can do arithmetic on in their head.
double niceStep(double rough) {
  final double magnitude = math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
  final double normalised = rough / magnitude;

  if (normalised <= 1) {
    return magnitude;
  }

  if (normalised <= 2) {
    return 2 * magnitude;
  }

  if (normalised <= 5) {
    return 5 * magnitude;
  }

  return 10 * magnitude;
}

/// A step that lands on both ends of a range the caller pinned.
///
/// When a scale is free to move, rounding the *ends* outward to the step is
/// what gives clean ticks. When both ends are given they cannot move, so the
/// step has to be the thing that gives — and a step that does not divide the
/// range leaves the top tick missing, which on a 99.5-to-100 axis means the one
/// number the reader came for is the one not written down.
///
/// So the 1-2-5 family is widened by a half step (2.5, 25, 250 — the divisor
/// every quarter-scale needs) and searched for the step that divides the range
/// exactly and comes closest to the tick count asked for.
double dividingStep(double range, int tickCount) {
  final double magnitude = math
      .pow(10, (math.log(range / math.max(1, tickCount)) / math.ln10).floor())
      .toDouble();
  double best = niceStep(range / math.max(1, tickCount));
  double closest = double.infinity;

  for (final double scale in <double>[0.1, 1, 10]) {
    for (final double unit in <double>[1, 2, 2.5, 5]) {
      final double step = unit * scale * magnitude;
      final double count = range / step;
      final double whole = count.roundToDouble();

      // The tolerance is a floating-point guard: 0.5 / 0.1 is 4.999999999999999.
      if (whole < 1 || (count - whole).abs() > 1e-9) {
        continue;
      }

      final double distance = (whole - tickCount).abs();

      if (distance < closest) {
        closest = distance;
        best = step;
      }
    }
  }

  return best;
}

/// A value scale: where it starts, where it ends, and what it ticks at.
class ValueScale {
  /// Creates a scale.
  const ValueScale(this.min, this.max, this.ticks);

  /// The bottom of the axis.
  final double min;

  /// The top.
  final double max;

  /// The clean numbers written along it.
  final List<double> ticks;

  /// A value as a fraction of the plot: `0` at [min] and `1` at [max].
  double fraction(double value) {
    final double span = max - min;

    return span == 0 ? 0 : (value - min) / span;
  }
}

/// A value axis whose steps are **multiplications** rather than additions.
///
/// The one scale in the library that changes what a distance on the plot means.
/// On a linear axis the same length is the same number of units wherever it is;
/// here it is the same *ratio* — the gap from 10 to 100 is the gap from 100 to
/// 1,000 — which is the only way a series that runs from 3 to 3,000,000 can be
/// drawn with the small end still legible.
///
/// There is no zero on it and nothing below it either, so [fraction] clamps:
/// a zero or a negative lands on the floor the axis chose, which is where the
/// axis ends rather than where the chart worked out the value belongs.
class LogScale extends ValueScale {
  /// Creates a log scale over a span already rounded to powers of ten.
  const LogScale(super.min, super.max, super.ticks);

  @override
  double fraction(double value) {
    final double span = _log10(max) - _log10(min);

    if (span == 0) {
      return 0;
    }

    return (_log10(value.clamp(min, max)) - _log10(min)) / span;
  }
}

double _log10(double value) => math.log(value) / math.ln10;

/// The scale a log axis runs on.
///
/// ## Zero, and everything under it
///
/// There is no such place. A logarithm has no value at zero and none at all
/// below it, so an axis whose data reaches either cannot simply be stretched to
/// hold them. What happens instead is stated rather than hidden: the axis
/// floors at the smallest **positive** power of ten the data needs, or three
/// decades under the top when the data offers no positive value to floor at,
/// and a zero or a negative is drawn on that floor.
///
/// ## The ticks
///
/// Powers of ten, because those are the numbers a reader can multiply in their
/// head. Over a short span — two decades or fewer, where whole decades would
/// leave an axis with three labels on it — each decade also gets its 2 and its
/// 5, which is the same 1-2-5 family [niceStep] picks from and for the same
/// reason. Over a long one the decades are thinned by stride instead. The React
/// build answers with `logScale`.
LogScale logScale(ChartExtent? extent, {double? min, double? max, int tickCount = 5}) {
  final double top = math.max(max ?? (extent?.max ?? 1), 1e-12);
  final double asked = min ?? (extent?.min ?? top / 1000);
  // Three decades under the top is the fallback, and it is a *choice* rather
  // than an answer: the data gave the axis nothing positive to stand on.
  final double floor = asked > 0 ? asked : top / 1000;

  final int lowExp = _log10(floor).floor();
  final int highExp = _log10(top).ceil();
  final double low = math.pow(10, lowExp).toDouble();
  final double high = math.pow(10, math.max(highExp, lowExp + 1)).toDouble();

  final double span = _log10(high) - _log10(low);
  final List<double> ticks = <double>[];

  if (span <= 2) {
    for (int exponent = lowExp; exponent <= _log10(high) + 1e-9; exponent += 1) {
      for (final int mantissa in <int>[1, 2, 5]) {
        final double tick = mantissa * math.pow(10, exponent).toDouble();

        if (tick >= low - 1e-12 && tick <= high + 1e-12) {
          ticks.add(tick);
        }
      }
    }
  } else {
    final int stride = math.max(1, (span / math.max(1, tickCount - 1)).round());

    for (int exponent = lowExp; exponent <= _log10(high) + 1e-9; exponent += stride) {
      ticks.add(math.pow(10, exponent).toDouble());
    }
  }

  if (ticks.isEmpty || ticks.last != high) {
    ticks.add(high);
  }

  return LogScale(low, high, ticks);
}

/// The scale a value axis runs on, rounded out to clean numbers.
///
/// Rounding *outward* is the part that matters: a maximum of 4,830 becomes
/// 5,000 and not 4,830, so the top tick is a number and the tallest bar stops
/// short of the ceiling. A scale whose last bar touches the frame reads as
/// clipped even when it is exactly right.
///
/// Zero is included unless the caller says otherwise, because bar length is
/// only proportional to value when the baseline is zero. A line chart of a
/// quantity that never approaches zero is the case for passing [min] — and it
/// is a case the caller has to make, not one the chart makes for them.
ValueScale valueScale(
  ChartExtent? extent, {
  double? min,
  double? max,
  int tickCount = 5,
  bool includeZero = true,
}) {
  double low = min ?? (extent?.min ?? 0);
  double high = max ?? (extent?.max ?? 1);

  if (includeZero && min == null) {
    low = math.min(low, 0);
  }

  if (includeZero && max == null) {
    high = math.max(high, 0);
  }

  // A flat series — every value the same — has no extent to divide by. Open a
  // band around it rather than dividing by zero and drawing a line off the top.
  // Only the ends the caller left free move: `min: 0` over a row of zeros is an
  // axis that starts at zero, not one that opens below it.
  if (high == low) {
    final double pad = high.abs() > 0 ? high.abs() * 0.5 : 1;

    if (min == null || max != null) {
      low -= pad;
    }

    if (max == null || min != null) {
      high += pad;
    }
  }

  // Both ends pinned means the *step* is what has to give; otherwise it is the
  // ends that round outward to a step chosen from the data.
  final bool pinned = min != null && max != null;
  final double step = pinned
      ? dividingStep(high - low, tickCount)
      : niceStep((high - low) / math.max(1, tickCount));

  final double start = min ?? (low / step).floorToDouble() * step;
  final double end = max ?? (high / step).ceilToDouble() * step;

  final ticks = <double>[];

  // The epsilon is a floating-point guard, not a fudge: 0.1 × 3 lands at
  // 0.30000000000000004, which without it drops the last tick off every scale
  // whose step is not a power of two.
  for (double tick = start; tick <= end + step * 1e-9; tick += step) {
    // And the rounding is the other half of it — a tick printed as
    // `0.30000000000000004` is worse than a missing one.
    ticks.add(double.parse(tick.toStringAsFixed(12)));
  }

  return ValueScale(start, end, ticks);
}

/* ---------------------------------------------------------------------------
 * Labels
 * ------------------------------------------------------------------------- */

/// How many labels to skip so the ones that survive clear each other.
///
/// Every nth label rather than rotating them: a rotated axis is unreadable at a
/// glance and it steals a band of the plot to be unreadable in. `n` is chosen
/// so the labels clear each other at the measured width, and it always keeps
/// the first — a reader who cannot see where the axis starts cannot read any of
/// it.
int tickStride(int count, double available, double labelWidth) {
  if (count <= 1 || available <= 0) {
    return 1;
  }

  final int fits = math.max(1, (available / math.max(1, labelWidth)).floor());

  return math.max(1, (count / fits).ceil());
}

/// Whether the label at [index] survives the stride.
///
/// Every nth, and — when it fits — the last one, which is the part a plain
/// modulo gets wrong: a fourteen-day axis at a stride of two ends at day
/// thirteen, and a percentage axis ends at 80%. The end of a scale is the
/// number a reader looks for first, and dropping it to keep the arithmetic tidy
/// is the wrong trade.
bool showsTick(int index, int count, int stride, {required bool roomForLast}) {
  return index % stride == 0 || (roomForLast && index == count - 1);
}

/// Whether the last label clears the last one the stride kept.
///
/// The two are `(count - 1) % stride` steps apart, and they need half of each
/// label plus a little air between them — labels are centred on their tick, so
/// only the inner halves can collide.
bool fitsLast(int count, int stride, double step, double labelWidth) {
  final int over = (count - 1) % stride;

  return over > 0 && over * step >= labelWidth + 8;
}

/// Roughly how wide a string renders at a given font size.
///
/// An estimate on purpose. The alternative is laying every label out with a
/// `TextPainter` on a path that runs on every resize — and what this number is
/// used for is deciding how much room to reserve, where being a few pixels
/// generous costs nothing and being exact costs a relayout.
///
/// 0.6em is the average advance of a digit in the sans-serifs a UI runs in;
/// anything CJK is close to a full em, so the widest character decides. The
/// same estimate the React build makes, so the two reserve the same band.
double textWidth(String text, double fontSize) {
  double width = 0;

  for (final int code in text.runes) {
    final bool wide =
        (code >= 0x1100 && code <= 0x11FF) ||
        (code >= 0x2E80 && code <= 0xA4CF) ||
        (code >= 0xAC00 && code <= 0xD7FF) ||
        (code >= 0xF900 && code <= 0xFAFF) ||
        (code >= 0xFE30 && code <= 0xFE4F);

    width += wide ? 1 : 0.6;
  }

  return width * fontSize;
}

/// A label cut to the room it has, with an ellipsis.
///
/// The alternative when a category name is wider than its slot is to drop
/// labels until the survivors fit, and on five categories called things like
/// "Onboarding flow" that leaves exactly one of them on the axis — an axis with
/// one label is not a shorter axis, it is an unlabelled one.
String truncateLabel(String text, double maxWidth, double fontSize) {
  if (maxWidth <= 0 || textWidth(text, fontSize) <= maxWidth) {
    return text;
  }

  final double room = maxWidth - textWidth('…', fontSize);
  final buffer = StringBuffer();
  double width = 0;

  for (final int code in text.runes) {
    final String character = String.fromCharCode(code);
    final double next = width + textWidth(character, fontSize);

    if (next > room) {
      break;
    }

    width = next;
    buffer.write(character);
  }

  final String cut = buffer.toString().trimRight();

  return cut.isEmpty ? '…' : '$cut…';
}

/// The category labels as the axis writes them.
///
/// A long name is cut to its slot rather than labels being dropped until the
/// rest fit. Once a slot is narrower than about four characters a cut stops
/// helping, and the axis thins its labels out by stride instead. The ticks of a
/// value-scaled axis are numbers already rounded to be short, so [ticks] leaves
/// them whole. The React build answers with `fitCategoryLabels`.
List<String> fitCategoryLabels(
  List<String> texts, {
  required bool horizontal,
  required double slot,
  required double fontSize,
  required bool ticks,
}) {
  if (ticks || (!horizontal && slot - 6 < fontSize * 2.4)) {
    return texts;
  }

  return <String>[
    for (final String text in texts) truncateLabel(text, horizontal ? 150 : slot - 6, fontSize),
  ];
}

/* ---------------------------------------------------------------------------
 * Turned labels
 *
 * A category axis runs out of room in one direction only: across. Cutting a
 * name to its slot keeps every label on the axis, and past about four
 * characters it stops being an answer at all — "Onboar…", "Onboa…" and "Onbo…"
 * are three labels a reader cannot tell apart. Turning them is the other
 * answer: a label on its side takes one line of text across the axis however
 * long it is, and spends the room down the page instead.
 *
 * A label turned by an angle is a rectangle `width × fontSize` rotated about
 * its anchor, so what it takes in each direction is that rectangle's projection
 * onto the direction — which is where the sines and cosines come from, and why
 * a quarter turn costs exactly one line of text across and the whole label
 * down. The React build answers with `tickAngleOf`, `tiltedDepth`,
 * `tiltedStep` and `tiltedRoom`.
 * ------------------------------------------------------------------------ */

/// A caller's tick angle as the axis uses it: degrees, and never past a quarter
/// turn either way.
///
/// Past 90° a label is upside down, which is not a label. `-45` is the one to
/// reach for, and the sign is which way the text leans: negative runs it up
/// towards the right, the way every chart that has ever done this draws it.
double tickAngleOf(double? angle) {
  if (angle == null || !angle.isFinite) {
    return 0;
  }

  return angle.clamp(-90.0, 90.0);
}

/// The angle `PlChartAxis.autoTickAngle` settles on, which is a diagonal or
/// nothing at all.
///
/// The question it answers is the one a caller would otherwise answer by
/// looking: *would any of these names be cut?* If none of them would, upright
/// is the best an axis can do — it is the one angle that reads without the head
/// moving — and turning them would be spending the plot's height on a problem
/// the chart does not have. As soon as one name is wider than its slot, cutting
/// is the alternative, and a diagonal beats a cut at every width.
///
/// Deliberately not a *continuous* answer. An angle worked out to fit the
/// longest name exactly would be a different angle on every chart on a
/// dashboard, and would change under the reader as the window is resized; -45°
/// is the one every chart that does this has settled on, and holding it still
/// is worth more than the pixels a bespoke angle would save.
double autoTickAngle(List<String> texts, {required double slot, required double fontSize}) {
  final double room = slot - 6;

  return texts.any((String text) => textWidth(text, fontSize) > room) ? -45 : 0;
}

/// How deep a band of labels turned by [angle] is, away from the axis.
double tiltedDepth(double widest, double angle, double fontSize) {
  final double radians = angle.abs() * math.pi / 180;

  return math.sin(radians).abs() * widest + math.cos(radians).abs() * fontSize;
}

/// And how far off its own tick it reaches, along the axis.
///
/// What the two ends of the axis have to keep clear, so the first and the last
/// name are not cut off at the edge of the drawing.
double tiltedStep(double width, double angle, double fontSize) {
  final double radians = angle.abs() * math.pi / 180;

  return math.cos(radians).abs() * width + math.sin(radians).abs() * fontSize;
}

/// The least room two turned labels can sit in along the axis without touching.
///
/// And **not** [tiltedStep], which is the mistake this is here to avoid. Two
/// labels turned by the same angle are parallel, so what has to clear between
/// them is not their length but the distance *across* them — which is the step
/// along the axis times the sine of the angle. Read the other way round, that
/// is the step one line of text needs, and it is why a turned axis fits so many
/// more labels than an upright one: at a quarter turn the answer is one line of
/// text, whatever the names happen to say.
double tiltedPitch(double angle, double fontSize) {
  final double radians = angle.abs() * math.pi / 180;

  return fontSize * 1.35 / math.max(math.sin(radians).abs(), 0.09);
}

/// How long a turned label may be before it is cut, given the [depth] the axis
/// is willing to spend on its band.
///
/// A turned label is not confined to its slot any more, so nothing else stops a
/// forty-character name taking half the drawing. The depth is what is rationed,
/// and this reads the length back out of it. The floor on the sine keeps a
/// barely-turned label from being handed a budget of several thousand pixels.
double tiltedRoom(double depth, double angle, double fontSize) {
  final double radians = angle.abs() * math.pi / 180;

  return math.max(
    fontSize * 3,
    (depth - math.cos(radians).abs() * fontSize) / math.max(math.sin(radians).abs(), 0.09),
  );
}

/* ---------------------------------------------------------------------------
 * Geometry
 * ------------------------------------------------------------------------- */

/// A band scale: one slot per category, with the marks centred in it.
class BandScale {
  /// Creates a band scale over [length] with [count] slots.
  BandScale(int count, double length, double ratio)
    : step = count > 0 ? length / count : length,
      band = (count > 0 ? length / count : length) * ratio;

  /// How wide one slot is.
  final double step;

  /// How wide the marks in a slot are allowed to be, together.
  final double band;

  /// The centre of category [index], in pixels along the axis.
  double centre(int index) => step * (index + 0.5);
}

/// How a line gets from one point to the next.
enum PlChartCurve {
  /// Straight segments. The only one that claims nothing the data did not say.
  linear,

  /// A monotone cubic — curved, but never dipping below a value both of its
  /// neighbours are above.
  smooth,

  /// Held at each value until the next one.
  step,
}

/// A path through the points, in whichever of the three shapes was asked for.
///
/// A `null` **breaks** the path rather than interpolating across it: the
/// `moveTo` that starts a new subpath is the gap. A line that bridges a missing
/// month is a line that invents a number.
///
/// [PlChartCurve.smooth] is a monotone cubic and not a Catmull-Rom, which is
/// not a detail: a plain spline overshoots between two close points, so a
/// series that never goes below zero draws a curve that does. A chart is
/// allowed to be curved and it is not allowed to show a value that is not in
/// the data.
Path linePath(List<Offset?> points, PlChartCurve curve) {
  final path = Path();
  var run = <Offset>[];

  void flush() {
    if (run.isEmpty) {
      return;
    }

    if (run.length == 1) {
      // A lone point between two gaps has no line to be part of. A
      // zero-length stroke renders under a round cap as the dot it is.
      path
        ..moveTo(run.first.dx, run.first.dy)
        ..lineTo(run.first.dx, run.first.dy);
    } else if (curve == PlChartCurve.step) {
      path.moveTo(run.first.dx, run.first.dy);

      for (int i = 1; i < run.length; i += 1) {
        final double middle = (run[i - 1].dx + run[i].dx) / 2;

        path
          ..lineTo(middle, run[i - 1].dy)
          ..lineTo(middle, run[i].dy)
          ..lineTo(run[i].dx, run[i].dy);
      }
    } else if (curve == PlChartCurve.smooth) {
      path.moveTo(run.first.dx, run.first.dy);
      _monotone(path, run);
    } else {
      path.moveTo(run.first.dx, run.first.dy);

      for (int i = 1; i < run.length; i += 1) {
        path.lineTo(run[i].dx, run[i].dy);
      }
    }

    run = <Offset>[];
  }

  for (final Offset? point in points) {
    if (point == null) {
      flush();
    } else {
      run.add(point);
    }
  }

  flush();

  return path;
}

/// The cubic segments of a monotone interpolation.
///
/// Fritsch–Carlson: the tangent at each point is a harmonic mean of the slopes
/// either side of it, clamped to zero wherever they disagree in sign. That
/// clamp is what makes the curve monotone — it is why a run of increasing
/// values never dips on its way up, and why a minimum in the data is the
/// minimum on screen.
void _monotone(Path path, List<Offset> points) {
  final int n = points.length;
  final slopes = <double>[];

  for (int i = 0; i < n - 1; i += 1) {
    final double dx = points[i + 1].dx - points[i].dx;

    slopes.add(dx == 0 ? 0 : (points[i + 1].dy - points[i].dy) / dx);
  }

  final tangents = <double>[slopes.isEmpty ? 0 : slopes.first];

  for (int i = 1; i < n - 1; i += 1) {
    final double before = slopes[i - 1];
    final double after = slopes[i];

    tangents.add(before * after <= 0 ? 0 : (2 * before * after) / (before + after));
  }

  tangents.add(slopes.isEmpty ? 0 : slopes[n - 2]);

  for (int i = 0; i < n - 1; i += 1) {
    final double dx = (points[i + 1].dx - points[i].dx) / 3;

    path.cubicTo(
      points[i].dx + dx,
      points[i].dy + tangents[i] * dx,
      points[i + 1].dx - dx,
      points[i + 1].dy - tangents[i + 1] * dx,
      points[i + 1].dx,
      points[i + 1].dy,
    );
  }
}

/// The same path closed back along a second edge, for an area.
///
/// Two lists rather than a path and a number, because a stacked band's floor is
/// the band below it and moves with every category. Built from the runs rather
/// than from the whole line so a gap is a gap in the fill too — an area that
/// closes across a missing month fills in a value that was never measured,
/// which is the same lie the bridged line tells, painted over a larger part of
/// the chart.
Path areaPath(List<Offset?> top, List<Offset?> under, PlChartCurve curve) {
  final path = Path();
  var run = <int>[];

  void flush() {
    if (run.length < 2) {
      run = <int>[];

      return;
    }

    final List<Offset?> above = <Offset?>[for (final int i in run) top[i]];
    final List<Offset?> below = <Offset?>[for (final int i in run.reversed) under[i]];

    // One contour: the top, then the floor walked back with the same curve, so
    // a smoothed or stepped band and the band under it agree about where the
    // edge is between two points. `extendWithPath` joins the floor on with a
    // line where `addPath` would start a second contour, and two open contours
    // fill only the slivers between each edge and its own chord.
    path
      ..addPath(linePath(above, curve), Offset.zero)
      ..extendWithPath(linePath(below, curve), Offset.zero)
      ..close();

    run = <int>[];
  }

  for (int i = 0; i < top.length; i += 1) {
    if (i >= under.length || top[i] == null || under[i] == null) {
      flush();
    } else {
      run.add(i);
    }
  }

  flush();

  return path;
}

/// Which end of a bar its value is at, and so which corners are cut.
enum PlBarEnd {
  /// A vertical bar growing upward.
  up,

  /// One growing downward, for a negative value.
  down,

  /// A horizontal bar growing toward the ending edge.
  right,

  /// One growing toward the starting edge.
  left,
}

/// One bar, with the corners cut off its **data** end only.
///
/// The baseline end stays square: that is where the value starts from, and a
/// rounded foot makes the axis look scalloped. The radius is clamped to half
/// the bar in both directions, so a bar shorter than its own corner comes out
/// as a lozenge rather than as a shape turned inside out.
Path barPath(double x, double y, double width, double height, double radius, PlBarEnd end) {
  final double r = math.max(0, math.min(radius, math.min(width / 2, height / 2)));
  final rect = Rect.fromLTWH(x, y, width, height);

  if (r == 0 || width <= 0 || height <= 0) {
    return Path()..addRect(rect);
  }

  final zero = Radius.zero;
  final round = Radius.circular(r);

  return Path()..addRRect(switch (end) {
    PlBarEnd.up => RRect.fromRectAndCorners(
      rect,
      topLeft: round,
      topRight: round,
      bottomLeft: zero,
      bottomRight: zero,
    ),
    PlBarEnd.down => RRect.fromRectAndCorners(
      rect,
      topLeft: zero,
      topRight: zero,
      bottomLeft: round,
      bottomRight: round,
    ),
    PlBarEnd.right => RRect.fromRectAndCorners(
      rect,
      topLeft: zero,
      topRight: round,
      bottomLeft: zero,
      bottomRight: round,
    ),
    PlBarEnd.left => RRect.fromRectAndCorners(
      rect,
      topLeft: round,
      topRight: zero,
      bottomLeft: round,
      bottomRight: zero,
    ),
  });
}

/// The shapes a marker is drawn in, in the order they are handed out.
///
/// A second channel beside the hue, for a reader who cannot separate two of the
/// eight. Five, because past that a dot can be anything.
enum PlChartMarkShape {
  /// The default, and the only one that reads at any size.
  circle,

  /// Series two.
  square,

  /// Series three.
  triangle,

  /// Series four.
  diamond,

  /// Series five, and the last shape that is still a shape at 6px.
  cross,
}

/// The order shapes are handed out in, matching the palette: fixed, never
/// cycled.
const List<PlChartMarkShape> markShapes = <PlChartMarkShape>[
  PlChartMarkShape.circle,
  PlChartMarkShape.square,
  PlChartMarkShape.triangle,
  PlChartMarkShape.diamond,
  PlChartMarkShape.cross,
];

/// How much bigger than a circle of the same area each shape has to be drawn.
///
/// Equal *area*, not equal radius, and that is the whole reason this table
/// exists rather than five hand-picked numbers. On a bubble chart the area is
/// already carrying a magnitude, so a square that covers a third more ink than
/// the circle beside it is a square reporting a value it was not given. Solved
/// from `πr²`: a square's half-side is `r√π/2`, a diamond's half-diagonal
/// `r√(π/2)`, an equilateral triangle's circumradius `r√(4π/3√3)`, and a plus
/// whose arm is two thirds of its half-span `r√(9π/20)`.
const Map<PlChartMarkShape, double> _shapeScale = <PlChartMarkShape, double>{
  PlChartMarkShape.circle: 1,
  PlChartMarkShape.square: 0.8862,
  PlChartMarkShape.triangle: 1.5551,
  PlChartMarkShape.diamond: 1.2533,
  PlChartMarkShape.cross: 1.189,
};

/// One marker, centred on a point and covering the same area a circle of radius
/// [r] would.
Path markPath(PlChartMarkShape shape, double cx, double cy, double r) {
  final path = Path();
  final double size = math.max(0, r) * _shapeScale[shape]!;

  if (size == 0) {
    return path;
  }

  switch (shape) {
    case PlChartMarkShape.circle:
      path.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: size));
    case PlChartMarkShape.square:
      path.addRect(Rect.fromCenter(center: Offset(cx, cy), width: size * 2, height: size * 2));
    case PlChartMarkShape.triangle:
      // Sat on its circumcircle rather than on a bounding box, so it shares a
      // centre with the other four — a triangle centred on its box sits low,
      // and a row of markers would then not line up with the row of dots beside
      // it.
      for (int corner = 0; corner < 3; corner += 1) {
        final double radians = (corner * 120 - 90) * math.pi / 180;
        final double x = cx + size * math.cos(radians);
        final double y = cy + size * math.sin(radians);

        if (corner == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      path.close();
    case PlChartMarkShape.diamond:
      path
        ..moveTo(cx, cy - size)
        ..lineTo(cx + size, cy)
        ..lineTo(cx, cy + size)
        ..lineTo(cx - size, cy)
        ..close();
    case PlChartMarkShape.cross:
      // One outline of twelve corners rather than two overlapping rectangles,
      // which is what the React build writes: outlined separately, each
      // rectangle is stroked all the way round, so the ring draws a cross
      // through the middle of the mark.
      final double arm = size / 3;
      path
        ..moveTo(cx - arm, cy - size)
        ..lineTo(cx + arm, cy - size)
        ..lineTo(cx + arm, cy - arm)
        ..lineTo(cx + size, cy - arm)
        ..lineTo(cx + size, cy + arm)
        ..lineTo(cx + arm, cy + arm)
        ..lineTo(cx + arm, cy + size)
        ..lineTo(cx - arm, cy + size)
        ..lineTo(cx - arm, cy + arm)
        ..lineTo(cx - size, cy + arm)
        ..lineTo(cx - size, cy - arm)
        ..lineTo(cx - arm, cy - arm)
        ..close();
  }

  return path;
}

/* ---------------------------------------------------------------------------
 * Arcs
 * ------------------------------------------------------------------------- */

/// The centre line of a band, as an open arc.
///
/// What [arcPath] draws as a filled shape, this draws as a line to be stroked —
/// which is the difference between a dial that jumps to each new reading and
/// one that sweeps to it. A wedge's outline changes with the value, and an
/// outline is not something a length can travel along; a stroke's drawn length
/// is one number.
Path ringPath(double cx, double cy, double radius, double from, double to) {
  final Rect box = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
  final double start = (from - 90) * math.pi / 180;
  final double sweep = (to - from) * math.pi / 180;

  // A whole turn is two half-arcs for the reason a whole wedge is two ovals:
  // one arc whose ends meet draws nothing.
  if (sweep.abs() >= 2 * math.pi) {
    return Path()
      ..arcTo(box, start, math.pi, true)
      ..arcTo(box, start + math.pi, math.pi, false);
  }

  return Path()..arcTo(box, start, sweep, true);
}

/// A wedge, or a band between two radii, in degrees clockwise from twelve.
///
/// Degrees and not radians, and from the top and not from three o'clock,
/// because that is the frame a caller writes a `startAngle` in — the conversion
/// belongs in one place rather than at every call site. An [inner] of zero cuts
/// the wedge from the centre; anything above it leaves the middle open.
Path arcPath(double cx, double cy, double outer, double inner, double from, double to) {
  final Path path = Path();
  final Rect outerBox = Rect.fromCircle(center: Offset(cx, cy), radius: outer);

  // A whole turn cannot be one arc: the two ends are the same point, and the
  // rasteriser draws nothing at all. Two ovals with the even-odd rule are the
  // ring, and one oval is the disc.
  if ((to - from).abs() >= 360) {
    path.addOval(outerBox);

    if (inner > 0) {
      path
        ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: inner))
        ..fillType = PathFillType.evenOdd;
    }

    return path;
  }

  final double start = (from - 90) * math.pi / 180;
  final double sweep = (to - from) * math.pi / 180;

  if (inner <= 0) {
    return path
      ..moveTo(cx, cy)
      ..arcTo(outerBox, start, sweep, false)
      ..close();
  }

  // The second arc runs backwards, and the line into it is the radial edge —
  // which is why it is not forced to move: an arc that starts with a jump
  // leaves the band open along the side.
  return path
    ..arcTo(outerBox, start, sweep, true)
    ..arcTo(Rect.fromCircle(center: Offset(cx, cy), radius: inner), start + sweep, -sweep, false)
    ..close();
}

/* ---------------------------------------------------------------------------
 * Magnitude colour
 * ------------------------------------------------------------------------- */

/// Which way a magnitude is coloured.
enum PlChartScaleKind {
  /// One hue, pale to deep. Right whenever more is simply more.
  sequential,

  /// Two hues either side of a neutral, for a value with a *middle* that means
  /// something. Reached for on a plain magnitude it invents a boundary the data
  /// has none of.
  diverging,
}

/// How many steps each ramp has. Five, and the reason is in `styles.css`.
const int rampSteps = 5;

/// The step a value lands on.
///
/// A magnitude is not an identity, so it does not come off the eight-slot
/// categorical ramp. It comes off a one-hue ladder, and which rung is
/// arithmetic on the value.
///
/// A diverging scale is read from its *middle* rather than from its bottom, so
/// it is the distance either side of the neutral that is scaled — and by the
/// larger of the two arms, so a set running from −2 to +40 does not paint every
/// negative the deepest blue there is.
int rampStep(double value, double min, double max, PlChartScaleKind kind, {double midpoint = 0}) {
  if (kind == PlChartScaleKind.diverging) {
    final double reach = math.max((max - midpoint).abs(), (midpoint - min).abs());

    if (!(reach > 0)) {
      return 2;
    }

    // Two rungs each side of the neutral, which is the middle rung.
    return math.min(4, math.max(0, 2 + (value - midpoint) / reach * 2).round());
  }

  final double span = max - min;

  if (!(span > 0)) {
    return rampSteps - 1;
  }

  return math.min(rampSteps - 1, math.max(0, ((value - min) / span * rampSteps).floor()));
}

/* ---------------------------------------------------------------------------
 * Treemap
 * ------------------------------------------------------------------------- */

/// One tile, in pixels, and which value it came from.
class TreemapTile {
  /// Creates a tile.
  const TreemapTile({required this.index, required this.rect});

  /// Its place in the list as it was passed.
  final int index;

  /// Where it goes.
  final Rect rect;
}

/// A squarified treemap: the values as boxes whose areas are proportional, laid
/// out as close to square as they can be got.
///
/// Squarified rather than sliced, and the difference is the whole reason the
/// forty lines are worth it. A slice-and-dice treemap of twenty values ends in
/// slivers a pixel wide, and a sliver's *area* is unreadable however exact it
/// is — the reader compares its length instead, which is not the encoded
/// quantity. Bruls, Huizing and van Wijk's answer is greedy and simple: fill a
/// row along the box's shorter side, keep adding to it while the worst aspect
/// ratio in it improves, and start a new row the moment it stops.
///
/// The order is the caller's; the layout sorts descending internally because
/// the algorithm needs it and hands the original index back on every tile, so a
/// tile's colour and its name are still its own.
List<TreemapTile> squarify(List<double> values, double width, double height) {
  double total = 0;

  for (final double value in values) {
    total += math.max(0, value);
  }

  if (!(total > 0) || width <= 0 || height <= 0) {
    return <TreemapTile>[];
  }

  final double scale = width * height / total;
  final items =
      <_Area>[
        for (int i = 0; i < values.length; i += 1)
          if (math.max(0, values[i]) * scale > 0) _Area(i, math.max(0, values[i]) * scale),
      ]..sort((_Area a, _Area b) {
        final int byArea = b.area.compareTo(a.area);

        // Ties keep the order they were given, which is what a JavaScript `sort`
        // is required to do and what the React build gets for nothing. Dart's is
        // a quicksort past thirty-two items, so without this two tiles of the
        // same value could swap places and take each other's colour.
        return byArea != 0 ? byArea : a.index.compareTo(b.index);
      });

  final tiles = <TreemapTile>[];

  double x = 0;
  double y = 0;
  double boxWidth = width;
  double boxHeight = height;
  var row = <_Area>[];

  /// The worst aspect ratio in a row laid along the current short side.
  double worst(List<_Area> candidate) {
    final double side = math.min(boxWidth, boxHeight);
    double sum = 0;

    for (final _Area one in candidate) {
      sum += one.area;
    }

    if (!(sum > 0) || !(side > 0)) {
      return double.infinity;
    }

    // Sorted descending, so the first is the largest and the last the smallest.
    return math.max(
      side * side * candidate.first.area / (sum * sum),
      sum * sum / (side * side * candidate.last.area),
    );
  }

  void place() {
    double sum = 0;

    for (final _Area one in row) {
      sum += one.area;
    }

    final double side = math.min(boxWidth, boxHeight);
    final double thickness = side > 0 ? sum / side : 0;
    final bool across = boxWidth >= boxHeight;
    double along = 0;

    for (final _Area one in row) {
      final double length = thickness > 0 ? one.area / thickness : 0;

      tiles.add(
        TreemapTile(
          index: one.index,
          rect: across
              ? Rect.fromLTWH(x, y + along, thickness, length)
              : Rect.fromLTWH(x + along, y, length, thickness),
        ),
      );

      along += length;
    }

    if (across) {
      x += thickness;
      boxWidth -= thickness;
    } else {
      y += thickness;
      boxHeight -= thickness;
    }

    row = <_Area>[];
  }

  for (final _Area one in items) {
    if (row.isEmpty || worst(<_Area>[...row, one]) <= worst(row)) {
      row.add(one);
    } else {
      place();
      row.add(one);
    }
  }

  if (row.isNotEmpty) {
    place();
  }

  return tiles;
}

/// A value's area, and where it came from.
class _Area {
  const _Area(this.index, this.area);

  final int index;
  final double area;
}

/* ---------------------------------------------------------------------------
 * Time
 * ------------------------------------------------------------------------- */

/// The units a clock and a calendar are read in.
enum PlChartTimeUnit {
  /// Seconds.
  second,

  /// Minutes.
  minute,

  /// Hours.
  hour,

  /// Days.
  day,

  /// Weeks.
  week,

  /// Months.
  month,

  /// Quarters.
  quarter,

  /// Years.
  year,
}

const int _second = 1000;
const int _minute = 60 * _second;
const int _hour = 60 * _minute;
const int _day = 24 * _hour;

/// One step a time axis may tick in.
class _TimeStep {
  const _TimeStep(this.unit, this.count, this.size);

  final PlChartTimeUnit unit;
  final int count;
  final int size;
}

/// The steps a clock and a calendar actually have, smallest first.
///
/// [niceStep]'s 1-2-5 is the right family for a count and the wrong one for an
/// instant: run on a millisecond number it produces a tick every 200,000,000
/// ms, which lands at 14:53:20 on an arbitrary Tuesday. Nobody reads that. Time
/// is not decimal below the year — sixty, sixty, twenty-four, seven, twelve —
/// so the steps are written down rather than derived.
///
/// The size is only how a step is *chosen*: months and years are not a fixed
/// number of milliseconds, so the ticks themselves are walked with a calendar.
const List<_TimeStep> _timeSteps = <_TimeStep>[
  _TimeStep(PlChartTimeUnit.second, 1, _second),
  _TimeStep(PlChartTimeUnit.second, 5, 5 * _second),
  _TimeStep(PlChartTimeUnit.second, 15, 15 * _second),
  _TimeStep(PlChartTimeUnit.second, 30, 30 * _second),
  _TimeStep(PlChartTimeUnit.minute, 1, _minute),
  _TimeStep(PlChartTimeUnit.minute, 5, 5 * _minute),
  _TimeStep(PlChartTimeUnit.minute, 15, 15 * _minute),
  _TimeStep(PlChartTimeUnit.minute, 30, 30 * _minute),
  _TimeStep(PlChartTimeUnit.hour, 1, _hour),
  _TimeStep(PlChartTimeUnit.hour, 3, 3 * _hour),
  _TimeStep(PlChartTimeUnit.hour, 6, 6 * _hour),
  _TimeStep(PlChartTimeUnit.hour, 12, 12 * _hour),
  _TimeStep(PlChartTimeUnit.day, 1, _day),
  _TimeStep(PlChartTimeUnit.day, 2, 2 * _day),
  _TimeStep(PlChartTimeUnit.week, 1, 7 * _day),
  _TimeStep(PlChartTimeUnit.week, 2, 14 * _day),
  _TimeStep(PlChartTimeUnit.month, 1, 30 * _day),
  _TimeStep(PlChartTimeUnit.quarter, 1, 91 * _day),
  _TimeStep(PlChartTimeUnit.month, 6, 182 * _day),
  _TimeStep(PlChartTimeUnit.year, 1, 365 * _day),
];

/// The start of the unit that [time] falls in, in the reader's own timezone.
///
/// Local and not UTC, which is the whole reason this is calendar arithmetic
/// rather than a modulo: a tick labelled "Mar 3" has to sit at midnight where
/// the reader is, and an axis aligned to UTC puts it nine hours into the 2nd.
int _floorTime(int time, PlChartTimeUnit unit) {
  final DateTime at = DateTime.fromMillisecondsSinceEpoch(time);

  switch (unit) {
    case PlChartTimeUnit.year:
      return DateTime(at.year).millisecondsSinceEpoch;
    case PlChartTimeUnit.quarter:
      return DateTime(at.year, (at.month - 1) ~/ 3 * 3 + 1).millisecondsSinceEpoch;
    case PlChartTimeUnit.month:
      return DateTime(at.year, at.month).millisecondsSinceEpoch;
    case PlChartTimeUnit.week:
      // Dart counts Monday as 1 and Sunday as 7; the week starts on Sunday
      // here, matching the JavaScript build's `getDay`.
      return DateTime(at.year, at.month, at.day - (at.weekday % 7)).millisecondsSinceEpoch;
    case PlChartTimeUnit.day:
      return DateTime(at.year, at.month, at.day).millisecondsSinceEpoch;
    case PlChartTimeUnit.hour:
      return DateTime(at.year, at.month, at.day, at.hour).millisecondsSinceEpoch;
    // Floored towards negative infinity, which is what `Math.floor` does on
    // the web. `~/` truncates towards zero, so an instant before 1970 landed
    // on the minute *above* it and the axis started a minute later than the
    // React one.
    case PlChartTimeUnit.minute:
      return (time / _minute).floor() * _minute;
    case PlChartTimeUnit.second:
      return (time / _second).floor() * _second;
  }
}

/// [count] units on from [time], again by the calendar.
///
/// Adding 30 days is not adding a month and adding 365 is not adding a year, so
/// a scale that stepped in milliseconds would drift a day per leap year and
/// three per quarter. `DateTime`'s own rollover is correct, and it is also what
/// keeps a daily axis on midnight across a daylight-saving change.
int _addTime(int time, PlChartTimeUnit unit, int count) {
  final DateTime at = DateTime.fromMillisecondsSinceEpoch(time);

  switch (unit) {
    case PlChartTimeUnit.year:
      return DateTime(
        at.year + count,
        at.month,
        at.day,
        at.hour,
        at.minute,
        at.second,
      ).millisecondsSinceEpoch;
    case PlChartTimeUnit.quarter:
      return DateTime(at.year, at.month + 3 * count, at.day).millisecondsSinceEpoch;
    case PlChartTimeUnit.month:
      return DateTime(at.year, at.month + count, at.day).millisecondsSinceEpoch;
    case PlChartTimeUnit.week:
      return DateTime(at.year, at.month, at.day + 7 * count).millisecondsSinceEpoch;
    case PlChartTimeUnit.day:
      return DateTime(at.year, at.month, at.day + count).millisecondsSinceEpoch;
    case PlChartTimeUnit.hour:
      return DateTime(at.year, at.month, at.day, at.hour + count).millisecondsSinceEpoch;
    case PlChartTimeUnit.minute:
      return time + count * _minute;
    case PlChartTimeUnit.second:
      return time + count * _second;
  }
}

/// The container a step of this unit should be counted from.
///
/// A 6-month step floored only to a month starts wherever the data starts, and
/// an axis reading "Apr · Oct · Apr · Oct" has told the reader nothing about
/// where in the year they are. Counted from January it reads "Jan · Jul", which
/// is the same six months landing where a calendar already has a name for them.
const Map<PlChartTimeUnit, PlChartTimeUnit> _timeContainer = <PlChartTimeUnit, PlChartTimeUnit>{
  PlChartTimeUnit.second: PlChartTimeUnit.minute,
  PlChartTimeUnit.minute: PlChartTimeUnit.hour,
  PlChartTimeUnit.hour: PlChartTimeUnit.day,
  PlChartTimeUnit.day: PlChartTimeUnit.month,
  PlChartTimeUnit.week: PlChartTimeUnit.week,
  PlChartTimeUnit.month: PlChartTimeUnit.year,
  PlChartTimeUnit.quarter: PlChartTimeUnit.year,
  PlChartTimeUnit.year: PlChartTimeUnit.year,
};

/// The last step boundary at or before [time] — the axis' rounded-out start.
int _alignTime(int time, PlChartTimeUnit unit, int count) {
  int tick = _floorTime(time, _timeContainer[unit]!);

  if (unit == PlChartTimeUnit.year && count > 1) {
    // Decades start at 1990 and not at 1993, which is the same rule one step up.
    final int year = DateTime.fromMillisecondsSinceEpoch(tick).year;

    tick = DateTime(year - (year % count + count) % count).millisecondsSinceEpoch;
  }

  for (int i = 0; i < 500; i += 1) {
    final int next = _addTime(tick, unit, count);

    if (next > time) {
      return tick;
    }

    tick = next;
  }

  return tick;
}

/// A value scale whose numbers are instants, and the unit its ticks step in.
class TimeScale extends ValueScale {
  /// Creates a time scale.
  const TimeScale(super.min, super.max, super.ticks, this.unit, this.step);

  /// What a tick is a step of.
  final PlChartTimeUnit unit;

  /// How many of that unit each step covers — 1, 5, 15 minutes and so on.
  final int step;
}

/// The scale a time axis runs on, ticking where a calendar ticks.
///
/// The ends round *outward* to the step for the reason [valueScale]'s do: a
/// span that starts exactly on the left edge reads as clipped rather than as
/// starting there. Past a year the 1-2-5 family comes back, because above the
/// year time really is decimal — decades and centuries are the only units left.
TimeScale timeScale(ChartExtent? extent, {double? min, double? max, int tickCount = 6}) {
  int low = (min ?? extent?.min ?? DateTime(2000).millisecondsSinceEpoch.toDouble()).round();
  int high = (max ?? extent?.max ?? (low + _day).toDouble()).round();

  // A single instant is not a range. Open a day around it rather than dividing
  // by zero and drawing every mark on one pixel.
  if (high <= low) {
    low -= _day ~/ 2;
    high += _day ~/ 2;
  }

  final int span = high - low;

  /* The step whose tick count comes *closest* to the one asked for, rather than
     the largest that fits under it. "Largest that fits" is off by a factor of
     two every time the next step up is the better answer: five months at six
     ticks wants a month, and taking the biggest step under `span / 6` takes a
     fortnight and draws eleven. */
  _TimeStep chosen = _timeSteps.first;
  double closest = double.infinity;

  for (final _TimeStep candidate in _timeSteps) {
    final double distance = (span / candidate.size - tickCount).abs();

    if (distance < closest) {
      closest = distance;
      chosen = candidate;
    }
  }

  // Above a year the calendar has no more units to offer, so the step goes back
  // to 1-2-5 — counted in years, never in milliseconds.
  final PlChartTimeUnit unit = chosen.unit;
  final int count = unit == PlChartTimeUnit.year
      ? math.max(1, niceStep(span / tickCount / (365 * _day)).round())
      : chosen.count;

  final int start = min == null ? _alignTime(low, unit, count) : min.round();
  final ticks = <double>[];

  /* Walked rather than multiplied, so a month is a month. The loop runs one
     step past the data and keeps that step as the end, which is what rounds the
     axis outward at the top the way `_alignTime` rounded it at the bottom. */
  int tick = start;

  for (int i = 0; i < 500; i += 1) {
    ticks.add(tick.toDouble());

    if (tick > high) {
      break;
    }

    tick = _addTime(tick, unit, count);
  }

  double axisMin = start.toDouble();
  double axisMax = max ?? ticks.last;

  /* The guard at the top opens a day around a single instant in the *data*;
     this one does the same for a caller who passed the same `min` and `max`.
     An axis with no width has no fraction to give, and the two packages failed
     differently without this: every mark landed on the origin here and a
     screen off the plot on the web. */
  if (axisMax <= axisMin) {
    axisMin -= _day / 2;
    axisMax += _day / 2;
  }

  return TimeScale(
    axisMin,
    axisMax,
    <double>[
      for (final double one in ticks)
        if (one >= axisMin && one <= axisMax) one,
    ],
    unit,
    count,
  );
}

/// Whether an axis stepping in hours, minutes or seconds runs over more than
/// one calendar day, and so has to write the date beside each time.
///
/// `09:00 – 17:00` on an axis two days long could be either day. An axis that
/// ends exactly at midnight has not started the next day, so its last tick does
/// not count on its own.
bool timeNeedsDate(List<double> ticks, PlChartTimeUnit unit) {
  if (unit != PlChartTimeUnit.second &&
      unit != PlChartTimeUnit.minute &&
      unit != PlChartTimeUnit.hour) {
    return false;
  }

  if (ticks.length < 2) {
    return false;
  }

  return _floorTime(ticks.first.round(), PlChartTimeUnit.day) !=
      _floorTime(ticks.last.round() - 1, PlChartTimeUnit.day);
}

/// The four units a compact number is written in, in the order they are used.
const List<String> _compactUnits = <String>['K', 'M', 'B', 'T'];

/// A number with at most [places] decimals and no trailing zeros.
String _trimmed(double value, int places) {
  final String text = value.toStringAsFixed(places);

  if (!text.contains('.')) {
    return text;
  }

  return text.replaceFirst(RegExp(r'\.?0+$'), '');
}

/// [text], a number as [_trimmed] writes it, with its whole part grouped in
/// threes by a comma: `1234.5` becomes `1,234.5`.
///
/// English grouping, and in every locale. It is what `Intl` gives the React
/// build for a reader in English, and without `package:intl` there is no other
/// locale's to reach for: a reader in German, whose separator is a full stop,
/// sees the English one here, where the web gives them their own. A `format` is
/// how a chart writes its numbers any other way.
String _grouped(String text) {
  final bool negative = text.startsWith('-');
  final String unsigned = negative ? text.substring(1) : text;
  final int point = unsigned.indexOf('.');
  final String whole = point < 0 ? unsigned : unsigned.substring(0, point);
  final buffer = StringBuffer(negative ? '-' : '');

  for (int i = 0; i < whole.length; i += 1) {
    // A comma before every digit that has a whole number of threes after it.
    if (i > 0 && (whole.length - i) % 3 == 0) {
      buffer.write(',');
    }

    buffer.write(whole[i]);
  }

  if (point >= 0) {
    buffer.write(unsigned.substring(point));
  }

  return buffer.toString();
}

/// A number, compactly enough that a y axis of thousands is not four labels of
/// seven characters.
///
/// Only when the caller passed no `format` of their own: the moment they do,
/// they have said what the number means and the library's opinion about
/// thousands stops being welcome.
///
/// The React build hands this to `Intl` with `notation: 'compact'`. This
/// package ships no `package:intl`, which is the same trade [formatTimeValue]
/// makes, so the four English units are written out here and the arithmetic is
/// the one `Intl` does: compact from ten thousand up, one decimal place, and a
/// value that rounds up to a thousand moves a unit along, so 999,999 is `1M`
/// rather than `1000K`. Under ten thousand it is the plain number with at most
/// two decimals and its thousands grouped, `9,999`, as `Intl` writes it in
/// English — see [_grouped] for what that means in another language.
String compactNumber(double value) {
  final double magnitude = value.abs();

  if (magnitude < 10000) {
    return _grouped(_trimmed(value, 2));
  }

  double scaled = magnitude;
  int unit = -1;

  while (scaled >= 1000 && unit < _compactUnits.length - 1) {
    scaled /= 1000;
    unit += 1;
  }

  if (double.parse(scaled.toStringAsFixed(1)) >= 1000 && unit < _compactUnits.length - 1) {
    scaled /= 1000;
    unit += 1;
  }

  final String mantissa = _trimmed(scaled, 1);

  // Past the last unit the figure in front of it keeps growing, and `Intl`
  // groups it from five whole digits up, where a plain number is grouped from
  // four: `1234T`, but `12,345T`.
  final String written = mantissa.split('.').first.length >= 5 ? _grouped(mantissa) : mantissa;

  return '${value < 0 ? '-' : ''}$written${_compactUnits[unit]}';
}

/// One instant on a time axis, written unambiguously.
///
/// Off [PlDateNames]' own month names rather than off a platform formatter,
/// which is the same trade the date pickers make: this package takes no
/// dependency on `package:intl`, and an application that has one already can
/// hand the names over in three lines.
///
/// [withDate] puts the date in front of a time, for an axis [timeNeedsDate].
String formatTimeValue(
  double value,
  PlChartTimeUnit unit,
  PlDateNames names, {
  bool withYear = true,
  bool withDate = false,
}) {
  final DateTime at = DateTime.fromMillisecondsSinceEpoch(value.round());
  final String hh = at.hour.toString().padLeft(2, '0');
  final String mm = at.minute.toString().padLeft(2, '0');
  final String date = !withDate
      ? ''
      : withYear
      ? '${names.monthsShort[at.month - 1]} ${at.day}, ${at.year}, '
      : '${names.monthsShort[at.month - 1]} ${at.day}, ';

  switch (unit) {
    case PlChartTimeUnit.second:
      return '$date$hh:$mm:${at.second.toString().padLeft(2, '0')}';
    case PlChartTimeUnit.minute:
    case PlChartTimeUnit.hour:
      return '$date$hh:$mm';
    case PlChartTimeUnit.year:
      return '${at.year}';
    case PlChartTimeUnit.month:
    case PlChartTimeUnit.quarter:
      final String month = names.monthsShort[at.month - 1];

      return withYear ? '$month ${at.year}' : month;
    case PlChartTimeUnit.day:
    case PlChartTimeUnit.week:
      final String stamp = '${names.monthsShort[at.month - 1]} ${at.day}';

      return withYear ? '$stamp, ${at.year}' : stamp;
  }
}

/// A whole axis of ticks, written the way an axis is read.
///
/// The year is decided for the axis rather than for each tick, and that is the
/// part worth explaining. Writing it only where it *changes* is what a reader
/// wants and is not safe here: the labels are thinned again downstream, by a
/// stride measured against the plot's real width, and the tick the year was
/// riding on is exactly the one that gets dropped — leaving `Oct 2025 · Dec ·
/// Feb` with nothing to say which year February is in.
///
/// So: an axis inside one year names it once, on the first tick, which is the
/// one tick a stride never removes. An axis that crosses a year names it on
/// every tick, so whichever ones survive are each unambiguous.
///
/// The date on an axis of hours follows the second rule for the same reason:
/// an axis that crosses midnight writes it on every tick, since the midnight
/// tick is as likely to be dropped as the one a year was riding on.
List<String> formatTimeTicks(List<double> ticks, PlChartTimeUnit unit, PlDateNames names) {
  final years = <int>{
    for (final double tick in ticks) DateTime.fromMillisecondsSinceEpoch(tick.round()).year,
  };
  final bool always = years.length > 1;
  final bool withDate = timeNeedsDate(ticks, unit);

  return <String>[
    for (int i = 0; i < ticks.length; i += 1)
      formatTimeValue(ticks[i], unit, names, withYear: always || i == 0, withDate: withDate),
  ];
}
