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

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/chart.dart';
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
    required this.activeIndex,
    required this.hovered,
    required this.tokens,
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

  /// The category under the pointer, or `null`.
  final int? activeIndex;

  /// The series the legend is being hovered over, or `null`.
  final int? hovered;

  /// The theme, for the ink a mark's own label is written in.
  final PlassTokens tokens;

  /// How many categories there are.
  int get count => categories.length;

  /// Where a value sits along the value axis, in pixels from the chart's edge.
  double valuePx(double value) => plot.top + (1 - scale.fraction(value)) * plot.height;

  /// Where a category's centre sits along the category axis.
  ///
  /// A line's first point sits *on* the axis and a bar's first band starts at
  /// it, which is one half-step apart; [inset] is which of the two this is.
  double categoryPx(int index) {
    if (!inset) {
      return band.centre(index);
    }

    return count <= 1 ? plot.width / 2 : plot.width * index / (count - 1);
  }

  /// The two combined.
  Offset point(int index, double value) => Offset(plot.left + categoryPx(index), valuePx(value));

  /// Where the baseline is along the value axis.
  double get zeroPx => valuePx(math.min(math.max(0, scale.min), scale.max));
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
    this.includeZero = true,
    this.headroom = 0,
    this.format,
    this.semanticLabel,
    this.empty,
    this.size,
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

  @override
  State<PlassCartesianChart> createState() => _PlassCartesianChartState();
}

class _PlassCartesianChartState extends State<PlassCartesianChart> {
  /// Which series the reader has switched off in the legend.
  final Set<int> _off = <int>{};

  int? _activeIndex;
  int? _hovered;
  Offset? _pointer;

  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;

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
    final PlassSize size = _size;
    final double fontSize = chartFontSizes[size]!;
    final double height = widget.height ?? plotHeights[size]!;

    final List<List<ChartValue>> values = toValues(widget.series);
    final List<bool> visible = <bool>[
      for (int i = 0; i < widget.series.length; i += 1)
        !_off.contains(i) && !widget.series[i].hidden,
    ];
    final List<Color> colors = <Color>[
      for (int i = 0; i < widget.series.length; i += 1)
        seriesColor(widget.series[i].color, i, tokens.chart),
    ];

    final List<List<ChartValue>> shown = <List<ChartValue>>[
      for (int i = 0; i < values.length; i += 1)
        if (visible[i]) values[i] else <ChartValue>[],
    ];

    final int count = categoryCount(widget.series);
    final List<PlassChartCategory> categories = <PlassChartCategory>[
      for (int i = 0; i < count; i += 1) categoryAt(i, widget.categories, values),
    ];

    final ChartExtent? extent = extentOf(shown, stacked: widget.stacked);
    final bool nothing = extent == null;

