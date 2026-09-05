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
import 'dart:ui' show Color, Offset, Path, RRect, Radius, Rect;

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
const Map<PlassDensity, double> barBandRatio = <PlassDensity, double>{
  PlassDensity.standard: 0.68,
  PlassDensity.compact: 0.84,
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

/// A category as a number, for a category axis that is really a value axis.
///
/// A `DateTime` is its epoch milliseconds, which is what makes a scatter of
/// timestamps work at all. A string is not a position on a number line, so it
/// comes back `null` rather than `NaN` — the same rule [finiteOrNull] follows,
/// and for the same reason.
double? categoryToNumber(PlassChartCategory? value) {
  if (value == null) {
    return null;
  }

  final DateTime? date = value.date;

  if (date != null) {
    return date.millisecondsSinceEpoch.toDouble();
  }

  return finiteOrNull(value.number);
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

/// The two ends of a range, or `null` when there is nothing in it.
class ChartExtent {
  /// Creates an extent.
  const ChartExtent(this.min, this.max);

  /// The lowest value seen.
  final double min;

  /// The highest.
  final double max;
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
  if (high == low) {
    final double pad = high.abs() > 0 ? high.abs() * 0.5 : 1;

    low -= pad;
    high += pad;
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

    path
      ..addPath(linePath(above, curve), Offset.zero)
      ..addPath(_reverseEdge(below, curve), Offset.zero)
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

/// The floor of a band, walked back the way it came.
///
/// A line rather than the curve the top took: the two meet at the ends either
/// way, and a stacked band's floor is the band below it — which has already
/// been drawn with its own curve, so curving it again here would put a second,
/// slightly different edge over the first.
Path _reverseEdge(List<Offset?> points, PlChartCurve curve) {
  final path = Path();
  bool started = false;

  for (final Offset? point in points) {
    if (point == null) {
      continue;
    }

    if (!started) {
      path.moveTo(point.dx, point.dy);
      started = true;
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }

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

/// One marker, centred on a point.
Path markPath(PlChartMarkShape shape, double cx, double cy, double r) {
  final path = Path();

  switch (shape) {
    case PlChartMarkShape.circle:
      path.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    case PlChartMarkShape.square:
      // Squared off to the same *area* as the circle, so the two do not read as
      // two sizes of the same thing.
      final double side = r * 1.77;
      path.addRect(Rect.fromCenter(center: Offset(cx, cy), width: side, height: side));
    case PlChartMarkShape.triangle:
      final double side = r * 1.15;
      path
        ..moveTo(cx, cy - r * 1.25)
        ..lineTo(cx + side * 1.1, cy + r * 0.8)
        ..lineTo(cx - side * 1.1, cy + r * 0.8)
        ..close();
    case PlChartMarkShape.diamond:
      final double d = r * 1.3;
      path
        ..moveTo(cx, cy - d)
        ..lineTo(cx + d, cy)
        ..lineTo(cx, cy + d)
        ..lineTo(cx - d, cy)
        ..close();
    case PlChartMarkShape.cross:
      final double arm = r * 1.2;
      final double thick = r * 0.45;
      path
        ..addRect(Rect.fromCenter(center: Offset(cx, cy), width: arm * 2, height: thick * 2))
        ..addRect(Rect.fromCenter(center: Offset(cx, cy), width: thick * 2, height: arm * 2));
  }

  return path;
}
