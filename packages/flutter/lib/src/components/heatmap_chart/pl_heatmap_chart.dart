/// A magnitude per cell, coloured rather than measured.
library;

import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/chart.dart';
import 'package:plass_ui/src/internal/chart_frame.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

// The scale kind is arithmetic, so it lives with the arithmetic — but it is a
// prop, so it has to reach a caller. Re-exported here rather than copied, for
// the reason `PlLineChart` re-exports the curve.
export 'package:plass_ui/src/internal/chart.dart' show PlChartScaleKind;

/// The corner radius of a cell. Small — a tile is a block, not a chip.
const double _cellRadius = 3;

/// Which of the two drawings a heatmap is.
enum PlHeatmapShape {
  /// A cell per row and column, for two categorical axes and one magnitude.
  grid,

  /// A tile per datum, sized by its share and packed to fill the box.
  treemap,
}

/// What is written on a cell.
enum PlHeatmapLabels {
  /// Nothing on a grid; a tile's own name on a treemap.
  none,

  /// The value too, where the cell is big enough to hold it.
  all,
}

/// A magnitude per cell, coloured rather than measured.
///
/// Two shapes of the same idea. A [PlHeatmapShape.grid] is the one to reach for
/// when both axes are categorical and the question is *where* — which hour of
/// which day, which cohort in which week; a bar chart of the same data would be
/// forty bars nobody can scan. A [PlHeatmapShape.treemap] is for parts of a
/// whole with more parts than a `PlPieChart` can hold, and it is the same
/// widget because the data is the same shape: a row of a heatmap and a group of
/// a treemap are both a named series of named magnitudes.
///
/// Colour here encodes *size* and not identity, so it comes off a one-hue ramp
/// rather than off the categorical palette — a heatmap in eight hues says its
/// cells are eight unrelated things.
///
/// ```dart
/// PlHeatmapChart(series: hours, categories: weekdays)
/// ```
class PlHeatmapChart extends StatefulWidget {
  /// Creates a heatmap.
  const PlHeatmapChart({
    required this.series,
    this.categories,
    this.shape = PlHeatmapShape.grid,
    this.scale = PlChartScaleKind.sequential,
    this.midpoint = 0,
    this.min,
    this.max,
    this.valueLabels = PlHeatmapLabels.none,
    this.legend = const PlChartLegend(),
    this.tooltip = const PlChartTooltip(),
    this.height,
    this.format,
    this.semanticLabel,
    this.empty,
    this.size,
    super.key,
  });

  /// The rows. Each series is a row of the grid or a group of the treemap, and
  /// each datum a cell or a tile.
  ///
  /// A gap leaves the cell as surface rather than drawing it as the bottom of
  /// the scale, because "nothing happened" and "the least of anything" are not
  /// the same reading.
  final List<PlassChartSeries> series;

  /// The column names. Points may carry their own `x` instead.
  final List<PlassChartCategory>? categories;

  /// Whether the cells are a grid or a packed treemap.
  final PlHeatmapShape shape;

  /// How the magnitude is coloured.
  final PlChartScaleKind scale;

  /// Where a diverging scale turns over.
  final double midpoint;

  /// Where the scale starts. Taken from the data otherwise.
  final double? min;

  /// And where it ends.
  final double? max;

  /// Whether each cell carries its value.
  final PlHeatmapLabels valueLabels;

  /// The scale legend. Only its side and alignment are read — there is nothing
  /// on a scale to switch off.
  final PlChartLegend legend;

  /// The readout under the pointer.
  final PlChartTooltip tooltip;

  /// How tall the drawing is.
  final double? height;

  /// How a value is written.
  final String Function(double value)? format;

  /// What the whole drawing is called.
  final String? semanticLabel;

  /// What is drawn when there is nothing to draw.
  final Widget? empty;

  /// Type scale and plot height.
  final PlassSize? size;

  @override
  State<PlHeatmapChart> createState() => _PlHeatmapChartState();
}