    final ValueScale scale = valueScale(
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
            child: Center(
              child: Text(
                widget.empty is Text ? (widget.empty! as Text).data! : labels.empty,
                style: TextStyle(fontSize: metaText[size]!, color: tokens.mutedFg),
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
        final double left = widget.yAxis.thickness ?? valueBand;
        final double bottom =
            widget.xAxis.thickness ??
            (widget.xAxis.hidden
                ? 0
                : fontSize + 12 + (widget.xAxis.label != null ? axisLabelBand : 0));

        final double slot = (width - left - 16) / math.max(1, count);
        final List<String> categoryTexts = categories
            .map(
              (PlassChartCategory category) =>
                  truncateLabel(category.toString(), math.max(0, slot - 6), fontSize),
            )
            .toList();
        final double widestCategory = categoryTexts.fold<double>(
          0,
          (double most, String text) => math.max(most, textWidth(text, fontSize)),
        );

        // The last category's label is centred on the last tick, so half of it
        // hangs past the plot. Reserving that half is what stops a chart
        // clipping the one label a reader looks for first.
        final double rightPad = math.max(8, categoryTexts.isEmpty ? 8 : widestCategory / 2);
        // A mark is drawn from its centre, so half of the widest one hangs over
        // the top of the plot.
        final double topPad = markerRadii[size]! + 4 + widget.headroom;

        final box = PlotBox(
          left,
          topPad,
          math.max(0, width - left - rightPad),
          math.max(0, height - topPad - bottom),
        );

        // Bars divide the axis into `count` slots and sit in the middle of one;
        // lines divide it into `count - 1` gaps and sit on the joins. Both need
        // a step, because the hit target for a category is one step wide either
        // way.
        final band = BandScale(
          widget.inset ? math.max(1, count - 1) : count,
          box.width,
          barBandRatio[PlassDensity.standard]!,
        );

        final layout = PlassChartLayout(
          plot: box,
          values: values,
          visible: visible,
          colors: colors,
          scale: scale,
          band: band,
          categories: categories,
          size: size,
          inset: widget.inset,
          activeIndex: _activeIndex,
          hovered: _hovered,
          tokens: tokens,
        );

        void onMove(Offset local) {
          if (widget.tooltip.hidden ||
              widget.tooltip.mode == PlassChartTooltipMode.none ||
              count == 0) {
            return;
          }

          final double along = (local.dx - box.left).clamp(0, box.width);
          final int index = widget.inset
              ? (count <= 1 ? 0 : (along / (box.width / math.max(1, count - 1))).round())
              : (along / band.step).floor();
          final int clamped = index.clamp(0, count - 1);

          if (clamped != _activeIndex || local != _pointer) {
            setState(() {
              _activeIndex = clamped;
              _pointer = local;
            });
          }
        }

        void onLeave() {
          if (_activeIndex != null) {
            setState(() {
              _activeIndex = null;
              _pointer = null;
            });
          }
        }

        void onTap(Offset local) {
          final int? before = _activeIndex;

          onMove(local);

          // A second tap on the column already showing takes it down, which is
          // the only way to dismiss a tooltip on a screen with no pointer to
          // move away.
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
                  if (_activeIndex != null && _pointer != null && !widget.tooltip.hidden)
                    _Tooltip(
                      layout: layout,
                      index: _activeIndex!,
                      pointer: _pointer!,
                      series: widget.series,
                      tokens: tokens,
                      size: size,
                      write: _write,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );

    final Widget legend = widget.legend.hidden || widget.series.length < 2
        ? const SizedBox.shrink()
        : _Legend(
            series: widget.series,
            colors: colors,
            visible: visible,
            tokens: tokens,
            size: size,
            interactive: widget.legend.interactive,
            align: widget.legend.align,
            onToggle: (int index) => setState(() {
              if (!_off.remove(index)) {
                _off.add(index);
              }
            }),
            onHover: (int? index) => setState(() => _hovered = index),
          );

    final bool below =
        widget.legend.side == PlassSide.bottom || widget.legend.side == PlassSide.top;

    return Semantics(
      container: true,
      label: widget.semanticLabel ?? labels.chart,
      // The picture is a picture. What a screen reader is handed instead is the
      // series and their ends, which is the reading a sighted reader takes from
      // the shape — not a cell-by-cell recital of the whole table.
      value: _summary(values, visible),
      child: below
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (widget.legend.side == PlassSide.top) legend,
                plot,
                if (widget.legend.side == PlassSide.bottom) legend,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (widget.legend.side == PlassSide.left) legend,
                Expanded(child: plot),
                if (widget.legend.side == PlassSide.right) legend,
              ],
            ),
    );
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
      final String name = widget.series[i].name ?? 'Series ${i + 1}';

      parts.add(last == null ? name : '$name ${_write(last.value!)}');
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
      ..color = tokens.divider
      ..strokeWidth = hairline
      ..style = PaintingStyle.stroke;

    // The grid is a rule per tick and nothing else — no frame, no border. A
    // chart drawn inside a box is a chart with two edges where the design
    // language wants none.
    if (yAxis.grid && !yAxis.hidden) {
      for (final double tick in layout.scale.ticks) {
        final double y = layout.valuePx(tick);

        canvas.drawLine(Offset(box.left, y), Offset(box.right, y), grid);
      }
    }

    if (!yAxis.hidden) {
      for (int i = 0; i < layout.scale.ticks.length; i += 1) {
        _text(
          canvas,
          tickTexts[i],
          Offset(box.left - 8, layout.valuePx(layout.scale.ticks[i])),
          tokens.mutedFg,
          TextAlign.right,
        );
      }
    }

    if (!xAxis.hidden && layout.count > 0) {
      final double step = layout.inset
          ? (layout.count <= 1 ? box.width : box.width / math.max(1, layout.count - 1))
          : layout.band.step;
      final double widest = categoryTexts.fold<double>(
        0,
        (double most, String text) => math.max(most, textWidth(text, fontSize)),
      );
      final int stride = tickStride(layout.count, box.width, widest + 12);
      final bool roomForLast = fitsLast(layout.count, stride, step, widest);

      for (int i = 0; i < layout.count; i += 1) {
        if (!showsTick(i, layout.count, stride, roomForLast: roomForLast)) {
          continue;
        }

        _text(
          canvas,
          categoryTexts[i],
          Offset(box.left + layout.categoryPx(i), box.bottom + fontSize),
          tokens.mutedFg,
          TextAlign.center,
        );
      }
    }

    // The axis names, each in the band reserved for it. The value axis' is
    // turned on its side, which is the one rotation in the library and is what
    // every chart has always done: written across, a two-word name would take a
    // third of the plot's width.
    if (!yAxis.hidden && yAxis.label != null) {
      canvas
        ..save()
        ..translate(axisLabelBand / 2, box.top + box.height / 2)
        ..rotate(-math.pi / 2);
      _text(canvas, yAxis.label!, Offset.zero, tokens.mutedFg, TextAlign.center);
      canvas.restore();
    }

    if (!xAxis.hidden && xAxis.label != null) {
      _text(
        canvas,
        xAxis.label!,
        Offset(box.left + box.width / 2, size.height - axisLabelBand / 2),
        tokens.mutedFg,
        TextAlign.center,
      );
    }

    // The crosshair goes under the marks, so a line is never drawn over by the
    // thing pointing at it.
    if (layout.activeIndex != null && layout.count > 0) {
      final double x = box.left + layout.categoryPx(layout.activeIndex!);

      canvas.drawLine(
        Offset(x, box.top),
        Offset(x, box.bottom),
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
class _Legend extends StatelessWidget {
  const _Legend({
    required this.series,
    required this.colors,
    required this.visible,
    required this.tokens,
    required this.size,
    required this.interactive,
    required this.align,
    required this.onToggle,
    required this.onHover,
  });

  final List<PlassChartSeries> series;
  final List<Color> colors;
  final List<bool> visible;
  final PlassTokens tokens;
  final PlassSize size;
  final bool interactive;
  final PlassAlign align;
  final ValueChanged<int> onToggle;
  final ValueChanged<int?> onHover;

  @override
  Widget build(BuildContext context) {
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
        children: <Widget>[
          for (int i = 0; i < series.length; i += 1)
            _LegendEntry(
              name: series[i].name ?? 'Series ${i + 1}',
              color: colors[i],
              on: visible[i],
              tokens: tokens,
              size: size,
              onTap: interactive ? () => onToggle(i) : null,
              onHover: (bool over) => onHover(over ? i : null),
            ),
        ],
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
  });

  final String name;
  final Color color;
  final bool on;
  final PlassTokens tokens;
  final PlassSize size;
  final VoidCallback? onTap;
  final ValueChanged<bool> onHover;

  @override
  Widget build(BuildContext context) {
    final Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // The swatch keeps its colour when the series is switched off, and the
        // *name* is what dims: a grey swatch is a legend entry a reader has to
        // switch back on to find out what it was.
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color.withValues(alpha: on ? 1 : 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          name,
          style: TextStyle(
            fontSize: metaText[size]!,
            color: on ? tokens.fg : tokens.mutedFg,
            decoration: on ? null : TextDecoration.lineThrough,
          ),
        ),
      ],
    );

    if (onTap == null) {
      return row;
    }

    return Semantics(
      button: true,
      checked: on,
      label: name,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (PointerEnterEvent _) => onHover(true),
        onExit: (PointerExitEvent _) => onHover(false),
        child: GestureDetector(onTap: onTap, child: row),
      ),
    );
  }
}

/// The card that follows the pointer.
class _Tooltip extends StatelessWidget {
  const _Tooltip({
    required this.layout,
    required this.index,
    required this.pointer,
    required this.series,
    required this.tokens,
    required this.size,
    required this.write,
  });

  final PlassChartLayout layout;
  final int index;
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

      final double? value = layout.values[i][index].value;

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
                series[i].name ?? 'Series ${i + 1}',
                style: TextStyle(fontSize: metaText[size]!, color: tokens.mutedFg),
              ),
              const SizedBox(width: 10),
              Text(
                write(value),
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

    // Placed on whichever side of the pointer has room, so the card never
    // covers the marks it is describing.
    final bool toTheStart = pointer.dx > layout.plot.left + layout.plot.width * 0.6;

    return Positioned(
      left: toTheStart ? null : pointer.dx + 14,
      right: toTheStart ? layout.plot.width + layout.plot.left - pointer.dx + 14 : null,
      top: math.max(0, pointer.dy - 20),
      child: IgnorePointer(
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
                layout.categories[index].toString(),
                style: TextStyle(
                  fontSize: metaText[size]!,
                  fontWeight: FontWeight.w600,
                  color: tokens.fg,
                ),
              ),
              ...rows,
            ],
          ),
        ),
      ),
    );
  }
}
