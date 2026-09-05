/// Parts of a whole, at a glance.
library;

import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/chart.dart';
import 'package:plass_ui/src/internal/chart_frame.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// What the disc is cut into.
enum PlPieShape {
  /// A filled disc.
  pie,

  /// A ring, with room in the middle for the total.
  donut,

  /// Half a ring, opened along the bottom. For a gauge, or for a dashboard
  /// tile that is wider than it is tall.
  semi,
}

/// What is written on the slices.
///
/// Two members and not the four of [PlassChartValueLabels], because the other
/// two have nothing to mean here: a pie has no last category and no run of
/// values to take a high and a low from. Its slices are one number each.
enum PlPieLabels {
  /// Nothing.
  none,

  /// Each slice's share, where the slice is wide enough to hold it.
  all,
}

/// How much of the middle is cut out, per shape.
const Map<PlPieShape, double> _holes = <PlPieShape, double>{
  PlPieShape.pie: 0,
  PlPieShape.donut: 0.62,
  PlPieShape.semi: 0.62,
};

/// Parts of a whole, at a glance.
///
/// The narrowest chart in the library and the easiest one to misuse. An angle
/// is a poor thing to compare — two slices within a few percent of each other
/// are indistinguishable, and a reader cannot rank six of them — so the pie is
/// right for exactly one question: *is one of these most of it?* Anything finer
/// than that, and anything past six slices, is a `PlBarChart`.
///
/// A slice's colour follows the slice and not its size, so a chart that is
/// refiltered or resorted keeps every category the colour it had.
///
/// ```dart
/// PlPieChart(
///   data: const <PlassChartDatum>[
///     PlassChartDatum(40),
///     PlassChartDatum(25),
///     PlassChartDatum(20),
///   ],
///   categories: const <PlassChartCategory>[
///     PlassChartCategory.text('Search'),
///     PlassChartCategory.text('Social'),
///     PlassChartCategory.text('Direct'),
///   ],
///   shape: PlPieShape.donut,
/// )
/// ```
class PlPieChart extends StatefulWidget {
  /// Creates a pie chart.
  const PlPieChart({
    required this.data,
    this.categories,
    this.shape = PlPieShape.pie,
    this.startAngle = 0,
    this.center,
    this.valueLabels = PlPieLabels.none,
    this.legend = const PlChartLegend(),
    this.tooltip = const PlChartTooltip(),
    this.height,
    this.format,
    this.semanticLabel,
    this.empty,
    this.size,
    super.key,
  });

  /// The slices.
  ///
  /// One list and not a list of series, because that is what a pie *is*: the
  /// slices are the entities here, so each one takes a palette slot of its own
  /// and the legend lists them rather than listing series.
  final List<PlassChartDatum> data;

  /// What each slice is called. Points may carry their own `x` instead.
  final List<PlassChartCategory>? categories;

  /// Whether the middle is filled, open, or only half drawn.
  final PlPieShape shape;

  /// Where the first slice starts, in degrees clockwise from twelve o'clock.
  /// Ignored by [PlPieShape.semi], which is defined by where it opens.
  final double startAngle;

  /// What goes in the hole.
  ///
  /// A donut with nothing in the middle is a pie with a bite out of it; the
  /// total, or the one figure the chart is about, is what the ring was drawn
  /// around.
  final Widget? center;

  /// Whether each slice carries its share.
  ///
  /// The number written is the **share**, not the value: a share is what a pie
  /// is a picture of, and the value is one press away. A label that does not
  /// fit is dropped rather than clipped.
  final PlPieLabels valueLabels;

  /// The legend.
  final PlChartLegend legend;

  /// The readout under the pointer.
  final PlChartTooltip tooltip;

  /// How tall the drawing is. Falls back to the size ladder.
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
  State<PlPieChart> createState() => _PlPieChartState();
}

class _PlPieChartState extends State<PlPieChart> {
  /// Which slices the reader has switched off in the legend.
  final Set<int> _off = <int>{};

