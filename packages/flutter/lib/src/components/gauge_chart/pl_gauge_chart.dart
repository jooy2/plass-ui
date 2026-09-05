/// One number on a scale that is known in advance, drawn as a dial.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/chart.dart';
import 'package:plass_ui/src/internal/progress.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/threshold.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// One number on a scale that is known in advance, drawn as a dial.
///
/// It is a [PlMeter] bent into an arc, and the two are deliberately the same
/// idea in two shapes: [value], [min], [max] and [thresholds] mean exactly what
/// they mean there, so a page can move a reading from a bar to a dial without
/// changing what it says. Reach for the bar in a row of fields and for this one
/// in a tile of its own, where a dial reads at a glance from across a room and
/// a four-pixel bar does not.
///
/// It is not a `PlPieChart` with [PlPieShape.semi]. A pie is *parts of a whole*
/// and every slice is a category; this is one value against a scale, and the
/// unfilled part of the arc is not a second category — it is the rest of the
/// dial.
///
/// ```dart
/// PlGaugeChart(value: 68, caption: const Text('of quota'))
/// ```
class PlGaugeChart extends StatelessWidget {
  /// Creates a gauge.
  const PlGaugeChart({
    required this.value,
    this.min = 0,
    this.max = 100,
    this.sweep = 180,
    this.thickness = 0.22,
    this.thresholds,
    this.ticks,
    this.showRange = true,
    this.center,
    this.caption,
    this.height,
    this.format,
    this.semanticLabel,
    this.empty,
    this.size,
    this.color,
    super.key,
  });

  /// The reading. `null` draws the dial with nothing on it, which is the honest
  /// picture of an instrument that has not been told anything.
  final double? value;

  /// The bottom of the scale.
  final double min;

  /// And the top of it.
  final double max;

  /// How far round the dial goes, in degrees, opened symmetrically about twelve
  /// o'clock. `180` is the half-dial a dashboard tile wants; `270` is the
  /// instrument shape; `360` is a ring.
  final double sweep;

  /// How thick the arc is, as a fraction of its radius.
  final double thickness;

  /// Where the arc changes colour — the same bands a [PlMeter] takes, read the
  /// same way: the highest band at or below the value wins.
  final List<PlassThreshold>? thresholds;

  /// How many marks are drawn around the dial, ends included.
  ///
  /// `null` — the default — draws none: a gauge on a dashboard is read as a
  /// proportion, and ticks are for an instrument somebody takes a *number* off.
  /// `null` rather than React's `false`, because Dart has no union to put a
  /// count and a switch into one prop.
  final int? ticks;

  /// Writes [min] and [max] at the two ends of the arc.
  final bool showRange;

  /// What goes in the middle. Left out, it is the value written through
  /// [format], which is what the dial is for.
  final Widget? center;

  /// A line under the value: the unit, or what is being measured.
  final Widget? caption;

  /// How tall the drawing is. Falls back to the size ladder.
  final double? height;

  /// How a value is written.
  final String Function(double value)? format;

  /// What the dial is called.
  ///
  /// Named, it is one image saying one thing, which saves a reader hearing the
  /// two end labels as loose numbers. Unnamed there is nothing to call it, so
  /// the reading in the middle is read as the text it already is.
  final String? semanticLabel;

  /// What is drawn when there is nothing to draw.
  final Widget? empty;

  /// Type scale and dial height.
  final PlassSize? size;

  /// The family the arc takes where no threshold applies.
  final PlassColor? color;

