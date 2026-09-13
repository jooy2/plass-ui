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
    this.grid = true,
    this.thickness,
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

  /// Rules across the plot at each tick.
  final bool grid;

  /// Overrides the band the axis reserves, in logical pixels.
  final double? thickness;

  /// How a tick is written.
  final String Function(double value)? format;
}

/// Where the legend goes, and whether there is one.
class PlChartLegend {
  /// Creates a legend.
  const PlChartLegend({
    this.hidden = false,
    this.side = PlassSide.bottom,
    this.align = PlassAlign.center,
    this.interactive = true,
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

/// Everything a mark painter is told, once the frame has laid itself out.
class PlassChartLayout {
  /// Creates a layout.
  const PlassChartLayout({
    required this.plot,
    required this.values,
    required this.visible,
    required this.colors,
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
    this.markReadout,
    this.markHeading,
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

  /// What the readout says about a mark, for a chart whose marks are not in a
  /// grid the frame can look an answer up in.
  final String Function(PlassChartMark mark)? markReadout;

  /// And what it is called, for a chart whose marks name themselves rather than
  /// taking their series' name. A Gantt's spans do.
  final String Function(PlassChartMark mark)? markHeading;

  /// The value axis' scale, already worked out.
  ///
  /// For the axis that is not a count. [valueScale] rounds to 1-2-5, which is
  /// the family a reader does arithmetic in and exactly the wrong one for an
  /// instant — sixty, twenty-four, seven, twelve. A chart whose axis has its
  /// own arithmetic builds the scale itself and hands it over.
  final ValueScale? scale;

  /// What a screen reader is handed in place of the drawing, for a chart whose
  /// summary is not "each series and where it ended up".
  final String Function()? semanticValue;

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

  @override
  void dispose() {
    _pointer.dispose();
    super.dispose();
  }

  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

  String _write(double value) {
    if (widget.format != null) {
      return widget.format!(value);
    }

    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
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
        valueScale(
          extent,
          min: widget.yAxis.min,
          max: widget.yAxis.max,
          tickCount: widget.yAxis.tickCount,
          includeZero: widget.includeZero && widget.yAxis.min == null,
        );

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
        final List<String> categoryTexts = fitCategoryLabels(
          categoryScale == null
              ? <String>[
                  for (final PlassChartCategory category in categories)
                    categoryText(category, names),
                ]
              : widget.xAxis.format != null
              ? <String>[for (final double tick in categoryScale.ticks) widget.xAxis.format!(tick)]
              : categoryScale is TimeScale
              ? formatTimeTicks(categoryScale.ticks, categoryScale.unit, names)
              : <String>[
                  for (final PlassChartCategory category in categories)
                    categoryText(category, names),
                ],
          horizontal: widget.horizontal,
          slot: slot,
          fontSize: fontSize,
          ticks: categoryScale != null,
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
        final double left = widget.horizontal
            ? (widget.xAxis.thickness ?? categoryBand)
            : (widget.yAxis.thickness ?? valueBand);
        final double bottom = widget.horizontal
            ? (widget.yAxis.thickness ??
                  (widget.yAxis.hidden
                      ? 0
                      : fontSize + 12 + (widget.yAxis.label != null ? axisLabelBand : 0)))
            : (widget.xAxis.thickness ??
                  (widget.xAxis.hidden
                      ? 0
                      : fontSize + 12 + (widget.xAxis.label != null ? axisLabelBand : 0)));

        // The last category's label is centred on the last tick, so half of it
        // hangs past the plot. Reserving that half is what stops a chart
        // clipping the one label a reader looks for first — and a horizontal
        // chart needs none of it, because its category labels are in a column.
        final double rightPad = widget.horizontal
            ? 12
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

        /* The marks are built from the layout and then handed back to it, which
           is the only order that works: a builder that could read what is
           active would be reading a value that does not exist yet. */
        final List<PlassChartMark> built = widget.marks?.call(base) ?? const <PlassChartMark>[];
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
          if (widget.marks != null) {
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
            });
          }

          _pointer.value = null;
        }

        void onTap(Offset local) {
          final int? before = _activeIndex;
          final PlassChartMark? beforeMark = _activeMark;

          onMove(local);

          // A second tap on the thing already showing takes it down, which is
          // the only way to dismiss a tooltip on a screen with no pointer to
          // move away.
          if (widget.marks != null) {
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

        return MouseRegion(
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
                      textDirection: Directionality.of(context),
                      paintMarks: widget.paint,
                    ),
                  ),
                  if (!widget.tooltip.hidden && (active != null || _activeIndex != null))
                    ValueListenableBuilder<Offset?>(
                      valueListenable: _pointer,
                      builder: (BuildContext context, Offset? pointer, Widget? _) {
                        if (pointer == null) {
                          return const SizedBox.shrink();
                        }

                        if (active != null) {
                          return _MarkTooltip(
                            layout: layout,
                            mark: active,
                            pointer: pointer,
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
                          pointer: pointer,
                          series: widget.series,
                          tokens: tokens,
                          size: size,
                          write: _write,
                        );
                      },
                    ),
                ],
              ),
            ),
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
            onHover: (int? index) => setState(() => _hovered = index),
          );

    return Semantics(
      container: true,
      label: widget.semanticLabel ?? labels.chart,
      // The picture is a picture. What a screen reader is handed instead is the
      // series and their ends, which is the reading a sighted reader takes from
      // the shape — not a cell-by-cell recital of the whole table.
      value: _summaryFor(values, visible),
      child: PlassChartWithLegend(side: widget.legend.side, plot: plot, legend: legend),
    );
  }

  /// The summary, written again only when what it reads has changed.
  String _summaryFor(List<List<ChartValue>> values, List<bool> visible) {
    if (_said == null || !identical(_saidFor, widget) || !listEquals(_saidVisible, visible)) {
      _said = widget.semanticValue?.call() ?? _summary(values, visible);
      _saidFor = widget;
      _saidVisible = visible;
    }

    return _said!;
  }

  /// What each visible series is called and where it ended up.
  String _summary(List<List<ChartValue>> values, List<bool> visible) {
    final parts = <String>[];

    for (int i = 0; i < widget.series.length; i += 1) {
      if (!visible[i]) {
        continue;
      }

      final List<ChartValue> one = values[i];
      final ChartValue? last = one.cast<ChartValue?>().lastWhere(
        (ChartValue? entry) => entry?.value != null,
        orElse: () => null,
      );
      final String name = widget.series[i].name ?? '${i + 1}';

      parts.add(last == null ? name : '$name ${last.label ?? _write(last.value!)}');
    }

    return parts.join(', ');
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
      // of text rather than the width of a word.
      final int stride = layout.horizontal
          ? tickStride(layout.count, length, fontSize + 8)
          : tickStride(layout.count, length, widest + 12);
      final bool roomForLast = fitsLast(
        layout.count,
        stride,
        step,
        layout.horizontal ? fontSize : widest,
      );

      for (int i = 0; i < layout.count; i += 1) {
        if (!showsTick(i, layout.count, stride, roomForLast: roomForLast)) {
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
class PlassChartLegendBar extends StatelessWidget {
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
    this.vertical = false,
    super.key,
  });

  /// The entries, in the order their colours were handed out.
  final List<PlassChartSeries> series;

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

  @override
  Widget build(BuildContext context) {
    final List<Widget> entries = <Widget>[
      for (int i = 0; i < series.length; i += 1)
        _LegendEntry(
          name: series[i].name ?? '${i + 1}',
          color: colors[i],
          on: visible[i],
          tokens: tokens,
          size: size,
          swatch: swatch == null ? null : swatch!(i, colors[i]),
          onTap: interactive ? () => onToggle(i) : null,
          onHover: (bool over) => onHover(over ? i : null),
        ),
    ];

    if (vertical) {
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
        alignment: switch (align) {
          PlassAlign.start => WrapAlignment.start,
          PlassAlign.center => WrapAlignment.center,
          PlassAlign.end => WrapAlignment.end,
        },
        children: entries,
      ),
    );
  }
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
    final Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // The swatch keeps its colour when the series is switched off, and the
        // *name* is what dims: a grey swatch is a legend entry a reader has to
        // switch back on to find out what it was.
        Opacity(
          opacity: on ? 1 : 0.4,
          child:
              swatch ??
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
              ),
        ),
        const SizedBox(width: 6),
        // Wraps rather than overflows when the legend has less room than the
        // name, which a legend beside the plot often does.
        Flexible(
          child: Text(
            name,
            style: TextStyle(
              fontSize: metaText[size]!,
              color: on ? tokens.fg : tokens.mutedFg,
              decoration: on ? null : TextDecoration.lineThrough,
            ),
          ),
        ),
      ],
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

/// The card that follows the pointer.
class _Tooltip extends StatelessWidget {
  const _Tooltip({
    required this.layout,
    required this.index,
    required this.heading,
    required this.pointer,
    required this.series,
    required this.tokens,
    required this.size,
    required this.write,
  });

  final PlassChartLayout layout;
  final int index;
  final String heading;
  final Offset pointer;
  final List<PlassChartSeries> series;
  final PlassTokens tokens;
  final PlassSize size;
  final String Function(double) write;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    for (int i = 0; i < series.length; i += 1) {
      if (!layout.visible[i] || index >= layout.values[i].length) {
        continue;
      }

      final ChartValue entry = layout.values[i][index];
      final double? value = entry.value;

      if (value == null) {
        continue;
      }

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
      at: pointer,
      gap: 14,
      before: pointer.dx > layout.plot.left + layout.plot.width * 0.6,
      child: PlassChartTooltipCard(tokens: tokens, size: size, heading: heading, children: rows),
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

        return Row(
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
    required this.pointer,
    required this.name,
    required this.readout,
    required this.tokens,
    required this.size,
  });

  final PlassChartLayout layout;
  final PlassChartMark mark;
  final Offset pointer;
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
                  decoration: BoxDecoration(
                    color: layout.colors[mark.series],
                    borderRadius: BorderRadius.circular(2),
                  ),
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