  int? _active;
  int? _hovered;

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

    final List<ChartValue> values = toValues(<PlassChartSeries>[
      PlassChartSeries(data: widget.data),
    ]).first;

    /* A pie's slices are what the legend, the visibility and the palette are
       all keyed on, so they are turned into one-value series here. That is not
       a workaround: everywhere else in the library the thing that gets a colour
       and a legend row is a series, and a slice is playing exactly that part. */
    final List<PlassChartSeries> slices = <PlassChartSeries>[
      for (int i = 0; i < values.length; i += 1)
        PlassChartSeries(
          name: categoryAt(i, widget.categories, <List<ChartValue>>[values]).toString(),
          color: values[i].color,
          data: <PlassChartDatum>[widget.data[i]],
        ),
    ];

    final List<bool> visible = <bool>[for (int i = 0; i < slices.length; i += 1) !_off.contains(i)];
    final List<Color> colors = <Color>[
      for (int i = 0; i < slices.length; i += 1) seriesColor(values[i].color, i, tokens.chart),
    ];

    double total = 0;

    for (int i = 0; i < values.length; i += 1) {
      if (visible[i] && values[i].value != null) {
        total += values[i].value!.abs();
      }
    }

    final Widget plot = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth.isFinite ? constraints.maxWidth : height;
        final bool semi = widget.shape == PlPieShape.semi;

        // A semicircle gets the *whole* height as its radius rather than half
        // of it — it only draws the top half, so reserving room for the bottom
        // one would leave a blank band under the chart. Its centre then sits
        // below the middle of the box by half a radius, which puts the arc
        // itself in the middle: pinned to the bottom edge instead, a wide card
        // would draw a thin band with an empty half above it.
        final double centreX = width / 2;
        final double outer = math.max(0, math.min(width / 2, semi ? height : height / 2) - 2);
        final double centreY = semi ? math.min(height, height / 2 + outer / 2) : height / 2;
        final double inner = outer * _holes[widget.shape]!;

        if (total <= 0 || outer <= 0) {
          return SizedBox(
            width: width,
            height: height,
            child: Center(
              child:
                  widget.empty ??
                  Text(
                    labels.empty,
                    style: TextStyle(fontSize: metaText[size]!, color: tokens.mutedFg),
                  ),
            ),
          );
        }

        final List<_Arc> arcs = _arcs(values, visible, total, semi, outer);

        void press(Offset local) {
          final int? found = _hit(local, arcs, centreX, centreY, outer, inner);

          if (widget.tooltip.hidden) {
            return;
          }

          setState(() => _active = found == _active ? null : found);
        }

        void move(Offset local) {
          if (widget.tooltip.hidden) {
            return;
          }

          final int? found = _hit(local, arcs, centreX, centreY, outer, inner);

          if (found != _active) {
            setState(() => _active = found);
          }
        }

