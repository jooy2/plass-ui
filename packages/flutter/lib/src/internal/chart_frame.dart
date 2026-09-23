/// Everything a chart draws that is not its marks.
///
/// The split this file makes is the one the whole `internal/` folder is about:
/// a line chart, an area chart and a bar chart differ in about forty lines each
/// — a path, a band, a rounded end — and agree on everything else. The axes,
/// the grid, the legend, the crosshair, the tooltip, the empty state and the
/// words a screen reader gets instead of the picture are all the same problem
/// several times over.
///
/// So [PlassCartesianChart] is the chart, and a widget hands it a painter that
/// draws the marks. What is left in `pl_line_chart.dart` is the line.
///
/// `internal/chart.dart` is the arithmetic under this; nothing in there knows
/// what a `Canvas` is, and nothing in here does arithmetic that is not layout.
///
/// It is not exported from `plass_ui.dart`.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/chart.dart';
import 'package:plass_ui/src/internal/date.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// What one axis is told about itself.
class PlChartAxis {
  /// Creates an axis.
  const PlChartAxis({
    this.hidden = false,
    this.label,
    this.min,
    this.max,
    this.tickCount = 5,
    this.scale = PlassChartScale.linear,
    this.grid = true,
    this.thickness,
    this.tickAngle = 0,
    this.format,
  });

  /// Draws nothing at all and gives the room back to the plot, which is what
  /// makes a sparkline-shaped chart the same widget with both axes off rather
  /// than a different widget.
  final bool hidden;

  /// A name for the axis, written along it.
  final String? label;

  /// Pins the bottom of a value axis. Naming it turns off the include-zero rule.
  final double? min;

  /// Pins the top.
  final double? max;

  /// Roughly how many ticks to aim for. The scale rounds to clean numbers, so
  /// what comes out is near this rather than on it.
  final int tickCount;

  /// Whether the axis steps by adding or by multiplying.
  ///
  /// [PlassChartScale.log] is the one scale in the library that changes what a
  /// distance on the plot means: the same length becomes the same **ratio**
  /// rather than the same number of units, so the gap from 10 to 100 is the gap
  /// from 100 to 1,000. It is the only way a series that runs from 3 to
  /// 3,000,000 can be drawn with the small end still legible, and it has to be
  /// labelled as what it is — a reader who takes it for linear reads every
  /// shape on it wrong.
  ///
  /// There is no zero on it, and nothing below one either. An axis whose data
  /// reaches either floors at the smallest positive power of ten it needs, or
  /// three decades under the top when the data offers none, and those values
  /// are drawn on that floor. A bar is the wrong mark for it for the same
  /// reason a bar's axis cannot be cropped: what a bar encodes is a length, and
  /// on a log axis a bar twice as long is not twice as much.
  ///
  /// Read on the **value** axis, and on a category axis only where that axis is
  /// a second value axis — a `PlScatterChart`'s. A band of categories has no
  /// arithmetic to do, and a time axis has its own.
  final PlassChartScale scale;

  /// Rules across the plot at each tick.
  final bool grid;

  /// Overrides the band the axis reserves, in logical pixels.
  final double? thickness;

  /// Turns the labels, in degrees, so long names fit without being cut.
  ///
  /// An axis runs out of room across and not down, so a name wider than its
  /// slot is cut to it — and past about four characters a cut stops telling two
  /// names apart, which is when this is the answer instead. A turned label
  /// takes one line of text across the axis however long it is, and spends the
  /// room under the plot, where a chart usually has some.
  ///
  /// `-45` is the one to reach for: it reads at a glance, and the negative sign
  /// runs the text up towards the right, the way every chart that does this
  /// draws it. `-90` stands it on end, which fits the most labels in the least
  /// width and is the one that has to be read with a tilted head. A positive
  /// angle leans the other way, down to the right.
  ///
  /// [autoTickAngle] asks the axis: it stays upright while every name fits its
  /// slot, and turns to `-45` as soon as one of them would be cut. Upright is
  /// the best an axis can do when there is room for it, and a diagonal beats a
  /// cut at every width — so it is the setting for a chart whose categories are
  /// the caller's data rather than the caller's choice.
  ///
  /// The band under the plot grows to hold whatever is asked for, up to about
  /// two fifths of the chart's height; a name longer than that is still cut,
  /// and the readout and the table still have all of it. Only the **category**
  /// axis turns — a value axis' ticks are numbers already rounded to be short —
  /// and only where that axis runs along the bottom, so it does nothing on a
  /// horizontal bar chart, whose category names are already one to a row.
  final double tickAngle;

  /// The [tickAngle] that lets the axis decide: upright while the names fit
  /// their slots, and on the diagonal once one of them would be cut.
  ///
  /// A sentinel rather than a second field, because it is the same axis of
  /// choice — how far to turn — and two fields would let a caller ask for both
  /// at once. The React build spells it `tickAngle="auto"`, which Dart has no
  /// union type for.
  static const double autoTickAngle = double.infinity;

  /// How a tick is written.
  final String Function(double value)? format;
}

/// Whether an axis steps by adding or by multiplying.
enum PlassChartScale {
  /// The same length is the same number of units wherever it is. The default.
  linear,

  /// The same length is the same *ratio* — the gap from 10 to 100 is the gap
  /// from 100 to 1,000.
  ///
  /// The only way a series that runs from 3 to 3,000,000 can be drawn with the
  /// small end still legible, and it has to be labelled as what it is: a reader
  /// who takes it for linear reads every shape on it wrong.
  log,
}

/// Where the legend goes, and whether there is one.
class PlChartLegend {
  /// Creates a legend.
  const PlChartLegend({
    this.hidden = false,
    this.side = PlassSide.bottom,
    this.align = PlassAlign.center,
    this.interactive = true,
    this.maxEntries,
  });

  /// Draws nothing.
  ///
  /// The React build spells this as `legend={false}`; Dart has no union type to
  /// say it that way, so the switch is a field on the object.
  final bool hidden;

  /// Which edge of the plot it sits on.
  final PlassSide side;

  /// Where along that edge.
  final PlassAlign align;

  /// Whether pressing an entry switches its series off, and hovering one dims
  /// the rest.
  final bool interactive;

  /// Shows this many entries and folds the rest behind a button that opens
  /// them.
  ///
  /// A legend is a key, and a key of twelve names wrapped over four rows is a
  /// paragraph the reader has to search — on a card, it is also four rows the
  /// plot no longer has. Folding keeps the legend one or two rows tall and
  /// leaves the rest one press away, which is the right trade whenever the
  /// reader is looking up *one* series rather than reading the list.
  ///
  /// The entries kept are the first ones, in the order the series were passed,
  /// because that is the order their colours were handed out in and the order
  /// the reader has already learned. Nothing is hidden from a screen reader by
  /// it: the fold is a real button that says how many are behind it, and every
  /// series is in the reading the chart hands over either way.
  final int? maxEntries;
}

/// What a tooltip shows, and whether there is one.
class PlChartTooltip {
  /// Creates a tooltip.
  const PlChartTooltip({this.mode = PlassChartTooltipMode.column, this.hidden = false});

  /// How much of the chart a pointer summons.
  final PlassChartTooltipMode mode;

  /// Draws nothing.
  final bool hidden;
}

/// The plot's box inside the chart, once the axes have taken their bands.
class PlotBox {
  /// Creates a box.
  const PlotBox(this.left, this.top, this.width, this.height);

  /// The starting edge.
  final double left;

  /// The top.
  final double top;

  /// How wide.
  final double width;

  /// How tall.
  final double height;

  /// The bottom edge.
  double get bottom => top + height;

  /// The ending edge.
  double get right => left + width;
}

/// One mark on a plot whose marks are not arranged in columns.
///
/// A scatter has no shared categories, so there is no column for a pointer to
/// be inside and nothing for a crosshair to be dropped through: the only
/// question a reader can be asking is "which of these dots". A chart that says
/// so hands the frame its marks and gets the nearest-mark search and the
/// readout anchoring for free.
class PlassChartMark {
  /// Creates a mark.
  const PlassChartMark({
    required this.series,
    required this.index,
    required this.centre,
    required this.r,
    this.rx,
    this.ry,
  });

  /// Its series' place in the list as it was passed — where its colour is from.
  final int series;

  /// Its own place within that series.
  final int index;

  /// Where it is pinned, in pixels from the chart's top-left.
  final Offset centre;

  /// How big it is, which is also how far off it a press still counts.
  final double r;

  /// Its half-width and half-height, when the mark is a box rather than a disc.
  ///
  /// A span on a Gantt is two hundred pixels of bar whose centre a pointer may
  /// never go near, so measuring to the centre would hand the row's short bar a
  /// press the reader is plainly not making. Given these, the pointer is tested
  /// against the *body*.
  final double? rx;

  /// The other half of [rx].
  final double? ry;

  /// How far the press is from this mark, or `null` when it is not near it.
  double? distanceFrom(Offset at, double slop) {
    final double? halfWidth = rx;
    final double? halfHeight = ry;

    if (halfWidth == null || halfHeight == null) {
      final double away = (centre - at).distance;

      return away <= r + slop ? away : null;
    }

    // Outside the box in each axis, which is zero while the press is within it.
    final double dx = math.max(0, (at.dx - centre.dx).abs() - halfWidth);
    final double dy = math.max(0, (at.dy - centre.dy).abs() - halfHeight);
    final double away = math.sqrt(dx * dx + dy * dy);

    return away <= slop ? away : null;
  }
}

/// Builds every mark, once the frame knows where the plot is.
typedef PlassChartMarkBuilder = List<PlassChartMark> Function(PlassChartLayout layout);

/// What the category axis is: a row of slots, or a second number line.
enum PlassChartAxisScale {
  /// One slot per category. Every chart but the scatter.
  band,

  /// Numbers, spaced by what they are. What a scatter needs and what nothing
  /// else does.
  value,
}