class _PlHeatmapChartState extends State<PlHeatmapChart> {
  /// Which cell the pointer is on, by its two coordinates.
  ///
  /// The coordinates and not the placed cell: the cells are laid out afresh on
  /// every build, so holding one would mean comparing a new instance against an
  /// old one — which is never equal, and which made a second press on the same
  /// cell fail to dismiss its readout.
  ({int row, int index})? _active;

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
    final PlassSize size = widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final double fontSize = chartFontSizes[size]!;
    final double plotHeight = widget.height ?? plotHeights[size]!;

    final List<List<ChartValue>> values = toValues(widget.series);

    int columns = 0;

    for (final List<ChartValue> row in values) {
      columns = math.max(columns, row.length);
    }

    final List<PlassChartCategory> columnNames = <PlassChartCategory>[
      for (int i = 0; i < columns; i += 1) categoryAt(i, widget.categories, values),
    ];
    final List<String> rowNames = <String>[
      for (int i = 0; i < widget.series.length; i += 1) widget.series[i].name ?? '${i + 1}',
    ];

    /* The scale, over every cell. One ladder for the whole chart and not one
       per row: the colour of a cell has to mean the same number wherever it is,
       which is the entire promise a heatmap makes. */
    double low = double.infinity;
    double high = double.negativeInfinity;
    bool seen = false;

    for (final List<ChartValue> row in values) {
      for (final ChartValue cell in row) {
        if (cell.value == null) {
          continue;
        }

        seen = true;
        low = math.min(low, cell.value!);
        high = math.max(high, cell.value!);
      }
    }

    final double from = widget.min ?? (seen ? low : 0);
    final double to = widget.max ?? (seen ? high : 1);
    final bool nothing = !seen || columns == 0 || widget.series.isEmpty;

    final List<Color> ramp = widget.scale == PlChartScaleKind.diverging
        ? tokens.chartDiverging
        : tokens.chartSequential;
    final List<Color> ink = widget.scale == PlChartScaleKind.diverging
        ? tokens.chartDivergingOn
        : tokens.chartSequentialOn;