        return MouseRegion(
          onHover: (PointerHoverEvent event) => move(event.localPosition),
          onExit: (PointerExitEvent _) {
            if (_active != null) {
              setState(() => _active = null);
            }
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // A press leaves the readout up and a second press on the same
            // slice takes it down, for the reason the cartesian frame gives:
            // clearing it on the release is a readout a reader with no pointer
            // never gets to read.
            onTapDown: (TapDownDetails details) => press(details.localPosition),
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                children: <Widget>[
                  CustomPaint(
                    size: Size(width, height),
                    painter: _PiePainter(
                      arcs: arcs,
                      colors: colors,
                      own: values,
                      centreX: centreX,
                      centreY: centreY,
                      outer: outer,
                      inner: inner,
                      active: _active,
                      hovered: _hovered,
                      shares: widget.valueLabels == PlPieLabels.all,
                      fontSize: fontSize,
                      surface: tokens.surface,
                    ),
                  ),
                  if (widget.center != null && inner > 0)
                    // Directional rather than physical, though the box is the
                    // same either way: its centre is the plot's own centre, so
                    // measuring from the start edge and from the left edge land
                    // in exactly the same place.
                    PositionedDirectional(
                      start: centreX - inner,
                      top: centreY - inner,
                      width: inner * 2,
                      height: semi ? inner : inner * 2,
                      child: IgnorePointer(child: Center(child: widget.center)),
                    ),
                  if (_active != null && !widget.tooltip.hidden)
                    PositionedDirectional(
                      start: 0,
                      end: 0,
                      top: 8,
                      child: Align(
                        child: PlassChartTooltipCard(
                          tokens: tokens,
                          size: size,
                          heading: slices[_active!].name ?? '',
                          children: <Widget>[
                            _Readout(
                              color: values[_active!].color ?? colors[_active!],
                              text: _share(values[_active!].value ?? 0, total),
                              tokens: tokens,
                              size: size,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );

    final Widget legend = widget.legend.hidden || slices.length < 2
        ? const SizedBox.shrink()
        : PlassChartLegendBar(
            series: slices,
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

              if (_active == index) {
                _active = null;
              }
            }),
            onHover: (int? index) => setState(() => _hovered = index),
          );

    final bool below =
        widget.legend.side == PlassSide.bottom || widget.legend.side == PlassSide.top;

    return Semantics(
      container: true,
      label: widget.semanticLabel ?? labels.chart,
      // The picture is a picture. What a screen reader is handed instead is
      // every slice and its share, which is the reading a sighted reader takes
      // from the angles.
      value: _summary(slices, values, visible, total),
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

  /// Where each slice starts and stops, in degrees clockwise from twelve.
  List<_Arc> _arcs(
    List<ChartValue> values,
    List<bool> visible,
    double total,
    bool semi,
    double outer,
  ) {
    final double sweep = semi ? 180 : 360;
    double angle = semi ? -90 : widget.startAngle;

    return <_Arc>[
      for (int i = 0; i < values.length; i += 1)
        if (visible[i] && values[i].value != null && values[i].value != 0)
          () {
            final double share = values[i].value!.abs() / total;
            final _Arc arc = _Arc(i, angle, angle + share * sweep, share);

            angle += share * sweep;

            return arc;
          }(),
    ];
  }

  /// Which slice the pointer is over, or `null` when it is off the ring.
  int? _hit(
    Offset at,
    List<_Arc> arcs,
    double centreX,
    double centreY,
    double outer,
    double inner,
  ) {
    final double dx = at.dx - centreX;
    final double dy = at.dy - centreY;
    final double radius = math.sqrt(dx * dx + dy * dy);

    if (radius > outer || radius < inner) {
      return null;
    }

    // Back to the frame the arcs were built in: degrees clockwise from twelve,
    // and never negative, so a slice that straddles the top still matches.
    double degrees = math.atan2(dy, dx) * 180 / math.pi + 90;

    while (degrees < 0) {
      degrees += 360;
    }

    for (final _Arc arc in arcs) {
      double from = arc.start % 360;
      final double span = arc.end - arc.start;

      if (from < 0) {
        from += 360;
      }

      final double offset = (degrees - from + 360) % 360;

      if (offset < span) {
        return arc.index;
      }
    }

    return null;
  }

  /// The value, and what part of the whole it is.
  ///
  /// Rounded to a tenth and written without a trailing `.0`, which is the one
  /// place Dart and JavaScript disagree about a number: `40.0` and `40` are the
  /// same share, and the two builds must not read it out two ways.
  String _share(double value, double total) {
    final double percent = total == 0 ? 0 : value.abs() / total * 100;
    final double rounded = (percent * 10).round() / 10;
    final String written = rounded == rounded.roundToDouble()
        ? rounded.toInt().toString()
        : rounded.toString();

    return '${_write(value)} · $written%';
  }

  /// Every visible slice and what it is worth.
  String _summary(
    List<PlassChartSeries> slices,
    List<ChartValue> values,
    List<bool> visible,
    double total,
  ) {
    final parts = <String>[];

    for (int i = 0; i < slices.length; i += 1) {
      if (!visible[i] || values[i].value == null) {
        continue;
      }

      parts.add('${slices[i].name} ${_share(values[i].value!, total)}');
    }

    return parts.join(', ');
  }
}

/// One slice, in the frame `arcPath` reads.
class _Arc {
  const _Arc(this.index, this.start, this.end, this.share);

  /// Its place in the data as it was passed — where its colour is from.
  final int index;

  /// Degrees clockwise from twelve o'clock.
  final double start;

  /// And where it stops.
  final double end;

  /// Its part of the total, from zero to one.
  final double share;
}

class _PiePainter extends CustomPainter {
  const _PiePainter({
    required this.arcs,
    required this.colors,
    required this.own,
    required this.centreX,
    required this.centreY,
    required this.outer,
    required this.inner,
    required this.active,
    required this.hovered,
    required this.shares,
    required this.fontSize,
    required this.surface,
  });

  final List<_Arc> arcs;
  final List<Color> colors;
  final List<ChartValue> own;
  final double centreX;
  final double centreY;
  final double outer;
  final double inner;
  final int? active;
  final int? hovered;
  final bool shares;
  final double fontSize;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    // The 2px between two slices, as the angle that subtends it at the rim.
    // Wider for a small pie than for a large one, which is the point: the gap
    // is a constant on screen, not a constant in the data.
    final double pad = outer > 0 ? math.min(4, markGap / outer * 180 / math.pi) : 0;

    for (final _Arc arc in arcs) {
      final bool dimmed =
          (hovered != null && hovered != arc.index) || (active != null && active != arc.index);

      // The pad is taken off both ends and never off a slice narrower than two
      // of it, or a one-degree sliver inverts and draws the whole circle
      // instead of nothing.
      final double room = arc.end - arc.start > pad * 2 ? pad / 2 : 0;
      final Color color = own[arc.index].color ?? colors[arc.index];

      canvas.drawPath(
        arcPath(centreX, centreY, outer, inner, arc.start + room, arc.end - room),
        Paint()..color = color.withValues(alpha: dimmed ? 0.32 : 1),
      );
    }

    if (!shares) {
      return;
    }

    for (final _Arc arc in arcs) {
      final double middle = ((arc.start + arc.end) / 2 - 90) * math.pi / 180;
      final double radius = inner > 0 ? (inner + outer) / 2 : outer * 0.68;

      // Measured before it is placed: a label wider than the slice is dropped,
      // never clipped and never spilled over the neighbour it would then be
      // labelling.
      final double room = (arc.end - arc.start) * math.pi / 180 * radius;

      if (room < fontSize * 2 || outer - inner < fontSize * 1.6) {
        continue;
      }

      final painter = TextPainter(
        text: TextSpan(
          text: '${(arc.share * 100).round()}%',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            // Inside a filled mark is the one place a label wears something
            // other than an ink token, and it is the sheet's own colour rather
            // than white: a pale slice would swallow white.
            color: surface,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      painter.paint(
        canvas,
        Offset(
          centreX + radius * math.cos(middle) - painter.width / 2,
          centreY + radius * math.sin(middle) - painter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(_PiePainter old) =>
      old.arcs != arcs ||
      old.colors != colors ||
      old.active != active ||
      old.hovered != hovered ||
      old.shares != shares ||
      old.outer != outer ||
      old.inner != inner ||
      old.surface != surface;
}

/// The one row a pie's readout has.
class _Readout extends StatelessWidget {
  const _Readout({
    required this.color,
    required this.text,
    required this.tokens,
    required this.size,
  });

  final Color color;
  final String text;
  final PlassTokens tokens;
  final PlassSize size;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            text,
            style: TextStyle(
              fontSize: metaText[size]!,
              fontWeight: FontWeight.w600,
              color: tokens.fg,
            ),
          ),
        ],
      ),
    );
  }
}