/// One mark per drawn value, for a chart whose marks sit in a grid.
///
/// [PlassChartTooltipMode.nearest] is the only thing that asks for these. A
/// line chart and a bar chart have no mark list of their own — their hit
/// testing is by column, because a column is what their numbers share — so the
/// marks the nearest-mark search needs have to be built from the layout, and
/// from the layout alone, because the frame is the only place that knows where
/// anything ended up.
///
/// Stacking is the one thing it has to be told, and it has to be: a stacked
/// series is drawn on the running total of the ones under it, and a mark placed
/// at the bare value would sit somewhere the reader can see nothing. Only the
/// visible series contribute to that total, for the same reason they do
/// everywhere else — hiding one from the legend closes the gap it left. The
/// React build answers with `gridMarks`.
List<PlassChartMark> gridMarks(PlassChartLayout layout, bool stacked) {
  final List<PlassChartMark> built = <PlassChartMark>[];
  final double radius = markerRadii[layout.size]!;
  final List<double> running = <double>[];

  for (int s = 0; s < layout.values.length; s += 1) {
    final List<ChartValue> one = layout.values[s];
    final List<double> under = <double>[
      for (int i = 0; i < one.length; i += 1) i < running.length ? running[i] : 0,
    ];

    if (stacked && layout.visible[s]) {
      for (int i = 0; i < one.length; i += 1) {
        while (running.length <= i) {
          running.add(0);
        }

        running[i] = running[i] + (one[i].value ?? 0);
      }
    }

    if (!layout.visible[s]) {
      continue;
    }

    for (int i = 0; i < one.length && i < layout.count; i += 1) {
      final double? value = one[i].value;

      if (value == null) {
        continue;
      }

      final Offset at = layout.point(i, stacked ? under[i] + value : value);

      built.add(PlassChartMark(series: s, index: i, centre: at, r: radius));
    }
  }

  return built;
}

/// Everything a mark painter is told, once the frame has laid itself out.
class PlassChartLayout {
  /// Creates a layout.
  const PlassChartLayout({
    required this.plot,
    required this.values,
    required this.visible,
    required this.colors,
    required this.dashed,
    required this.scale,
    required this.band,
    required this.categories,
    required this.size,
    required this.inset,
    required this.horizontal,
    required this.density,
    required this.activeIndex,
    required this.hovered,
    required this.tokens,
    this.categoryScale,
    this.marks = const <PlassChartMark>[],
    this.activeMark,
  });

  /// Where the marks may be drawn.
  final PlotBox plot;

  /// Every series unpacked, in the order it was given.
  final List<List<ChartValue>> values;

  /// Which of them are switched on, by index.
  final List<bool> visible;

  /// The colour each series takes, by index — never renumbered by a filter.
  final List<Color> colors;

  /// Which series are drawn as a dashed line, by index, in the same order.
  final List<bool> dashed;

  /// The value axis' scale.
  final ValueScale scale;

  /// The category axis' slots.
  final BandScale band;

  /// What the category axis says at each position.
  final List<PlassChartCategory> categories;

  /// The size the whole chart is drawn at.
  final PlassSize size;

  /// Whether the first mark sits *on* the axis rather than in the middle of a
  /// band — a line does, a bar does not.
  final bool inset;

  /// Whether the marks run along the category axis rather than across it.
  ///
  /// A horizontal bar chart is the right answer whenever the category names are
  /// words: it has a whole column for them, where a vertical one has the width
  /// of one bar.
  final bool horizontal;

  /// How much of a category's slot the marks in it may take.
  final PlassDensity density;

  /// The category under the pointer, or `null`.
  final int? activeIndex;

  /// The series the legend is being hovered over, or `null`.
  final int? hovered;

  /// The theme, for the ink a mark's own label is written in.
  final PlassTokens tokens;

  /// The scale the *category* axis runs on, when it is a second number line.
  /// `null` on every chart whose categories are slots.
  final ValueScale? categoryScale;

  /// Every mark, when the chart supplied a builder. Empty otherwise.
  final List<PlassChartMark> marks;

  /// The one the pointer is on, or `null`.
  final PlassChartMark? activeMark;

  /// How many categories there are.
  int get count => categories.length;

  /// How long the category axis is, in pixels.
  double get categoryLength => horizontal ? plot.height : plot.width;

  /// Where a value sits along the value axis, in pixels from the chart's edge.
  double valuePx(double value) => horizontal
      ? plot.left + scale.fraction(value) * plot.width
      : plot.top + (1 - scale.fraction(value)) * plot.height;

  /// Where a category's centre sits **along the category axis**, measured from
  /// the plot's own start rather than from the chart's edge.
  ///
  /// A line's first point sits *on* the axis and a bar's first band starts at
  /// it, which is one half-step apart; [inset] is which of the two this is.
  double categoryPx(int index) {
    final ValueScale? line = categoryScale;

    if (line != null) {
      // Defined through `categoryValuePx` rather than beside it, so a tick and
      // a point that share a number cannot land in two places.
      final double at = index < line.ticks.length ? line.ticks[index] : line.max;

      return categoryValuePx(at) - (horizontal ? plot.top : plot.left);
    }

    if (!inset) {
      return band.centre(index);
    }

    return count <= 1 ? categoryLength / 2 : categoryLength * index / (count - 1);
  }

  /// The two combined, whichever way round the chart runs.
  Offset point(int index, double value) => horizontal
      ? Offset(valuePx(value), plot.top + categoryPx(index))
      : Offset(plot.left + categoryPx(index), valuePx(value));

  /// Where a *number* sits along the category axis, in pixels from the chart's
  /// edge — the same absolute reckoning [valuePx] uses, and deliberately not
  /// [categoryPx]'s offset-along-the-axis. Only meaningful with a
  /// [categoryScale].
  double categoryValuePx(double value) {
    final ValueScale? line = categoryScale;

    if (line == null) {
      return plot.left + categoryPx(0);
    }

    return horizontal
        ? plot.top + (1 - line.fraction(value)) * plot.height
        : plot.left + line.fraction(value) * plot.width;
  }

  /// Where the baseline is along the value axis.
  double get zeroPx => valuePx(math.min(math.max(0, scale.min), scale.max));

  /// A copy carrying the marks that were built from it.
  PlassChartLayout withMarks(List<PlassChartMark> built, PlassChartMark? active) =>
      PlassChartLayout(
        plot: plot,
        values: values,
        visible: visible,
        colors: colors,
        dashed: dashed,
        scale: scale,
        band: band,
        categories: categories,
        size: size,
        inset: inset,
        horizontal: horizontal,
        density: density,
        activeIndex: activeIndex,
        hovered: hovered,
        tokens: tokens,
        categoryScale: categoryScale,
        marks: built,
        activeMark: active,
      );
}

/// Draws the marks a particular chart is made of.
typedef PlassChartMarkPainter = void Function(Canvas canvas, PlassChartLayout layout);

/// A chart with two axes, and the frame around whatever is drawn between them.
class PlassCartesianChart extends StatefulWidget {
  /// Creates a frame.
  const PlassCartesianChart({
    required this.series,
    required this.paint,
    this.categories,
    this.xAxis = const PlChartAxis(),
    this.yAxis = const PlChartAxis(),
    this.reference = const <PlassChartReference>[],
    this.legend = const PlChartLegend(),
    this.tooltip = const PlChartTooltip(),
    this.height,
    this.stacked = false,
    this.inset = false,
    this.horizontal = false,
    this.density,
    this.includeZero = true,
    this.headroom = 0,
    this.format,
    this.semanticLabel,
    this.empty,
    this.size,
    this.xScale = PlassChartAxisScale.band,
    this.marks,
    this.markRadius = 24,
    this.markInset = 0,
    this.swatch,
    this.stroked = false,
    this.markReadout,
    this.markHeading,
    this.markColor,
    this.semanticValue,
    this.scale,
    super.key,
  });

  /// The data.
  final List<PlassChartSeries> series;

  /// Draws the marks, once the frame has worked out where they go.
  final PlassChartMarkPainter paint;

  /// What the category axis says, when the points do not carry it themselves.
  final List<PlassChartCategory>? categories;

  /// Lines drawn across the plot at a value — a target, an average, a limit.
  ///
  /// Not data, and drawn as if they know it: dashed, in the muted ink, under
  /// the marks. They sit on the **value** axis, so one runs across a vertical
  /// chart and down a horizontal one. Each is written into the reading a screen
  /// reader is given with the chart.
  final List<PlassChartReference> reference;

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

  /// Whether the series ride on the totals of the ones below them.
  final bool stacked;

  /// Whether the first mark sits *on* the category axis.
  final bool inset;

  /// Whether the marks run along the category axis rather than across it.
  final bool horizontal;

  /// How much of a category's slot the marks in it may take. Never the height.
  final PlassDensity? density;

  /// Whether zero stays in range.
  final bool includeZero;

  /// Room above the tallest mark, for a value written over it.
  final double headroom;

  /// How a value is written in a tooltip and on the axis.
  final String Function(double value)? format;

  /// What the whole drawing is called.
  final String? semanticLabel;

  /// What is drawn when there is nothing to draw.
  final Widget? empty;

  /// Type scale, plot height, line weight and marker radius.
  final PlassSize? size;

  /// Whether the category axis is a row of slots or a second number line.
  final PlassChartAxisScale xScale;

  /// Builds every mark on the plot, which swaps the frame's column hit-testing
  /// for a nearest-mark search. The result comes back on the layout, so the
  /// marks are laid out once and drawn from the same list they are tested
  /// against.
  final PlassChartMarkBuilder? marks;

  /// How far off a mark a press still counts as on it, in pixels. Added to the
  /// mark's own radius — a 4px dot is not a hit target.
  final double markRadius;

  /// Room on **every** side of the plot, for marks drawn from their centre.
  ///
  /// [headroom] is not enough for those: a bubble at the largest x hangs over
  /// the right edge and one at the smallest hangs over the value axis' own
  /// labels. A line's marker gets away with it because a line is inset from
  /// both ends anyway; a scatter places a mark wherever the number says.
  final double markInset;

  /// The legend's swatch, for a chart whose marks are not all the same shape.
  final Widget Function(int index, Color color)? swatch;

  /// Whether the marks are a stroke along the categories — a line, or the edge
  /// of an area that is not stacked — so a `dashed` series is drawn dashed, and
  /// its legend entry is a dashed rule rather than a square.
  ///
  /// Said by the chart rather than read off the series, because `dashed` does
  /// nothing on a bar or a stacked band, and a legend that promised a dashed
  /// line the plot never drew would be the one part of the chart that lied.
  final bool stroked;