    final Widget plot = SizedBox(
      height: plotHeight,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : plotHeight * 2;

          if (nothing || width <= 0) {
            return Center(
              child:
                  widget.empty ??
                  Text(
                    labels.empty,
                    style: TextStyle(fontSize: metaText[size]!, color: tokens.mutedFg),
                  ),
            );
          }

          /* The two bands the names take out of the box, measured from the
             names themselves. A treemap has neither: its tiles are named on
             their own faces, which is the trade it makes for filling the box
             edge to edge.

             The row band is capped at a quarter of the width. A grid that hands
             a third of itself to a column of words has stopped being a grid,
             and a name that does not fit is cut. */
          final bool grid = widget.shape == PlHeatmapShape.grid;
          final List<String> rowTexts = grid
              ? <String>[
                  for (final String name in rowNames)
                    truncateLabel(name, math.min(150, width * 0.25), fontSize),
                ]
              : const <String>[];

          double band = 0;

          for (final String text in rowTexts) {
            band = math.max(band, textWidth(text, fontSize));
          }

          final double left = grid ? band + 10 : 0;
          final double columnBand = grid ? fontSize + 8 : 0;
          final double plotWidth = math.max(0, width - left);
          final double innerHeight = math.max(0, plotHeight - columnBand);

          final List<_Cell> cells = _layout(
            values: values,
            grid: grid,
            inset: left,
            width: plotWidth,
            height: innerHeight,
            columns: columns,
          );

          ({int row, int index})? under(Offset at) {
            for (final _Cell cell in cells) {
              if (cell.rect.contains(at)) {
                return (row: cell.row, index: cell.index);
              }
            }

            return null;
          }

          final bool quiet =
              widget.tooltip.hidden || widget.tooltip.mode == PlassChartTooltipMode.none;

          void press(Offset at) {
            if (quiet) {
              return;
            }

            final ({int row, int index})? found = under(at);

            // A second press on the cell already showing takes it down, which
            // is the only way to dismiss a readout on a screen with no pointer
            // to move away.
            setState(() => _active = found == null || found == _active ? null : found);
          }

          /// The placed cell the readout is about, looked up rather than held.
          _Cell? shown;

          for (final _Cell cell in cells) {
            if (cell.row == _active?.row && cell.index == _active?.index) {
              shown = cell;
              break;
            }
          }

          return MouseRegion(
            onHover: (PointerHoverEvent event) {
              if (quiet) {
                return;
              }

              final ({int row, int index})? found = under(event.localPosition);

              if (found != _active) {
                setState(() => _active = found);
              }
            },
            onExit: (PointerExitEvent _) {
              if (_active != null) {
                setState(() => _active = null);
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (TapDownDetails details) => press(details.localPosition),
              child: Stack(
                children: <Widget>[
                  CustomPaint(
                    size: Size(width, plotHeight),
                    painter: _HeatmapPainter(
                      cells: cells,
                      grid: grid,
                      rowTexts: rowTexts,
                      columnNames: columnNames,
                      inset: left,
                      plotWidth: plotWidth,
                      plotHeight: innerHeight,
                      columns: columns,
                      rows: widget.series.length,
                      ramp: ramp,
                      ink: ink,
                      surface: tokens.surface,
                      mutedFg: tokens.mutedFg,
                      fontSize: fontSize,
                      from: from,
                      to: to,
                      scale: widget.scale,
                      midpoint: widget.midpoint,
                      labelled: widget.valueLabels == PlHeatmapLabels.all,
                      active: shown,
                      write: _write,
                    ),
                  ),
                  if (shown != null && !widget.tooltip.hidden)
                    Positioned(
                      left: math.min(
                        math.max(0, shown.rect.center.dx + 12),
                        math.max(0, width - 160),
                      ),
                      top: math.max(0, shown.rect.top - 8),
                      child: PlassChartTooltipCard(
                        tokens: tokens,
                        size: size,
                        // Both coordinates, which is what a cell *is*. The row
                        // underneath then has only the number left to carry.
                        heading: '${rowNames[_active!.row]} · ${columnNames[_active!.index]}',
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              shown.value.label ?? _write(shown.value.value ?? 0),
                              style: TextStyle(
                                fontSize: metaText[size]!,
                                fontWeight: FontWeight.w600,
                                color: tokens.fg,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );

    final Widget legend = widget.legend.hidden || nothing
        ? const SizedBox.shrink()
        : PlassChartScaleLegend(
            steps: ramp,
            from: _write(
              widget.scale == PlChartScaleKind.diverging
                  ? widget.midpoint - _reach(from, to, widget.midpoint)
                  : from,
            ),
            to: _write(
              widget.scale == PlChartScaleKind.diverging
                  ? widget.midpoint + _reach(from, to, widget.midpoint)
                  : to,
            ),
            middle: widget.scale == PlChartScaleKind.diverging ? _write(widget.midpoint) : null,
            tokens: tokens,
            size: size,
            align: widget.legend.align,
          );

    final bool below =
        widget.legend.side == PlassSide.bottom || widget.legend.side == PlassSide.top;

    return Semantics(
      container: true,
      label: widget.semanticLabel ?? labels.chart,
      // Every cell, because a heatmap has no line to describe the shape of.
      value: _summary(values, rowNames, columnNames),
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

  /// Where each cell goes.
  ///
  /// A grid divides the box evenly and a treemap packs it, and past that the
  /// two are one drawing — the same fill, the same ink, the same label rule —
  /// which is what makes them one widget.
  List<_Cell> _layout({
    required List<List<ChartValue>> values,
    required bool grid,
    required double inset,
    required double width,
    required double height,
    required int columns,
  }) {
    if (width <= 0 || height <= 0) {
      return const <_Cell>[];
    }

    if (!grid) {
      final flat = <_Cell>[];

      for (int row = 0; row < values.length; row += 1) {
        for (int i = 0; i < values[row].length; i += 1) {
          if (values[row][i].value != null) {
            flat.add(_Cell(row: row, index: i, value: values[row][i], rect: Rect.zero));
          }
        }
      }

      // A tile's *area* is its share, so a negative has no area to be. It stays
      // in the reading and off the picture, which is the honest half of each.
      final List<TreemapTile> tiles = squarify(
        <double>[for (final _Cell one in flat) math.max(0, one.value.value ?? 0)],
        width,
        height,
      );

      return <_Cell>[
        for (final TreemapTile tile in tiles)
          _Cell(
            row: flat[tile.index].row,
            index: flat[tile.index].index,
            value: flat[tile.index].value,
            rect: tile.rect.shift(Offset(inset, 0)),
          ),
      ];
    }

    final double rowHeight = height / math.max(1, values.length);
    final double cellWidth = width / math.max(1, columns);
    final list = <_Cell>[];

    for (int row = 0; row < values.length; row += 1) {
      for (int i = 0; i < values[row].length; i += 1) {
        if (values[row][i].value == null) {
          continue;
        }

        list.add(
          _Cell(
            row: row,
            index: i,
            value: values[row][i],
            rect: Rect.fromLTWH(inset + i * cellWidth, row * rowHeight, cellWidth, rowHeight),
          ),
        );
      }
    }

    return list;
  }

  /// Every cell, row by row.
  String _summary(
    List<List<ChartValue>> values,
    List<String> rowNames,
    List<PlassChartCategory> columnNames,
  ) {
    final rows = <String>[];

    for (int row = 0; row < values.length; row += 1) {
      final cells = <String>[];

      for (int i = 0; i < values[row].length; i += 1) {
        final double? value = values[row][i].value;

        if (value == null) {
          continue;
        }

        final String name = i < columnNames.length ? columnNames[i].toString() : '$i';

        cells.add('$name ${_write(value)}');
      }

      if (cells.isNotEmpty) {
        rows.add('${rowNames[row]}: ${cells.join(', ')}');
      }
    }

    return rows.join('. ');
  }
}

/// How far the further arm of a diverging scale reaches from its middle.
double _reach(double low, double high, double midpoint) =>
    math.max((high - midpoint).abs(), (midpoint - low).abs());

/// One cell or tile, placed.
class _Cell {
  const _Cell({required this.row, required this.index, required this.value, required this.rect});

  final int row;
  final int index;
  final ChartValue value;
  final Rect rect;
}

class _HeatmapPainter extends CustomPainter {
  const _HeatmapPainter({
    required this.cells,
    required this.grid,
    required this.rowTexts,
    required this.columnNames,
    required this.inset,
    required this.plotWidth,
    required this.plotHeight,
    required this.columns,
    required this.rows,
    required this.ramp,
    required this.ink,
    required this.surface,
    required this.mutedFg,
    required this.fontSize,
    required this.from,
    required this.to,
    required this.scale,
    required this.midpoint,
    required this.labelled,
    required this.active,
    required this.write,
  });

  final List<_Cell> cells;
  final bool grid;
  final List<String> rowTexts;
  final List<PlassChartCategory> columnNames;

  /// How far in from the chart's own edge the cells start, in canvas
  /// coordinates. Named for the offset rather than for a side, because the
  /// drawing runs the same way in every locale.
  final double inset;
  final double plotWidth;
  final double plotHeight;
  final int columns;
  final int rows;
  final List<Color> ramp;
  final List<Color> ink;
  final Color surface;
  final Color mutedFg;
  final double fontSize;
  final double from;
  final double to;
  final PlChartScaleKind scale;
  final double midpoint;
  final bool labelled;
  final _Cell? active;
  final String Function(double) write;

  void _text(Canvas canvas, String value, Offset at, Color colour, {double weight = 400}) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          fontSize: fontSize,
          color: colour,
          fontWeight: weight == 500 ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  /// Whether a label fits its tile with room either side.
  ///
  /// Measured before it is placed and dropped when it does not, which is the
  /// same rule the pie's share labels follow: a clipped label is worse than a
  /// missing one, because a missing one sends the reader to the readout and a
  /// clipped one sends them nowhere.
  bool _fits(String text, double width, double height) =>
      height >= fontSize * 1.8 && width >= math.min(textWidth(text, fontSize), fontSize * 2.5) + 8;

  @override
  void paint(Canvas canvas, Size size) {
    for (final _Cell cell in cells) {
      // The 2px between two cells is the surface showing through and never a
      // stroke, exactly as it is between two bars.
      final double w = math.max(0, cell.rect.width - markGap);
      final double h = math.max(0, cell.rect.height - markGap);

      if (w <= 0 || h <= 0) {
        continue;
      }

      final int step = rampStep(cell.value.value ?? 0, from, to, scale, midpoint: midpoint);
      final bool on = active?.row == cell.row && active?.index == cell.index;
      final Rect box = Rect.fromLTWH(
        cell.rect.left + markGap / 2,
        cell.rect.top + markGap / 2,
        w,
        h,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          box,
          Radius.circular(math.min(_cellRadius, math.min(w / 2, h / 2))),
        ),
        Paint()..color = (cell.value.color ?? ramp[step]).withValues(alpha: on ? 1 : 0.94),
      );

      /* A tile says what it is and a cell says how much. On the grid the two
         coordinates are already written down the side and along the bottom, so
         the only thing left to write is the number; on a treemap nothing is
         written anywhere else, so the name comes first and the value only if
         there is still room under it. */
      final String value = write(cell.value.value ?? 0);
      final String name = cell.index < columnNames.length
          ? columnNames[cell.index].toString()
          : '${cell.index}';
      final List<String> lines = grid
          ? (labelled ? <String>[value] : const <String>[])
          : (labelled ? <String>[name, value] : <String>[name]);
      final written = <String>[
        for (final String line in lines)
          if (_fits(line, w, h / lines.length)) line,
      ];

      for (int i = 0; i < written.length; i += 1) {
        _text(
          canvas,
          truncateLabel(written[i], cell.rect.width - 8, fontSize),
          Offset(
            cell.rect.center.dx,
            cell.rect.center.dy + (i - (written.length - 1) / 2) * (fontSize + 2),
          ),
          cell.value.color != null ? surface : ink[step],
          weight: i == 0 ? 500 : 400,
        );
      }
    }

    if (!grid) {
      return;
    }

    // The grid's two axes. Names down the side and along the bottom, each in a
    // band of its own — written over the cells they would be unreadable, and a
    // heatmap's cells are the one thing on the page with no spare contrast to
    // lend.
    for (int i = 0; i < rowTexts.length; i += 1) {
      final painter = TextPainter(
        text: TextSpan(
          text: rowTexts[i],
          style: TextStyle(fontSize: fontSize, color: mutedFg),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      painter.paint(
        canvas,
        Offset(
          inset - 8 - painter.width,
          (i + 0.5) * plotHeight / math.max(1, rows) - painter.height / 2,
        ),
      );
    }

    final double slot = plotWidth / math.max(1, columns);

    for (int i = 0; i < columnNames.length; i += 1) {
      final String text = columnNames[i].toString();
      // Every nth, chosen so the labels clear each other — the same answer the
      // cartesian axis gives, and never a rotated one.
      final int stride = math.max(1, ((textWidth(text, fontSize) + 8) / math.max(1, slot)).ceil());

      if (i % stride != 0) {
        continue;
      }

      _text(canvas, text, Offset(inset + (i + 0.5) * slot, plotHeight + fontSize * 0.9), mutedFg);
    }
  }

  @override
  bool shouldRepaint(_HeatmapPainter old) =>
      old.cells != cells ||
      old.active != active ||
      old.ramp != ramp ||
      old.ink != ink ||
      old.labelled != labelled ||
      old.from != from ||
      old.to != to ||
      old.scale != scale ||
      old.midpoint != midpoint ||
      old.inset != inset ||
      old.plotWidth != plotWidth ||
      old.plotHeight != plotHeight;
}