  String _write(double each) {
    if (format != null) {
      return format!(each);
    }

    if (each == each.roundToDouble() && each.abs() < 1e15) {
      return each.toInt().toString();
    }

    return each.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final labels = PlassTheme.labelsOf(context);
    final PlassSize step = size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final PlassColor family = color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
    final bool still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final double plotHeight = height ?? plotHeights[step]!;
    final double fontSize = chartFontSizes[step]!;

    final double span = math.max(1, math.min(360, sweep));
    final double range = max - min;
    final double? fraction = value == null || value!.isNaN || range == 0
        ? null
        : ((value! - min) / range).clamp(0.0, 1.0);

    final PlassColor band = value == null ? family : bandColor(value!, family, thresholds);

    final Widget reading = center ?? Text(value == null ? '—' : _write(value!));

    final Widget dial = SizedBox(
      height: plotHeight,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : plotHeight * 2;

          final _Dial box = _Dial.measure(
            width: width,
            height: plotHeight,
            span: span,
            thickness: thickness,
            fontSize: fontSize,
            hasTicks: ticks != null,
            rangeText: showRange && span < 330
                ? <String>[
                    truncateLabel(_write(min), math.max(0, width * 0.28), fontSize),
                    truncateLabel(_write(max), math.max(0, width * 0.28), fontSize),
                  ]
                : const <String>[],
          );

          if (box.outer <= 0 || range == 0) {
            return Center(
              child:
                  empty ??
                  Text(
                    labels.empty,
                    style: TextStyle(fontSize: metaText[step]!, color: tokens.mutedFg),
                  ),
            );
          }

          return Stack(
            children: <Widget>[
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: fraction ?? 0),
                  duration: still || fraction == null ? Duration.zero : fillDuration,
                  curve: PlassTokens.ease,
                  builder: (BuildContext context, double drawn, Widget? _) => CustomPaint(
                    painter: _GaugePainter(
                      dial: box,
                      fraction: fraction == null ? null : drawn,
                      groove: tokens.family(family).soft,
                      fill: tokens.family(band).fill,
                      grid: tokens.chartGrid,
                      ink: tokens.mutedFg,
                      fontSize: fontSize,
                      ticks: ticks,
                    ),
                  ),
                ),
              ),
              // Real text rather than something painted: this is the one number
              // the chart is about, so it has to be selectable, findable and in
              // the semantics tree.
              // Directional rather than physical, though the block is the same
              // either way round: it is centred on the dial's own centre, so
              // measuring from the start edge and from the left edge land in
              // exactly the same place.
              PositionedDirectional(
                top: box.textTop - box.blockHeight / 2,
                start: box.centreX - box.room / 2,
                width: box.room,
                height: box.blockHeight,
                child: IgnorePointer(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      DefaultTextStyle.merge(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: box.readingSize(reading is Text ? (reading.data ?? '') : ''),
                          fontWeight: FontWeight.w600,
                          color: tokens.fg,
                        ),
                        child: reading,
                      ),
                      if (caption != null)
                        DefaultTextStyle.merge(
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: metaText[step]!, color: tokens.mutedFg),
                          child: caption!,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    if (semanticLabel == null) {
      return dial;
    }

    return Semantics(
      container: true,
      image: true,
      label: value == null ? semanticLabel : '$semanticLabel: ${_write(value!)} / ${_write(max)}',
      excludeSemantics: true,
      child: dial,
    );
  }
}

/// Where the dial goes in the box it was given.
///
/// Measured once and read by both halves — the painter and the block of text in
/// the hole — because they have to agree about a chord neither of them owns.
class _Dial {
  const _Dial({
    required this.centreX,
    required this.centreY,
    required this.outer,
    required this.inner,
    required this.span,
    required this.fontSize,
    required this.labelReach,
    required this.labelDrop,
    required this.labelUnder,
    required this.rangeText,
    required this.textTop,
    required this.room,
    required this.readingRise,
    required this.blockHeight,
  });