  /// What the readout says about a mark, for a chart whose marks are not in a
  /// grid the frame can look an answer up in.
  final String Function(PlassChartMark mark)? markReadout;

  /// And what it is called, for a chart whose marks name themselves rather than
  /// taking their series' name. A Gantt's spans do.
  final String Function(PlassChartMark mark)? markHeading;

  /// And what colour its swatch is, for a chart whose marks are not coloured
  /// by the frame's series.
  ///
  /// A Gantt hands the frame one stand-in series and numbers its marks by
  /// *row*, so a mark's series is not an index into the frame's colours at all
  /// — read as one, the second row's card asked for a colour that was not
  /// there and threw.
  final Color Function(PlassChartMark mark)? markColor;

  /// The value axis' scale, already worked out.
  ///
  /// For the axis that is not a count. [valueScale] rounds to 1-2-5, which is
  /// the family a reader does arithmetic in and exactly the wrong one for an
  /// instant — sixty, twenty-four, seven, twelve. A chart whose axis has its
  /// own arithmetic builds the scale itself and hands it over.
  final ValueScale? scale;

  /// What a screen reader is handed in place of the drawing, for a chart whose
  /// summary is not "each series and where it ended up".
  ///
  /// Handed which series are on: the ones that did not start `hidden`, less
  /// whatever the reader has switched off in the legend since.
  final String Function(List<bool> visible)? semanticValue;

  @override
  State<PlassCartesianChart> createState() => _PlassCartesianChartState();
}

class _PlassCartesianChartState extends State<PlassCartesianChart> {
  /// Which series are switched off: the ones that started `hidden`, then
  /// whatever the reader toggled in the legend.
  ///
  /// `hidden` is read once, as the React build reads it, so a series that starts
  /// switched off is one the legend can switch back on.
  final Set<int> _off = <int>{};

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < widget.series.length; i += 1) {
      if (widget.series[i].hidden) {
        _off.add(i);
      }
    }
  }

  int? _activeIndex;
  int? _hovered;
  PlassChartMark? _activeMark;

  /// The plot's own tab stop, which the arrow keys walk.
  ///
  /// Held here rather than made by the `Focus` below, because that widget is
  /// rebuilt with every column the pointer crosses and a node made in `build`
  /// would be a new node — and the focus would fall off the chart — each time.
  final FocusNode _focus = FocusNode(debugLabel: 'PlassCartesianChart');

  /// Whether the ring is drawn: the plot holds the focus, and it arrived from
  /// the keyboard rather than from a press.
  bool _focusVisible = false;

  /// Whether what is being read was reached by a key rather than by the
  /// pointer.
  ///
  /// A key has no pointer to stand the card beside or to measure `item` mode
  /// against, so the card is anchored on the column itself and speaks for all
  /// of it — which is what the React build does for the same reason.
  bool _keyed = false;

  /// Where the pointer is, apart from the state that decides what is drawn.
  ///
  /// A move inside the same column, or near the same mark, changes nothing but
  /// where the tooltip stands, so it is a notifier the tooltip listens to rather
  /// than a rebuild of the whole frame for every pixel.
  final ValueNotifier<Offset?> _pointer = ValueNotifier<Offset?>(null);

  /// The summary, and what it was written for. It reads every value, so it is
  /// written again only for a new widget — new data, a new format — or a
  /// series switched on or off, not for each column the pointer crosses.
  String? _said;
  PlassCartesianChart? _saidFor;
  List<bool>? _saidVisible;
  PlDateNames? _saidNames;

  @override
  void dispose() {
    _pointer.dispose();
    _focus.dispose();
    super.dispose();
  }

  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

  String _write(double value) {
    if (widget.format != null) {
      return widget.format!(value);
    }

    return compactNumber(value);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final labels = PlassTheme.labelsOf(context);
    final PlDateNames names = PlassTheme.defaultsOf(context).names ?? PlDateNames.english;
    final PlassSize size = _size;
    final double fontSize = chartFontSizes[size]!;
    final double height = widget.height ?? plotHeights[size]!;

    final List<List<ChartValue>> values = toValues(widget.series);
    final List<bool> visible = <bool>[
      for (int i = 0; i < widget.series.length; i += 1) !_off.contains(i),
    ];
    final List<Color> colors = <Color>[
      for (int i = 0; i < widget.series.length; i += 1)
        seriesColor(widget.series[i].color, i, tokens.chart),
    ];
    final List<bool> dashed = <bool>[
      for (int i = 0; i < widget.series.length; i += 1) widget.series[i].dashed,
    ];

    final List<List<ChartValue>> shown = <List<ChartValue>>[
      for (int i = 0; i < values.length; i += 1)
        if (visible[i]) values[i] else <ChartValue>[],
    ];

    /* A value-scaled category axis has no columns, so what goes down it is its
       own ticks rather than the data's labels. Rounding them here rather than
       in the painter is what lets everything downstream — the label band, the
       tick text, `categoryPx` — stay the one code path it already was. */
    final bool dated =
        widget.xScale == PlassChartAxisScale.value && categoriesAreDates(values, widget.categories);
    final ValueScale? categoryScale = widget.xScale != PlassChartAxisScale.value
        ? null
        : dated
        ? timeScale(
            categoryExtent(values, widget.categories),
            min: widget.xAxis.min,
            max: widget.xAxis.max,
            tickCount: widget.xAxis.tickCount,
          )
        : widget.xAxis.scale == PlassChartScale.log
        // A second value axis is a value axis, so it takes the same choice. A
        // *band* of categories does not: there is no arithmetic between 'Seoul'
        // and 'Tokyo' for a logarithm to do.
        ? logScale(
            categoryExtent(values, widget.categories),
            min: widget.xAxis.min,
            max: widget.xAxis.max,
            tickCount: widget.xAxis.tickCount,
          )
        : valueScale(
            categoryExtent(values, widget.categories),
            min: widget.xAxis.min,
            max: widget.xAxis.max,
            tickCount: widget.xAxis.tickCount,
            includeZero: false,
          );

    final int count = categoryScale?.ticks.length ?? categoryCount(widget.series);
    final List<PlassChartCategory> categories = categoryScale != null
        ? <PlassChartCategory>[
            for (final double tick in categoryScale.ticks) PlassChartCategory.number(tick),
          ]
        : <PlassChartCategory>[
            for (int i = 0; i < count; i += 1) categoryAt(i, widget.categories, values),
          ];

    final ChartExtent? extent = extentOf(shown, stacked: widget.stacked);
    final bool nothing = extent == null;

    final ValueScale scale =
        widget.scale ??
        (widget.yAxis.scale == PlassChartScale.log
            // `includeZero` is not passed on, and there is nothing to pass it
            // to: a log axis has no zero to keep in range.
            ? logScale(
                extent,
                min: widget.yAxis.min,
                max: widget.yAxis.max,
                tickCount: widget.yAxis.tickCount,
              )
            : valueScale(
                extent,
                min: widget.yAxis.min,
                max: widget.yAxis.max,
                tickCount: widget.yAxis.tickCount,
                includeZero: widget.includeZero && widget.yAxis.min == null,
              ));

    final Widget plot = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        if (nothing) {
          return SizedBox(
            height: height,
            // The caller's widget as it is — a `Text.rich`, an icon over a
            // line — in the same muted type the default is written in.
            child: Center(
              child: DefaultTextStyle.merge(
                style: TextStyle(fontSize: metaText[size]!, color: tokens.mutedFg),
                child: widget.empty ?? Text(labels.empty),
              ),
            ),
          );
        }

        final List<String> tickTexts = scale.ticks
            .map((double tick) => widget.yAxis.format?.call(tick) ?? _write(tick))
            .toList();
        final double widestTick = tickTexts.fold<double>(
          0,
          (double most, String text) => math.max(most, textWidth(text, fontSize)),
        );

        // The two bands the axes take out of the box. `hidden` gives the room
        // back to the plot, which is what makes a sparkline-shaped chart the
        // same widget with both axes off rather than a different one.
        final double axisLabelBand = fontSize + 6;
        final double valueBand = widget.yAxis.hidden
            ? 0
            : widestTick + 10 + (widget.yAxis.label != null ? axisLabelBand : 0);

        // A horizontal chart gives each category label a row of its own on the
        // starting edge; a vertical one gives it the width of one slot, and a
        // slot too narrow to cut a name to is left for the stride to thin out.
        final double slot = (width - valueBand - 16) / math.max(1, count);

        // A value-scaled axis writes its own ticks: through `xAxis.format` when
        // there is one, as the calendar does when they are moments, and as the
        // numbers they are otherwise.
        final List<String> rawCategoryTexts = categoryScale == null
            ? <String>[
                for (final PlassChartCategory category in categories) categoryText(category, names),
              ]
            : widget.xAxis.format != null
            ? <String>[for (final double tick in categoryScale.ticks) widget.xAxis.format!(tick)]
            : categoryScale is TimeScale
            ? formatTimeTicks(categoryScale.ticks, categoryScale.unit, names)
            : <String>[
                for (final PlassChartCategory category in categories) categoryText(category, names),
              ];

        /* A turned category axis, and how deep its band is allowed to get.
           Only along the bottom: a horizontal chart's category names already
           have a row each on the starting edge, which is the thing turning them
           would be buying. Two fifths of the box is the ceiling — past that the
           labels are the chart and the plot is the caption under them.

           A value-scaled axis writes ticks rather than names, and a tick is a
           number already rounded to be short: it is never cut, so
           `autoTickAngle` has nothing to answer there and an explicit angle is
           the only way to turn one. */
        final bool ticked = categoryScale != null;
        final double tickAngle = widget.horizontal
            ? 0
            : widget.xAxis.tickAngle == PlChartAxis.autoTickAngle
            ? (ticked ? 0 : autoTickAngle(rawCategoryTexts, slot: slot, fontSize: fontSize))
            : tickAngleOf(widget.xAxis.tickAngle);
        final bool tilted = tickAngle != 0 && !widget.xAxis.hidden;
        final double tiltBand = math.max(fontSize * 3, height * 0.4);

        // Cut to the slot, or — turned, and so no longer in a slot at all — to
        // the length the band it hangs in has room for.
        final List<String> categoryTexts = tilted
            ? <String>[
                for (final String text in rawCategoryTexts)
                  truncateLabel(text, tiltedRoom(tiltBand, tickAngle, fontSize), fontSize),
              ]
            : fitCategoryLabels(
                rawCategoryTexts,
                horizontal: widget.horizontal,
                slot: slot,
                fontSize: fontSize,
                ticks: ticked,
              );
        final double widestCategory = categoryTexts.fold<double>(
          0,
          (double most, String text) => math.max(most, textWidth(text, fontSize)),
        );

        // `thickness` belongs to whichever axis is actually on that edge, which
        // swaps with the orientation — read off the wrong one, a bar chart
        // turned on its side would take its start margin from the axis along
        // the bottom.
        final double categoryBand = widget.xAxis.hidden
            ? 0
            : widestCategory + 10 + (widget.xAxis.label != null ? axisLabelBand : 0);
        /* A turned label hangs off its tick in one direction only — up to the
           right when the angle is negative, down to the right when it is
           positive — so what has to be kept clear is one end of the axis rather
           than half a label at both. Without it the first or last name runs off
           the edge of the drawing, which is the one label a reader looks for
           first. */
        final double overhang = tilted ? tiltedStep(widestCategory, tickAngle, fontSize) + 4 : 0;

        /// The band of tick labels under the plot, which is also where the
        /// axis' own name goes next.
        final double tickBand = tilted
            ? 8 + tiltedDepth(widestCategory, tickAngle, fontSize)
            : fontSize + 6;

        final double left = math.max(
          widget.horizontal
              ? (widget.xAxis.thickness ?? categoryBand)
              : (widget.yAxis.thickness ?? valueBand),
          tilted && tickAngle < 0 ? overhang : 0,
        );
        final double bottom = widget.horizontal
            ? (widget.yAxis.thickness ??
                  (widget.yAxis.hidden
                      ? 0
                      : fontSize + 12 + (widget.yAxis.label != null ? axisLabelBand : 0)))
            : (widget.xAxis.thickness ??
                  (widget.xAxis.hidden
                      ? 0
                      : tickBand + 6 + (widget.xAxis.label != null ? axisLabelBand : 0)));

        // The last category's label is centred on the last tick, so half of it
        // hangs past the plot. Reserving that half is what stops a chart
        // clipping the one label a reader looks for first — and a horizontal
        // chart needs none of it, because its category labels are in a column.
        final double rightPad = widget.horizontal
            ? 12
            : tilted
            ? (tickAngle > 0 ? overhang : 12)
            : math.max(8, categoryTexts.isEmpty ? 8 : widestCategory / 2);
        // A mark is drawn from its centre, so half of the widest one hangs over
        // the top of the plot.
        final double topPad = markerRadii[size]! + 4 + widget.headroom + widget.markInset;

        final box = PlotBox(
          left + widget.markInset,
          topPad,
          math.max(0, width - left - rightPad - widget.markInset * 2),
          math.max(0, height - topPad - bottom - widget.markInset),
        );

        // Bars divide the axis into `count` slots and sit in the middle of one;
        // lines divide it into `count - 1` gaps and sit on the joins. Both need
        // a step, because the hit target for a category is one step wide either
        // way.
        final band = BandScale(
          widget.inset ? math.max(1, count - 1) : count,
          widget.horizontal ? box.height : box.width,
          barBandRatio[_density]!,
        );

        final base = PlassChartLayout(
          plot: box,
          values: values,
          visible: visible,
          colors: colors,
          dashed: dashed,
          scale: scale,
          band: band,
          categories: categories,
          size: size,
          inset: widget.inset,
          horizontal: widget.horizontal,
          density: _density,
          activeIndex: _activeIndex,
          hovered: _hovered,
          tokens: tokens,
          categoryScale: categoryScale,
        );

        /* `nearest` is the one mode that changes how the press is *read* rather
           than what it is answered with: a chart of columns is asked which
           column, and this asks which mark. A chart that already builds its own
           marks — a scatter, a Gantt — is searched mark by mark whatever the
           mode says, so all this has to supply is the marks a grid-shaped chart
           never needed. */
        final PlassChartMarkBuilder? markBuilder =
            widget.marks ??
            (widget.tooltip.mode == PlassChartTooltipMode.nearest && !widget.tooltip.hidden
                ? (PlassChartLayout from) => gridMarks(from, widget.stacked)
                : null);

        /* The marks are built from the layout and then handed back to it, which
           is the only order that works: a builder that could read what is
           active would be reading a value that does not exist yet. */
        final List<PlassChartMark> built = markBuilder?.call(base) ?? const <PlassChartMark>[];
        final PlassChartMark? active = _activeMark == null
            ? null
            : built.cast<PlassChartMark?>().firstWhere(
                (PlassChartMark? mark) =>
                    mark!.series == _activeMark!.series && mark.index == _activeMark!.index,
                orElse: () => null,
              );
        final PlassChartLayout layout = built.isEmpty && active == null
            ? base
            : base.withMarks(built, active);

        /// Which mark the press is nearest, or `null` when it is near none.
        PlassChartMark? nearest(Offset local) {
          PlassChartMark? found;
          double best = double.infinity;

          for (final PlassChartMark mark in built) {
            final double? away = mark.distanceFrom(local, widget.markRadius);

            if (away != null && away < best) {
              best = away;
              found = mark;
            }
          }

          return found;
        }

        void onMove(Offset local) {
          if (widget.tooltip.hidden ||
              widget.tooltip.mode == PlassChartTooltipMode.none ||
              count == 0) {
            return;
          }

          // A chart that builds its own marks is asking "which of these", not
          // "which column", so the search is for the nearest mark and a press
          // that lands near none of them clears the readout.
          if (markBuilder != null) {
            final PlassChartMark? found = nearest(local);

            if (found?.series != _activeMark?.series || found?.index != _activeMark?.index) {
              setState(() => _activeMark = found);
            }

            _pointer.value = found == null ? null : local;

            return;
          }

          final double length = widget.horizontal ? box.height : box.width;
          final double along = widget.horizontal
              ? (local.dy - box.top).clamp(0, length)
              : (local.dx - box.left).clamp(0, length);
          final int index = widget.inset
              ? (count <= 1 ? 0 : (along / (length / math.max(1, count - 1))).round())
              : (along / band.step).floor();
          final int clamped = index.clamp(0, count - 1);

          if (clamped != _activeIndex) {
            setState(() => _activeIndex = clamped);
          }

          _pointer.value = local;
        }

        void onLeave() {
          if (_activeIndex != null || _activeMark != null) {
            setState(() {
              _activeIndex = null;
              _activeMark = null;
              _keyed = false;
            });
          }

          _pointer.value = null;
        }

        /* The walk. A chart with marks is walked mark by mark, in the order the
           builder made them — which is the order the data was given, not the
           order they are painted in — and a chart without them is walked column
           by column. The same two lists the pointer is tested against, so a key
           can never reach something a pointer could not. */
        final bool speaks =
            !widget.tooltip.hidden && widget.tooltip.mode != PlassChartTooltipMode.none;
        final int walkLength = markBuilder != null ? built.length : count;

        void goTo(int at) {
          if (walkLength == 0) {
            return;
          }

          final int bounded = at.clamp(0, walkLength - 1);

          setState(() {
            _keyed = true;

            if (markBuilder != null) {
              _activeMark = built[bounded];
            } else {
              _activeIndex = bounded;
            }
          });

          _pointer.value = null;
        }

        void step(int delta) {
          final int? current = markBuilder != null
              ? (active == null ? null : built.indexOf(active))
              : _activeIndex;

          // Nothing read yet: forward starts at the first, and back at the last.
          goTo((current ?? (delta > 0 ? -1 : walkLength)) + delta);
        }

        KeyEventResult onKey(FocusNode node, KeyEvent event) {
          if (!speaks || (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
            return KeyEventResult.ignored;
          }

          // Along the category axis, whichever way round it runs. A horizontal
          // chart's categories go down the side, so the keys that walk them do
          // too. Physical keys on a physical axis: a chart's canvas runs left to
          // right in every locale, and so does the walk across it.
          final LogicalKeyboardKey key = event.logicalKey;
          final LogicalKeyboardKey forward = widget.horizontal
              ? LogicalKeyboardKey.arrowDown
              : LogicalKeyboardKey.arrowRight;
          final LogicalKeyboardKey back = widget.horizontal
              ? LogicalKeyboardKey.arrowUp
              : LogicalKeyboardKey.arrowLeft;

          if (key == forward) {
            step(1);
          } else if (key == back) {
            step(-1);
          } else if (key == LogicalKeyboardKey.home) {
            goTo(0);
          } else if (key == LogicalKeyboardKey.end) {
            goTo(walkLength - 1);
          } else if (key == LogicalKeyboardKey.escape && (_activeIndex != null || active != null)) {
            // Only while something is being read. With nothing to clear, the
            // key belongs to whatever the chart sits in — a sheet, a dialog —
            // and swallowing it would leave that unable to close.
            onLeave();
          } else {
            return KeyEventResult.ignored;
          }

          return KeyEventResult.handled;
        }

        /// Where the card stands for a column reached by key. Beside the top of
        /// the column on a vertical chart and beside the first value on a
        /// horizontal one, which is where the React build hangs it.
        Offset keyAnchor(int index) {
          if (!widget.horizontal) {
            return Offset(box.left + layout.categoryPx(index), box.top);
          }

          final List<int> spoken = _spokenAt(layout, index, PlassChartTooltipMode.column, null);

          return Offset(
            spoken.isEmpty ? box.left : layout.valuePx(layout.values[spoken.first][index].value!),
            box.top + layout.categoryPx(index),
          );
        }

        /// What the live region says for what is being read, or nothing.
        String readout(Offset? pointer) {
          if (!speaks) {
            return '';
          }

          if (active != null) {
            // A chart whose marks say their own reading is read the way its
            // card is: the heading, then the reading.
            if (widget.markReadout != null) {
              final String heading =
                  widget.markHeading?.call(active) ??
                  widget.series[active.series].name ??
                  '${active.series + 1}';
              final String said = widget.markReadout!(active);

              return said.isEmpty ? heading : '$heading, $said';
            }

            // A mark of a grid is one cell of a column, and is read as one: the
            // category it is in, then its series and its value.
            final ChartValue entry = layout.values[active.series][active.index];

            return '${categoryText(layout.categories[active.index], names)}, '
                '${_itemReading(widget.series[active.series].name, entry, _write)}';
          }

          final int? index = _activeIndex;

          if (index == null) {
            return '';
          }

          final List<int> spoken = _spokenAt(
            layout,
            index,
            pointer == null ? PlassChartTooltipMode.column : widget.tooltip.mode,
            pointer,
          );

          if (spoken.isEmpty) {
            return '';
          }

          return <String>[
            categoryText(layout.categories[index], names),
            for (final int i in spoken)
              _itemReading(widget.series[i].name, layout.values[i][index], _write),
          ].join(', ');
        }

        void onTap(Offset local) {
          final int? before = _activeIndex;
          final PlassChartMark? beforeMark = _activeMark;

          onMove(local);

          // A second tap on the thing already showing takes it down, which is
          // the only way to dismiss a tooltip on a screen with no pointer to
          // move away.
          if (markBuilder != null) {
            if (beforeMark != null &&
                beforeMark.series == _activeMark?.series &&
                beforeMark.index == _activeMark?.index) {
              onLeave();
            }

            return;
          }

          if (before != null && before == _activeIndex) {
            onLeave();
          }
        }

        final Widget drawing = MouseRegion(
          onHover: (PointerHoverEvent event) => onMove(event.localPosition),
          onExit: (PointerExitEvent _) => onLeave(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // A tap **leaves** the tooltip up, and a second tap on the same
            // column takes it down again. Clearing it on the release would be a
            // tooltip a reader with no pointer never gets to read: on a touch
            // screen the press and the release are a tenth of a second apart.
            onTapDown: (TapDownDetails details) => onTap(details.localPosition),
            // And a drag scrubs along the axis, which is how a column is read
            // on a phone without lifting a finger between each one.
            onHorizontalDragStart: (DragStartDetails details) => onMove(details.localPosition),
            onHorizontalDragUpdate: (DragUpdateDetails details) => onMove(details.localPosition),
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                children: <Widget>[
                  CustomPaint(
                    size: Size(width, height),
                    painter: _FramePainter(
                      layout: layout,
                      tokens: tokens,
                      fontSize: fontSize,
                      tickTexts: tickTexts,
                      categoryTexts: categoryTexts,
                      xAxis: widget.xAxis,
                      yAxis: widget.yAxis,
                      axisLabelBand: axisLabelBand,
                      tickAngle: tilted ? tickAngle : 0,
                      tickBand: tickBand,
                      references: widget.reference,
                      textDirection: Directionality.of(context),
                      paintMarks: widget.paint,
                    ),
                  ),
                  if (!widget.tooltip.hidden && (active != null || _activeIndex != null))
                    ValueListenableBuilder<Offset?>(
                      valueListenable: _pointer,
                      builder: (BuildContext context, Offset? pointer, Widget? _) {
                        // Beside the pointer when there is one, and on the
                        // thing itself when a key got there instead.
                        final Offset? at =
                            pointer ??
                            (!_keyed
                                ? null
                                : active != null
                                ? active.centre
                                : keyAnchor(_activeIndex!));

                        if (at == null) {
                          return const SizedBox.shrink();
                        }

                        if (active != null) {
                          return _MarkTooltip(
                            layout: layout,
                            mark: active,
                            color: widget.markColor?.call(active) ?? layout.colors[active.series],
                            name:
                                widget.markHeading?.call(active) ??
                                widget.series[active.series].name ??
                                '${active.series + 1}',
                            readout:
                                widget.markReadout?.call(active) ??
                                _write(layout.values[active.series][active.index].value ?? 0),
                            tokens: tokens,
                            size: size,
                          );
                        }

                        return _Tooltip(
                          layout: layout,
                          index: _activeIndex!,
                          heading: categoryText(layout.categories[_activeIndex!], names),
                          at: at,
                          pointer: pointer,
                          series: widget.series,
                          // A key has nothing to measure `item` against, so it
                          // gets the whole column.
                          mode: pointer == null
                              ? PlassChartTooltipMode.column
                              : widget.tooltip.mode,
                          tokens: tokens,
                          size: size,
                          write: _write,
                        );
                      },
                    ),
                  if (speaks)
                    ValueListenableBuilder<Offset?>(
                      valueListenable: _pointer,
                      builder: (BuildContext context, Offset? pointer, Widget? _) =>
                          _Readout(said: readout(pointer)),
                    ),
                ],
              ),
            ),
          ),
        );

        // A tab stop whenever there is something drawn, as the React build's
        // picture is. Its semantics are declared on the chart's own node below
        // rather than here: the plot is a node of its own, for the press and
        // the drag it answers, and a focus landing on that one would land on a
        // node with no name.
        return Focus(
          focusNode: _focus,
          includeSemantics: false,
          onKeyEvent: onKey,
          onFocusChange: (bool has) {
            setState(() {
              _focusVisible =
                  has && FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
            });

            // Leaving the chart clears what was being read, rather than
            // leaving the last column standing in the readout forever.
            if (!has) {
              onLeave();
            }
          },
          child: CustomPaint(
            foregroundPainter: _focusVisible
                ? PlassFocusRingPainter(
                    color: tokens.family(PlassColor.primary).ring,
                    borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.xs]!),
                    // Held off the drawing rather than flush with it, as the
                    // React build's `outline-offset-2` is: the plot has no edge
                    // of its own for the ring to thicken, and one laid on the
                    // axis labels would read as a border drawn round them.
                    offset: 2,
                  )
                : null,
            child: drawing,
          ),
        );
      },
    );

    final Widget? legend = widget.legend.hidden || widget.series.length < 2
        ? null
        : PlassChartLegendBar(
            series: widget.series,
            colors: colors,
            visible: visible,
            tokens: tokens,
            size: size,
            interactive: widget.legend.interactive,
            align: widget.legend.align,
            vertical: _beside(widget.legend.side),
            onToggle: (int index) => setState(() {
              if (!_off.remove(index)) {
                _off.add(index);
              }
            }),
            swatch: widget.swatch,
            dashed: widget.stroked ? dashed : null,
            onHover: (int? index) => setState(() => _hovered = index),
            maxEntries: widget.legend.maxEntries,
          );

    return Semantics(
      container: true,
      label: widget.semanticLabel ?? labels.chart,
      // The plot's tab stop, said on the node that carries the name, so a
      // reader arriving by Tab hears what the chart is and what it says.
      focusable: !nothing,
      focused: !nothing && _focus.hasFocus,
      onFocus: nothing ? null : _focus.requestFocus,
      // The picture is a picture, so what a screen reader is handed is every
      // value in it: each visible series, then its categories and what it was
      // worth at each. There is no table beside a Flutter chart the way there
      // is on the web, so this text is the only path to the numbers — the
      // scatter and the heatmap in this package already take it.
      value: _summaryFor(
        values,
        visible,
        categories,
        names,
        // A category is worth saying only when it says something. Given no
        // `categories` and no value scale, it is the position in the list,
        // which the order of the reading already carries — and "New, zero, four
        // thousand" is a number the reader has to work out is not data.
        named: widget.categories != null || categoryScale != null,
      ),
      child: PlassChartWithLegend(side: widget.legend.side, plot: plot, legend: legend),
    );
  }

  /// The summary, written again only when what it reads has changed.
  ///
  /// It is a whole chart's worth of text, so it is built once and kept rather
  /// than rebuilt on every pointer move over the plot.
  String _summaryFor(
    List<List<ChartValue>> values,
    List<bool> visible,
    List<PlassChartCategory> categories,
    PlDateNames names, {
    required bool named,
  }) {
    if (_said == null ||
        !identical(_saidFor, widget) ||
        !listEquals(_saidVisible, visible) ||
        _saidNames != names) {
      _said =
          widget.semanticValue?.call(visible) ??
          _summary(values, visible, categories, names, named: named);
      _saidFor = widget;
      _saidVisible = visible;
      _saidNames = names;
    }

    return _said!;
  }

  /// Each visible series, then every category it has a value at and that value.
  String _summary(
    List<List<ChartValue>> values,
    List<bool> visible,
    List<PlassChartCategory> categories,
    PlDateNames names, {
    required bool named,
  }) {
    final parts = <String>[];

    for (int i = 0; i < widget.series.length; i += 1) {
      if (!visible[i]) {
        continue;
      }

      final List<ChartValue> one = values[i];
      final String name = widget.series[i].name ?? '${i + 1}';
      final points = <String>[];

      for (int at = 0; at < one.length && at < categories.length; at += 1) {
        final ChartValue entry = one[at];

        // A gap is left out rather than read as an empty category: a reader
        // hearing "March" with nothing after it cannot tell a gap from a value
        // the writer forgot.
        if (entry.value == null) {
          continue;
        }

        final String said = entry.label ?? _write(entry.value!);

        points.add(named ? '${categoryText(categories[at], names)} $said' : said);
      }

      // A series of nothing but gaps is still named, so the reader is told it
      // is there rather than left to wonder where it went.
      parts.add(points.isEmpty ? name : '$name: ${points.join('; ')}');
    }

    // A target is a fact about the picture rather than decoration on it, so a
    // reader given the reading instead of the drawing is given the lines too.
    // An unlabelled one is read by its value, which is all a sighted reader
    // gets from it either.
    for (final PlassChartReference one in widget.reference) {
      final String said = _write(one.value);

      parts.add(one.label == null ? said : '${one.label} $said');
    }

    return parts.join('. ');
  }
}