  /// How much room the arc needs, as multiples of its own radius.
  ///
  /// The top of the dial is always a full radius above the centre; how far it
  /// reaches *below* depends on the sweep — a half-dial stops level with its
  /// centre, a 270° one drops most of a radius past it. Sizing against the box
  /// rather than assuming a circle is what keeps a wide, short card from
  /// drawing a thin band with an empty half above it.
  factory _Dial.measure({
    required double width,
    required double height,
    required double span,
    required double thickness,
    required double fontSize,
    required bool hasTicks,
    required List<String> rangeText,
  }) {
    final double half = span / 2;
    final double halfRadians = half * math.pi / 180;
    final double belowFactor = span >= 360 ? 1 : math.max(0, -math.cos(halfRadians));
    final double sideFactor = span >= 180 ? 1 : math.sin(halfRadians);
    final double endOutX = math.sin(halfRadians);
    final double endOutY = -math.cos(halfRadians);

    double widest = 0;

    for (final String text in rangeText) {
      widest = math.max(widest, textWidth(text, fontSize));
    }

    // A range label goes with the end it names, in one of two arrangements
    // rather than a blend of them. An end that points sideways has the whole
    // empty width of the tile under it, so the label is centred *under* it; an
    // end already pointing downward carries the label on in that direction.
    final double edge = fontSize * 0.35;
    final double tickReach = hasTicks ? fontSize * 0.85 : 0;
    final bool labelUnder = endOutY <= 0.25;
    final double labelReach = labelUnder ? 0 : fontSize * 0.5;
    final double labelDrop = labelUnder ? fontSize : fontSize * (0.35 + endOutY * 0.55);
    final double labelBelow = rangeText.isEmpty
        ? 0
        : endOutY * labelReach + labelDrop + fontSize * 0.25;

    final double sidePad = math.max(edge, tickReach);
    final double topPad = math.max(edge, tickReach);
    final double bottomPad = math.max(math.max(edge, tickReach), labelBelow);

    final limits = <double>[
      (width / 2 - sidePad) / math.max(0.05, sideFactor),
      (height - topPad - bottomPad) / (1 + belowFactor),
    ];

    if (widest > 0 && endOutX > 0.05) {
      final double outboard = labelUnder ? widest / 2 : widest;

      limits.add(math.max(0, width / 2 - edge - outboard) / endOutX - labelReach);
    }

    final double outer = math.max(0, limits.reduce(math.min));
    final double inner = outer * (1 - math.min(0.9, math.max(0.05, thickness)));

    // Centred in what the box actually has rather than pinned under the top
    // margin. A half-dial on a tile as tall as a line chart is a third of its
    // own box, and the two thirds under it are not the dial's to hold.
    final double drawn = topPad + outer * (1 + belowFactor) + bottomPad;
    final double centreY = topPad + outer + math.max(0, (height - drawn) / 2);

    // The reading sits in the middle of the hole the arc leaves, which is not
    // the middle of the circle: a half-dial's hole stops at the horizontal, so
    // its middle is half an inner radius up.
    final double textTop = centreY - inner * (1 - math.min(1, belowFactor)) / 2;
    final double readingRise = math.min(inner, (centreY - textTop).abs());
    final double blockHeight = math.max(fontSize * 2.6, inner);
    final double blockRise = math.min(inner, (centreY - textTop).abs());
    final double room = math.sqrt(math.max(0, inner * inner - blockRise * blockRise)) * 2;

    return _Dial(
      centreX: width / 2,
      centreY: centreY,
      outer: outer,
      inner: inner,
      span: span,
      fontSize: fontSize,
      labelReach: labelReach,
      labelDrop: labelDrop,
      labelUnder: labelUnder,
      rangeText: rangeText,
      textTop: textTop,
      room: room,
      readingRise: readingRise,
      blockHeight: blockHeight,
    );
  }

  final double centreX;
  final double centreY;
  final double outer;
  final double inner;
  final double span;
  final double fontSize;
  final double labelReach;
  final double labelDrop;
  final bool labelUnder;
  final List<String> rangeText;
  final double textTop;
  final double room;
  final double readingRise;
  final double blockHeight;

  /// Where the arc starts, in degrees clockwise from twelve.
  double get from => -span / 2;

  /// And where it stops.
  double get to => span / 2;