/// The grid, the axes and — last — the marks the chart is actually about.
class _FramePainter extends CustomPainter {
  const _FramePainter({
    required this.layout,
    required this.tokens,
    required this.fontSize,
    required this.tickTexts,
    required this.categoryTexts,
    required this.xAxis,
    required this.yAxis,
    required this.axisLabelBand,
    required this.tickAngle,
    required this.tickBand,
    required this.references,
    required this.textDirection,
    required this.paintMarks,
  });

  final PlassChartLayout layout;
  final PlassTokens tokens;
  final double fontSize;
  final List<String> tickTexts;
  final List<String> categoryTexts;
  final PlChartAxis xAxis;
  final PlChartAxis yAxis;
  final double axisLabelBand;

  /// How far the category labels are turned, already clamped. `0` is upright.
  final double tickAngle;

  /// How deep their band under the plot is, which is where the axis' own name
  /// goes next. Turning them makes it several times taller, and a name written
  /// at the upright offset would land in the middle of them.
  final double tickBand;

  /// The lines drawn across the plot that are not data.
  final List<PlassChartReference> references;
  final TextDirection textDirection;
  final PlassChartMarkPainter paintMarks;

  void _text(Canvas canvas, String value, Offset at, Color ink, TextAlign align) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(fontSize: fontSize, color: ink),
      ),
      textAlign: align,
      textDirection: textDirection,
    )..layout();

    final double dx = switch (align) {
      TextAlign.center => at.dx - painter.width / 2,
      TextAlign.right => at.dx - painter.width,
      _ => at.dx,
    };

    painter.paint(canvas, Offset(dx, at.dy - painter.height / 2));
  }

  /// One category label, turned about the point it would have been centred on.
  ///
  /// The pivot is the tick's own x a few pixels under the axis, so the end of
  /// the label that touches the axis is the end that belongs to that tick. The
  /// text is laid out to the left of the pivot for a negative angle and to the
  /// right for a positive one, which is the `textAnchor` the React build sets;
  /// the rotation then swings it down into the band.
  void _turnedText(Canvas canvas, String value, Offset pivot, Color ink) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(fontSize: fontSize, color: ink),
      ),
      textDirection: textDirection,
    )..layout();

    canvas
      ..save()
      ..translate(pivot.dx, pivot.dy)
      ..rotate(tickAngle * math.pi / 180);
    painter.paint(canvas, Offset(tickAngle < 0 ? -painter.width : 0, -painter.height / 2));
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final PlotBox box = layout.plot;
    final grid = Paint()
      ..color = tokens.chartGrid
      ..strokeWidth = hairline
      ..style = PaintingStyle.stroke;

    // The grid is a rule per tick and nothing else — no frame, no border. A
    // chart drawn inside a box is a chart with two edges where the design
    // language wants none.
    if (yAxis.grid && !yAxis.hidden) {
      for (final double tick in layout.scale.ticks) {
        final double at = layout.valuePx(tick);

        canvas.drawLine(
          layout.horizontal ? Offset(at, box.top) : Offset(box.left, at),
          layout.horizontal ? Offset(at, box.bottom) : Offset(box.right, at),
          grid,
        );
      }
    }

    if (!yAxis.hidden) {
      for (int i = 0; i < layout.scale.ticks.length; i += 1) {
        final double at = layout.valuePx(layout.scale.ticks[i]);

        _text(
          canvas,
          tickTexts[i],
          layout.horizontal ? Offset(at, box.bottom + fontSize) : Offset(box.left - 8, at),
          tokens.mutedFg,
          layout.horizontal ? TextAlign.center : TextAlign.right,
        );
      }
    }

    if (!xAxis.hidden && layout.count > 0) {
      final double length = layout.categoryLength;
      final double step = layout.inset
          ? (layout.count <= 1 ? length : length / math.max(1, layout.count - 1))
          : layout.band.step;
      final double widest = categoryTexts.fold<double>(
        0,
        (double most, String text) => math.max(most, textWidth(text, fontSize)),
      );
      // A horizontal chart's labels are stacked, so what has to clear is a line
      // of text rather than the width of a word. Turned labels are parallel, so
      // what has to clear between two of them is the distance across a line of
      // text rather than the length of a name — the whole reason for turning
      // them.
      final double labelAlong = tickAngle != 0 ? tiltedPitch(tickAngle, fontSize) : widest + 12;
      final int stride = layout.horizontal
          ? tickStride(layout.count, length, fontSize + 8)
          : tickStride(layout.count, length, labelAlong);
      // A turned label leans off one end of the axis and the layout has already
      // reserved the room for it, so the last one always fits.
      final bool roomForLast =
          tickAngle != 0 ||
          fitsLast(layout.count, stride, step, layout.horizontal ? fontSize : widest);

      for (int i = 0; i < layout.count; i += 1) {
        if (!showsTick(i, layout.count, stride, roomForLast: roomForLast)) {
          continue;
        }

        if (tickAngle != 0) {
          _turnedText(
            canvas,
            categoryTexts[i],
            Offset(box.left + layout.categoryPx(i), box.bottom + 8 + fontSize / 2),
            tokens.mutedFg,
          );
          continue;
        }

        _text(
          canvas,
          categoryTexts[i],
          layout.horizontal
              ? Offset(box.left - 8, box.top + layout.categoryPx(i))
              : Offset(box.left + layout.categoryPx(i), box.bottom + fontSize),
          tokens.mutedFg,
          layout.horizontal ? TextAlign.right : TextAlign.center,
        );
      }
    }

    /* The lines that are not data.
       Over the grid and under the marks, which is the whole of what a reference
       is: something to read the data *against* rather than something to read.
       Dashed for the same reason — a solid rule across a plot is what a
       gridline is, and a reader who has learned that a solid hairline is chrome
       must not meet one that is a target. */
    for (final PlassChartReference one in references) {
      final double along = layout.valuePx(one.value);
      final Color ink = one.color ?? tokens.mutedFg;
      final Paint stroke = Paint()
        ..color = ink
        ..strokeWidth = hairline
        ..style = PaintingStyle.stroke;

      final Offset from = layout.horizontal ? Offset(along, box.top) : Offset(box.left, along);
      final Offset to = layout.horizontal ? Offset(along, box.bottom) : Offset(box.right, along);

      if (one.dashed) {
        canvas.drawPath(dashedPath(Path()..addPolygon(<Offset>[from, to], false)), stroke);
      } else {
        canvas.drawLine(from, to, stroke);
      }

      // At the far end of its own line and just clear of it, which is the one
      // place on a plot a short word can go without landing on a mark.
      if (one.label != null) {
        _text(
          canvas,
          one.label!,
          layout.horizontal
              ? Offset(along, box.top + fontSize)
              : Offset(box.right, along - fontSize),
          ink,
          layout.horizontal ? TextAlign.center : TextAlign.right,
        );
      }
    }

    // The axis names, each in the band reserved for it. The value axis' is
    // turned on its side, which is the one rotation in the library and is what
    // every chart has always done: written across, a two-word name would take a
    // third of the plot's width.
    final PlChartAxis alongTheSide = layout.horizontal ? xAxis : yAxis;
    final PlChartAxis alongTheFoot = layout.horizontal ? yAxis : xAxis;

    if (!alongTheSide.hidden && alongTheSide.label != null) {
      canvas
        ..save()
        ..translate(axisLabelBand / 2, box.top + box.height / 2)
        ..rotate(-math.pi / 2);
      _text(canvas, alongTheSide.label!, Offset.zero, tokens.mutedFg, TextAlign.center);
      canvas.restore();
    }

    if (!alongTheFoot.hidden && alongTheFoot.label != null) {
      _text(
        canvas,
        alongTheFoot.label!,
        Offset(box.left + box.width / 2, size.height - axisLabelBand / 2),
        tokens.mutedFg,
        TextAlign.center,
      );
    }

    // The crosshair goes under the marks, so a line is never drawn over by the
    // thing pointing at it.
    if (layout.activeIndex != null && layout.count > 0) {
      final double at = layout.categoryPx(layout.activeIndex!);

      canvas.drawLine(
        layout.horizontal ? Offset(box.left, box.top + at) : Offset(box.left + at, box.top),
        layout.horizontal ? Offset(box.right, box.top + at) : Offset(box.left + at, box.bottom),
        Paint()
          ..color = tokens.mutedFg.withValues(alpha: 0.35)
          ..strokeWidth = hairline,
      );
    }

    canvas.save();
    // Clipped to the plot and a marker's own radius past it, so a dot on the
    // top value is whole and a line still cannot run out over the axis labels.
    canvas.clipRect(
      Rect.fromLTWH(
        box.left - markerRadii[layout.size]! - 2,
        box.top - markerRadii[layout.size]! - 2,
        box.width + markerRadii[layout.size]! * 2 + 4,
        box.height + markerRadii[layout.size]! * 2 + 4,
      ),
    );
    paintMarks(canvas, layout);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FramePainter old) => true;
}

/// The row of names under the plot.
/// The swatch-and-name row every chart carries, cartesian or not.
///
/// Shared rather than private because a pie's slices play exactly the part a
/// line chart's series do — they are what takes a palette slot, what the reader
/// switches off, and what a hover dims the others for. A second copy of this
/// would be a second answer to what a switched-off entry looks like.
class PlassChartLegendBar extends StatefulWidget {
  /// Creates the legend.
  const PlassChartLegendBar({
    required this.series,
    required this.colors,
    required this.visible,
    required this.tokens,
    required this.size,
    required this.interactive,
    required this.align,
    required this.onToggle,
    required this.onHover,
    this.swatch,
    this.dashed,
    this.vertical = false,
    this.maxEntries,
    super.key,
  });

  /// The entries, in the order their colours were handed out.
  final List<PlassChartSeries> series;

  /// Which entries the plot draws as a dashed line, by index. Each of those is
  /// keyed with a dashed rule rather than a square. See
  /// [PlassCartesianChart.stroked].
  final List<bool>? dashed;

  /// One colour per entry.
  final List<Color> colors;

  /// Which of them are drawn.
  final List<bool> visible;

  /// The palette in scope.
  final PlassTokens tokens;

  /// The type scale.
  final PlassSize size;

  /// Whether pressing an entry switches it off.
  final bool interactive;

  /// Where the row sits along the chart's width.
  final PlassAlign align;

  /// Called with the entry that was pressed.
  final ValueChanged<int> onToggle;

  /// Called with the entry the pointer is on, or `null` when it leaves.
  final ValueChanged<int?> onHover;

  /// The swatch, for a chart whose marks are not all the same shape.
  ///
  /// A scatter past the third series tells its series apart by shape as well as
  /// by hue, and a legend answering with eight identical squares would be back
  /// to colour alone — which is the thing the shapes were added to fix.
  final Widget Function(int index, Color color)? swatch;

  /// Whether the entries are one under another, for a legend beside the plot.
  final bool vertical;