  /// The largest type size at which [text] still sits inside the hole.
  ///
  /// Two things have to fit — half the line's width sideways, and how far its
  /// digits climb above its middle — and both grow with the size being solved
  /// for, so this is a quadratic rather than a division. Solved rather than
  /// iterated, because iterating oscillates: a size that does not fit shrinks,
  /// a shorter number climbs less, and the room that frees up allows a size
  /// that does not fit.
  double readingSize(String text) {
    final double units = textWidth(text, 1);

    if (units <= 0) {
      return fontSize * 2;
    }

    // 0.42 of the size above the middle is where a digit's top lands, and 0.86
    // of the chord is what it may fill. Both keep a little back, because
    // `textWidth` is a *reservation* estimate and runs under on punctuation.
    const double cap = 0.42;
    const double fill = 0.86;

    final double a = units * units / (4 * fill * fill) + cap * cap;
    final double b = 2 * readingRise * cap;
    final double c = readingRise * readingRise - inner * inner;

    if (a <= 0 || c >= 0) {
      return fontSize;
    }

    final double solved = (math.sqrt(b * b - 4 * a * c) - b) / (2 * a);

    return math.max(fontSize, math.min(fontSize * 2, solved));
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({
    required this.dial,
    required this.fraction,
    required this.groove,
    required this.fill,
    required this.grid,
    required this.ink,
    required this.fontSize,
    required this.ticks,
  });

  final _Dial dial;
  final double? fraction;
  final Color groove;
  final Gradient fill;
  final Color grid;
  final Color ink;
  final double fontSize;
  final int? ticks;

  /// Degrees clockwise from twelve to a point on a circle of radius [r].
  Offset _pointAt(double r, double degrees) {
    final double radians = (degrees - 90) * math.pi / 180;

    return Offset(dial.centreX + r * math.cos(radians), dial.centreY + r * math.sin(radians));
  }

  @override
  void paint(Canvas canvas, Size size) {
    // The rest of the dial. Not a second value — a groove.
    canvas.drawPath(
      arcPath(dial.centreX, dial.centreY, dial.outer, dial.inner, dial.from, dial.to),
      Paint()..color = groove,
    );

    final double? drawn = fraction;

    if (drawn != null && drawn > 0) {
      // The reading, stroked along the groove's centre line rather than filled
      // as a second wedge, so that what changes with the value is a length.
      final Rect area = Rect.fromCircle(
        center: Offset(dial.centreX, dial.centreY),
        radius: dial.outer,
      );

      canvas.drawPath(
        ringPath(
          dial.centreX,
          dial.centreY,
          (dial.outer + dial.inner) / 2,
          dial.from,
          dial.from + dial.span * drawn,
        ),
        Paint()
          ..shader = fill.createShader(area)
          ..style = PaintingStyle.stroke
          ..strokeWidth = dial.outer - dial.inner,
      );
    }

    final int count = ticks == null ? 0 : math.max(2, ticks!);

    for (int i = 0; i < count; i += 1) {
      final double at = dial.from + dial.span * i / (count - 1);

      canvas.drawLine(
        _pointAt(dial.outer + fontSize * 0.25, at),
        _pointAt(dial.outer + fontSize * 0.6, at),
        Paint()
          ..color = grid
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round,
      );
    }

    if (dial.rangeText.length != 2) {
      return;
    }

    for (int i = 0; i < 2; i += 1) {
      final Offset at = _pointAt(dial.outer + dial.labelReach, i == 0 ? dial.from : dial.to);
      final painter = TextPainter(
        text: TextSpan(
          text: dial.rangeText[i],
          style: TextStyle(fontSize: fontSize, color: ink),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final double dx = dial.labelUnder
          ? at.dx - painter.width / 2
          : (i == 0 ? at.dx - painter.width : at.dx);

      painter.paint(canvas, Offset(dx, at.dy + dial.labelDrop - painter.height));
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.fraction != fraction ||
      old.groove != groove ||
      old.fill != fill ||
      old.grid != grid ||
      old.ink != ink ||
      old.fontSize != fontSize ||
      old.ticks != ticks ||
      old.dial.outer != dial.outer ||
      old.dial.inner != dial.inner ||
      old.dial.span != dial.span;
}