  /// Shows this many entries and folds the rest behind a button that opens
  /// them. See [PlChartLegend.maxEntries].
  final int? maxEntries;

  @override
  State<PlassChartLegendBar> createState() => _PlassChartLegendBarState();
}

class _PlassChartLegendBarState extends State<PlassChartLegendBar> {
  /// Whether the folded entries are showing. Held here rather than handed down
  /// from the chart, because it is a fact about the legend and about nothing
  /// else on the plot.
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final List<PlassChartSeries> series = widget.series;

    /* The fold. The entries kept are the *first* ones rather than the visible
       ones or the largest ones: that is the order their colours were handed out
       in, which is the order the reader has already learned, and a key that
       rearranged itself as series were switched off would stop being a key. */
    final int? cap = widget.maxEntries;
    final bool folded = cap != null && cap > 0 && series.length > cap && !_open;
    final int drawn = folded ? cap : series.length;

    final List<Widget> entries = <Widget>[
      for (int i = 0; i < drawn; i += 1)
        _LegendEntry(
          name: series[i].name ?? '${i + 1}',
          color: widget.colors[i],
          on: widget.visible[i],
          tokens: widget.tokens,
          size: widget.size,
          swatch: widget.swatch != null
              ? widget.swatch!(i, widget.colors[i])
              : (widget.dashed?[i] ?? false)
              ? _DashedRule(color: widget.colors[i], size: widget.size)
              : null,
          onTap: widget.interactive ? () => widget.onToggle(i) : null,
          onHover: (bool over) => widget.onHover(over ? i : null),
        ),
      // The way in and the way back out, on the same button. It says how many
      // are behind it rather than only 'more', so a reader who is deciding
      // whether to open it has the number.
      if (folded || _open)
        _LegendFold(
          said: folded
              ? PlassTheme.labelsOf(context).chartMore(series.length - drawn)
              : PlassTheme.labelsOf(context).chartFewer,
          open: _open,
          tokens: widget.tokens,
          size: widget.size,
          onTap: () => setState(() => _open = !_open),
        ),
    ];

    if (widget.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: entries,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 14,
        runSpacing: 6,
        alignment: switch (widget.align) {
          PlassAlign.start => WrapAlignment.start,
          PlassAlign.center => WrapAlignment.center,
          PlassAlign.end => WrapAlignment.end,
        },
        children: entries,
      ),
    );
  }
}

/// The legend's own 'and this many more', and the way back.
///
/// A real button rather than a row of dots: the entries behind it are a thing
/// a reader has to be able to reach by keyboard and be told about by a screen
/// reader, which is also why it says the number rather than only 'more'.
class _LegendFold extends StatelessWidget {
  const _LegendFold({
    required this.said,
    required this.open,
    required this.tokens,
    required this.size,
    required this.onTap,
  });

  final String said;
  final bool open;
  final PlassTokens tokens;
  final PlassSize size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      expanded: open,
      label: said,
      onTap: onTap,
      excludeSemantics: true,
      child: PlassInteractive(
        onTap: onTap,
        builder: (BuildContext context, PlassInteraction state) {
          final Widget word = Text(
            said,
            style: TextStyle(
              fontSize: metaText[size]!,
              fontWeight: FontWeight.w500,
              color: state.hovered ? tokens.fg : tokens.mutedFg,
            ),
          );

          if (!state.focusVisible) {
            return word;
          }

          return CustomPaint(
            foregroundPainter: PlassFocusRingPainter(
              color: tokens.family(PlassColor.primary).ring,
              borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.xs]!),
            ),
            child: word,
          );
        },
      ),
    );
  }
}

/// The legend's key for a `dashed` series: a short run of the line itself.
///
/// A filled square says "this colour" and nothing else, which for a forecast
/// drawn in the same hue as the measurement beside it is the one half of the key
/// that does not tell them apart. So the entry draws what the plot draws — two
/// dashes at the line's weight, in its rhythm and with its round ends — and the
/// square stays on a solid series, where the colour is the whole difference.
class _DashedRule extends StatelessWidget {
  const _DashedRule({required this.color, required this.size});

  final Color color;
  final PlassSize size;

  @override
  Widget build(BuildContext context) {
    final double stroke = lineWidths[size]!;

    // Two dashes and the gap between them, and the round ends reach half a
    // stroke past each end of that run.
    return CustomPaint(
      size: Size(lineDash * 2 + lineDashGap + stroke, 9),
      painter: _DashedRulePainter(color: color, stroke: stroke),
    );
  }
}

class _DashedRulePainter extends CustomPainter {
  const _DashedRulePainter({required this.color, required this.stroke});

  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final double y = size.height / 2;

    canvas.drawPath(
      dashedPath(
        Path()
          ..moveTo(stroke / 2, y)
          ..lineTo(size.width - stroke / 2, y),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_DashedRulePainter old) => old.color != color || old.stroke != stroke;
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry({
    required this.name,
    required this.color,
    required this.on,
    required this.tokens,
    required this.size,
    required this.onTap,
    required this.onHover,
    this.swatch,
  });

  final String name;
  final Color color;
  final bool on;
  final PlassTokens tokens;
  final PlassSize size;
  final VoidCallback? onTap;
  final ValueChanged<bool> onHover;
  final Widget? swatch;

  @override
  Widget build(BuildContext context) {
    // Switched off, the entry fades as one thing — swatch and name together, at
    // one opacity — which is what a control that has been switched off looks
    // like everywhere else in the library. The swatch keeps its own colour
    // through it: a grey swatch is a legend entry a reader has to switch back
    // on to find out what it was. And so does the name, whose recolouring to
    // the muted ink was the one place a hidden entry was told apart by a hue,
    // and read as a second kind of text rather than as the same entry, off.
    final Widget row = Opacity(
      opacity: on ? 1 : 0.4,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          swatch ??
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
              ),
          const SizedBox(width: 6),
          // Wraps rather than overflows when the legend has less room than the
          // name, which a legend beside the plot often does.
          Flexible(
            child: Text(
              name,
              style: TextStyle(
                fontSize: metaText[size]!,
                color: tokens.fg,
                // The half of "off" that survives being read in one colour.
                decoration: on ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return row;
    }

    // A switch the reader reaches by Tab as well as by pointer, and fires from
    // a screen reader: `PlassInteractive` keeps its gesture off the semantics
    // tree, so the action is declared on the node that names the entry.
    return Semantics(
      button: true,
      checked: on,
      label: name,
      onTap: onTap,
      excludeSemantics: true,
      child: MouseRegion(
        onEnter: (PointerEnterEvent _) => onHover(true),
        onExit: (PointerExitEvent _) => onHover(false),
        child: PlassInteractive(
          onTap: onTap,
          builder: (BuildContext context, PlassInteraction state) {
            if (!state.focusVisible) {
              return row;
            }

            return CustomPaint(
              foregroundPainter: PlassFocusRingPainter(
                color: tokens.family(PlassColor.primary).ring,
                borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.xs]!),
              ),
              child: row,
            );
          },
        ),
      ),
    );
  }
}

/// Which series a column's readout speaks for.
///
/// `column` is every visible one that has a value at [index]; `item` is the
/// single one whose mark [pointer] is nearest, measured along the *value* axis,
/// because where the pointer is across the plot has already settled the
/// category. The card and the live region both ask this, so what is drawn and
/// what is said cannot name two different sets of series.
List<int> _spokenAt(
  PlassChartLayout layout,
  int index,
  PlassChartTooltipMode mode,
  Offset? pointer,
) {
  final spoken = <int>[];

  for (int i = 0; i < layout.values.length; i += 1) {
    if (!layout.visible[i] || index >= layout.values[i].length) {
      continue;
    }

    if (layout.values[i][index].value != null) {
      spoken.add(i);
    }
  }

  if (mode == PlassChartTooltipMode.item && pointer != null && spoken.length > 1) {
    final double along = layout.horizontal ? pointer.dx : pointer.dy;

    double away(int i) => (layout.valuePx(layout.values[i][index].value!) - along).abs();

    int nearest = spoken.first;

    for (final int i in spoken) {
      if (away(i) < away(nearest)) {
        nearest = i;
      }
    }

    spoken
      ..clear()
      ..add(nearest);
  }

  return spoken;
}

/// One series' part of a spoken readout: its name, then what it is worth.
///
/// A series with no name is read by its value alone, as the React build reads
/// it. The card writes the series' number beside its swatch, where the swatch
/// says which line it is; said aloud with nothing beside it, "1: 12" is a
/// number the reader has to work out is not data.
String _itemReading(String? name, ChartValue entry, String Function(double) write) {
  // A point's own label wins, exactly as it does on the card.
  final String said = entry.label ?? write(entry.value!);

  return name == null ? said : '$name: $said';
}

/// What the pointer or the arrow keys have reached, said rather than drawn.
///
/// The card is a picture of the reading and is kept off the semantics tree, so
/// this is the half a screen reader hears. A live region, so a reader walking
/// the categories is told each one as it arrives without the focus moving off
/// the chart; empty when nothing is being read, so leaving the chart clears
/// what was said rather than leaving the last column standing in it.
///
/// A pixel square rather than nothing at all: a node with no size is taken
/// off the tree, and a region that comes and goes is one a browser does not
/// announce the first time it arrives.
class _Readout extends StatelessWidget {
  const _Readout({required this.said});

  final String said;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: said,
      child: const SizedBox.square(dimension: 1),
    );
  }
}

/// The card that follows the pointer, or stands on the column a key reached.
class _Tooltip extends StatelessWidget {
  const _Tooltip({
    required this.layout,
    required this.index,
    required this.heading,
    required this.at,
    required this.pointer,
    required this.series,
    required this.mode,
    required this.tokens,
    required this.size,
    required this.write,
  });

  final PlassChartLayout layout;
  final int index;
  final String heading;

  /// Where the card stands: the pointer, or the column when a key got there.
  final Offset at;

  /// The pointer, which `item` mode measures against. `null` from a key.
  final Offset? pointer;
  final List<PlassChartSeries> series;
  final PlassChartTooltipMode mode;
  final PlassTokens tokens;
  final PlassSize size;
  final String Function(double) write;

  @override
  Widget build(BuildContext context) {
    final List<int> spoken = _spokenAt(layout, index, mode, pointer);

    final rows = <Widget>[];

    for (final int i in spoken) {
      final ChartValue entry = layout.values[i][index];
      final double value = entry.value!;

      rows.add(
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: layout.colors[i],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                series[i].name ?? '${i + 1}',
                style: TextStyle(fontSize: metaText[size]!, color: tokens.mutedFg),
              ),
              const SizedBox(width: 10),
              // A point's own label wins, as it does in the React build's
              // tooltip and table. On a chart stacked to full that label is the
              // caller's number, and the value drawn is only its share.
              Text(
                entry.label ?? write(value),
                style: TextStyle(
                  fontSize: metaText[size]!,
                  fontWeight: FontWeight.w600,
                  color: tokens.fg,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    // Beside the pointer rather than under it, so the card never covers the
    // marks it is describing, and before it once the pointer is far along.
    return PlassChartTooltipPlacement(
      at: at,
      gap: 14,
      before: at.dx > layout.plot.left + layout.plot.width * 0.6,
      // The card is the half a reader sees. The half they hear is `_Readout`,
      // and a card left on the semantics tree as well was merged into the
      // name of whatever node held the plot — on a chart with no legend, the
      // chart's own, which then read "Chart, Jan, Revenue, 12" to anyone who
      // came back to it.
      child: ExcludeSemantics(
        child: PlassChartTooltipCard(tokens: tokens, size: size, heading: heading, children: rows),
      ),
    );
  }
}

bool _beside(PlassSide side) => side == PlassSide.left || side == PlassSide.right;

/// A chart with its legend on one of its four sides.
///
/// Above or below the plot, the legend is a row that wraps. Beside it, the
/// legend is a column no wider than two fifths of the chart: a row there has no
/// width to wrap at, so four or five series would stand in one line and push the
/// plot down to nothing.
class PlassChartWithLegend extends StatelessWidget {
  /// Puts [legend] on [side] of [plot].
  const PlassChartWithLegend({
    required this.side,
    required this.plot,
    required this.legend,
    super.key,
  });

  /// Which side the legend is on.
  final PlassSide side;

  /// The drawing.
  final Widget plot;

  /// The legend, or `null` for a chart that shows none.
  final Widget? legend;

  @override
  Widget build(BuildContext context) {
    final Widget? legend = this.legend;

    if (legend == null) {
      return plot;
    }

    if (!_beside(side)) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (side == PlassSide.top) legend,
          plot,
          if (side == PlassSide.bottom) legend,
        ],
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Widget column = ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.4),
          child: legend,
        );

        // A `Row` orders its children along the *writing* direction, so a
        // legend asked for on the right would be laid out on the left under
        // RTL. `PlassSide` is physical on purpose — a drawer's edge and a
        // tooltip's side are — so the row is pinned left to right and the side
        // stays where the caller put it. Nothing inside either child is pinned
        // with it: the legend's own text still reads the ambient direction.
        return Row(
          textDirection: TextDirection.ltr,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: <Widget>[
            if (side == PlassSide.left) column,
            Expanded(child: plot),
            if (side == PlassSide.right) column,
          ],
        );
      },
    );
  }
}

/// Puts a tooltip card beside the point it describes, and keeps all of it
/// inside the chart.
///
/// A chart clips what it draws to its own box, so a card placed by the point
/// alone was cut off by the bottom of a short chart and by either end of a
/// narrow one, which is where a reader is most likely to be pointing. The card
/// is measured, set [gap] after the point (or before it, when [before]), moved
/// to the other side when that side has no room, and then held inside the box.
///
/// Must be a child of the chart's `Stack`: it fills it.
class PlassChartTooltipPlacement extends StatelessWidget {
  /// Places [child] beside [at].
  const PlassChartTooltipPlacement({
    required this.at,
    required this.gap,
    required this.child,
    this.before = false,
    super.key,
  });

  /// The point the card describes, in the chart's coordinates.
  final Offset at;

  /// How far along the axis the card stands off the point.
  final double gap;

  /// Whether the card is asked for before the point rather than after it.
  final bool before;

  /// The card.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomSingleChildLayout(
        delegate: _TooltipPlacementDelegate(at: at, gap: gap, before: before),
        child: child,
      ),
    );
  }
}

class _TooltipPlacementDelegate extends SingleChildLayoutDelegate {
  const _TooltipPlacementDelegate({required this.at, required this.gap, required this.before});

  final Offset at;
  final double gap;
  final bool before;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final double after = at.dx + gap;
    final double ahead = at.dx - gap - childSize.width;
    final bool fitsAfter = after + childSize.width <= size.width;
    final bool fitsAhead = ahead >= 0;
    final double x = before
        ? (fitsAhead || !fitsAfter ? ahead : after)
        : (fitsAfter || !fitsAhead ? after : ahead);

    return Offset(
      clampDouble(x, 0, math.max(0, size.width - childSize.width)),
      clampDouble(at.dy - 20, 0, math.max(0, size.height - childSize.height)),
    );
  }

  @override
  bool shouldRelayout(_TooltipPlacementDelegate old) =>
      old.at != at || old.gap != gap || old.before != before;
}

/// The panel a chart writes its readout in.
///
/// Chrome and nothing else: the same glass, the same hairline and the same
/// shadow wherever a chart has something to say under the pointer. What goes
/// inside it differs — a cartesian chart lists every series in the column, a
/// pie names one slice — and that is the caller's business.
///
/// It ignores the pointer on purpose. A panel the pointer can enter is a panel
/// that steals the hover which produced it, and then flickers.
class PlassChartTooltipCard extends StatelessWidget {
  /// Creates the panel.
  const PlassChartTooltipCard({
    required this.tokens,
    required this.size,
    required this.heading,
    required this.children,
    super.key,
  });

  /// The palette in scope.
  final PlassTokens tokens;

  /// The type scale.
  final PlassSize size;

  /// What the readout is about — a category, or a slice's name.
  final String heading;

  /// The rows under it.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: tokens.glassPress,
          borderRadius: BorderRadius.circular(PlassTokens.radius[size]!),
          border: Border.all(color: tokens.glassLine, width: hairline),
          boxShadow: tokens.elevation(plassElevationMax),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              heading,
              style: TextStyle(
                fontSize: metaText[size]!,
                fontWeight: FontWeight.w600,
                color: tokens.fg,
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// The readout for one mark, on a plot whose marks are not in columns.
///
/// A separate widget from [_Tooltip] rather than a mode of it, because the two
/// answer different questions: a column's readout lists every series at that
/// category, and a mark's names the one thing the reader is pointing at. There
/// is nothing to list.
class _MarkTooltip extends StatelessWidget {
  const _MarkTooltip({
    required this.layout,
    required this.mark,
    required this.color,
    required this.name,
    required this.readout,
    required this.tokens,
    required this.size,
  });

  final PlassChartLayout layout;
  final PlassChartMark mark;

  /// The swatch's colour: the mark's own, which is not always its series'.
  final Color color;
  final String name;
  final String readout;
  final PlassTokens tokens;
  final PlassSize size;

  @override
  Widget build(BuildContext context) {
    // Anchored to the mark rather than to the pointer: a press on a phone lands
    // a finger's width from where the reader meant, and a card that follows
    // that lands somewhere they have to look for.
    return PlassChartTooltipPlacement(
      at: mark.centre,
      gap: (mark.rx ?? mark.r) + 10,
      before: mark.centre.dx > layout.plot.left + layout.plot.width * 0.6,
      // Off the semantics tree for the reason the column's card is.
      child: ExcludeSemantics(
        child: PlassChartTooltipCard(
          tokens: tokens,
          size: size,
          heading: name,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    readout,
                    style: TextStyle(
                      fontSize: metaText[size]!,
                      fontWeight: FontWeight.w600,
                      color: tokens.fg,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The ladder a heatmap's colours are read against.
///
/// Its own widget rather than the swatch legend with different content: what
/// this names is a *scale* and not a set of series, so there is nothing to
/// switch off and nothing to hover. The two ends are labelled and the middle
/// only when a diverging scale has one — written beside the bar rather than in
/// its own column, a middle label reads as a third end.
class PlassChartScaleLegend extends StatelessWidget {
  /// Creates the ladder.
  const PlassChartScaleLegend({
    required this.steps,
    required this.from,
    required this.to,
    required this.tokens,
    required this.size,
    this.middle,
    this.align = PlassAlign.center,
    this.vertical = false,
    super.key,
  });

  /// The ramp, pale end first.
  final List<Color> steps;

  /// What the pale end is worth.
  final String from;

  /// And the deep end.
  final String to;

  /// The palette in scope.
  final PlassTokens tokens;

  /// The type scale.
  final PlassSize size;

  /// Where a diverging scale turns over, written under the bar.
  final String? middle;

  /// Where the row sits along the chart's width.
  final PlassAlign align;

  /// Whether the legend is beside the plot rather than under it.
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final TextStyle ink = TextStyle(fontSize: metaText[size]!, color: tokens.mutedFg);

    final Widget bar = ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        width: vertical ? 80 : 96,
        height: 10,
        child: Row(
          children: <Widget>[
            for (final Color step in steps)
              Expanded(
                child: ColoredBox(color: step, child: const SizedBox.expand()),
              ),
          ],
        ),
      ),
    );

    final Widget ladder = Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: switch (align) {
          PlassAlign.start => MainAxisAlignment.start,
          PlassAlign.center => MainAxisAlignment.center,
          PlassAlign.end => MainAxisAlignment.end,
        },
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(from, style: ink),
                  const SizedBox(width: 8),
                  bar,
                  const SizedBox(width: 8),
                  Text(to, style: ink),
                ],
              ),
              if (middle != null)
                SizedBox(
                  width: vertical ? 80 : 96,
                  child: Text(middle!, textAlign: TextAlign.center, style: ink),
                ),
            ],
          ),
        ],
      ),
    );

    // Its own node rather than two or three loose numbers. Left to merge, the
    // ends of the ramp are absorbed into whatever container is above them —
    // which on a heatmap is the chart's own name, so `Chart` reads as
    // `Chart 4 40`.
    return Semantics(
      container: true,
      label: middle == null ? '$from – $to' : '$from – $middle – $to',
      excludeSemantics: true,
      child: ladder,
    );
  }
}
