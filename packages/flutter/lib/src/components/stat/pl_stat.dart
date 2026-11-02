/// One figure, and what has happened to it.
library;

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/skeleton/pl_skeleton.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

/// Which way a change has to go to be good news.
enum PlStatDirection {
  /// Up. Revenue, sign-ups, uptime.
  up,

  /// Down. Churn, a bounce rate, a p95 latency, a cost.
  down,
}

/// The figure's own ladder. It is the biggest thing in the box and is meant to
/// be.
const Map<PlassSize, double> _valueSize = <PlassSize, double>{
  PlassSize.xs: 20,
  PlassSize.sm: 24,
  PlassSize.md: 30,
  PlassSize.lg: 36,
  PlassSize.xl: 44,
};

/// One figure, and what has happened to it.
///
/// A row of these is the top of every dashboard, and the whole of what makes
/// them worth a widget rather than three `Text`s is the **change**: a number on
/// its own says what things are, and a number with a movement beside it says
/// whether that is going anywhere.
///
/// The colour of that movement is decided by [improvesWhen] and not by the sign,
/// which is the one thing a naive version of this gets wrong. Churn going up is
/// not good news, and a green arrow on it is a dashboard lying to somebody.
///
/// It draws **no surface**. A figure sits in a [PlCard] or in a row of them, and
/// a sheet inside a sheet is two sheets.
///
/// ```dart
/// PlStat(
///   label: const Text('Revenue'),
///   value: const Text('£48,120'),
///   change: 12.4,
///   description: const Text('vs last month'),
/// )
/// ```
class PlStat extends StatelessWidget {
  /// Creates a figure.
  const PlStat({
    this.label,
    this.value,
    this.description,
    this.icon,
    this.change,
    this.changeLabel,
    this.improvesWhen = PlStatDirection.up,
    this.loading = false,
    this.size,
    this.color,
    this.density,
    super.key,
  });

  /// What the figure is of. The line above it.
  final Widget? label;

  /// The figure itself, already formatted.
  ///
  /// A widget rather than a number, and deliberately: how a figure is written —
  /// the currency, the grouping, the decimals, the locale — is the screen's
  /// decision, and `package:intl`'s `NumberFormat` already makes it. A widget
  /// that took a number would have to guess at all four, and this package has no
  /// dependencies to guess with.
  final Widget? value;

  /// A line under the figure. What it is compared with, usually.
  final Widget? description;

  /// A glyph beside the label.
  final Widget? icon;

  /// How much it moved, as a percentage.
  ///
  /// Written by [formatChange]. A change that rounds to 0 at its one decimal is
  /// `0%`, with no arrow and in the muted colour.
  final double? change;

  /// What the change says instead of the formatted percentage. For a figure that
  /// moved by a count rather than by a proportion.
  final Widget? changeLabel;

  /// Which way is good news.
  final PlStatDirection improvesWhen;

  /// Draws a skeleton where the figure will be.
  final bool loading;

  /// The type scale of the figure and the words around it.
  final PlassSize? size;

  /// The family the icon takes.
  final PlassColor? color;

  /// The space between the three lines, and nothing else.
  final PlassDensity? density;

  /// How the percentage is written when [changeLabel] does not say.
  ///
  /// One decimal at most, and a sign on a rise — `+12.4%`, `-3%`. Written here
  /// rather than through `NumberFormat` because the package has no dependencies;
  /// anything more particular is what `changeLabel` is for.
  static String formatChange(double change) {
    final rounded = _roundChange(change);
    final text = rounded == rounded.roundToDouble()
        ? rounded.toStringAsFixed(0)
        : rounded.toStringAsFixed(1);

    return '${rounded > 0 ? '+' : ''}$text%';
  }

  /// [change] at the one decimal [formatChange] writes it at, with a change too
  /// small to show made `0` rather than `-0`, which would be written `-0%`.
  static double _roundChange(double change) {
    final rounded = (change * 10).roundToDouble() / 10;

    return rounded == 0 ? 0 : rounded;
  }

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final color = this.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
    final density = this.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

    final tokens = PlassTheme.of(context);
    final family = tokens.family(color);
    final space = density == PlassDensity.compact ? 2.0 : stackGap[size]!;

    // Read at the decimal it is written at, so `0%` never carries an arrow.
    final rounded = change == null ? null : _roundChange(change!);
    final moved = rounded != null && rounded != 0;
    final up = (rounded ?? 0) > 0;
    // Good news rather than a positive number. The two are the same thing for
    // revenue and the opposite for churn.
    final good = moved && (improvesWhen == PlStatDirection.up ? up : !up);
    final hasChange = change != null || changeLabel != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (label != null || icon != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                ExcludeSemantics(
                  child: IconTheme.merge(
                    data: IconThemeData(color: family.accent, size: metaText[size]! * 1.15),
                    child: icon!,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              if (label != null)
                Flexible(
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!),
                    child: label!,
                  ),
                ),
            ],
          ),
        if (label != null || icon != null) SizedBox(height: space),
        _ValueLine(
          gap: 8,
          runGap: space / 2,
          textDirection: Directionality.of(context),
          children: <Widget>[
            if (loading)
              PlSkeleton(size: size, color: color, width: _valueSize[size]! * 3)
            else if (value != null)
              // Truncated only when the figure is wider than the card on a line
              // of its own: the change gives way first, by going under it.
              DefaultTextStyle.merge(
                style: TextStyle(
                  color: tokens.fg,
                  fontWeight: FontWeight.w600,
                  fontSize: _valueSize[size]!,
                  height: 1.1,
                  leadingDistribution: TextLeadingDistribution.even,
                  fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                  overflow: TextOverflow.ellipsis,
                ),
                child: value!,
              ),
            if (hasChange && !loading)
              DefaultTextStyle.merge(
                style: TextStyle(
                  color: !moved
                      ? tokens.mutedFg
                      : good
                      ? tokens.family(PlassColor.success).accent
                      : tokens.family(PlassColor.danger).accent,
                  fontWeight: FontWeight.w500,
                  fontSize: metaText[size]!,
                  fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // The arrow is `aria-hidden`'s equivalent and the sign is in
                    // the text, so colour is never the only thing carrying the
                    // direction.
                    if (moved) ExcludeSemantics(child: Text(up ? '▲' : '▼')),
                    if (moved) const SizedBox(width: 2),
                    changeLabel ?? Text(formatChange(change!)),
                  ],
                ),
              ),
          ],
        ),
        if (description != null) ...<Widget>[
          SizedBox(height: space),
          DefaultTextStyle.merge(
            style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!),
            child: description!,
          ),
        ],
      ],
    );
  }
}

/// The figure and the change after it, on one baseline while they fit.
///
/// A [Row] would give the width to the figure and truncate it, and a [Wrap]
/// cannot line two sizes of type up on a baseline. A figure of "£48,120" beside
/// a change is wider than a card in two columns on a phone, and what a reader
/// came for is the figure, so the change goes on a line of its own under it.
class _ValueLine extends MultiChildRenderObjectWidget {
  const _ValueLine({
    required this.gap,
    required this.runGap,
    required this.textDirection,
    required super.children,
  });

  /// Between the two on one line.
  final double gap;

  /// Between the two on two lines.
  final double runGap;

  /// Which end the line starts from.
  final TextDirection textDirection;

  @override
  _RenderValueLine createRenderObject(BuildContext context) {
    return _RenderValueLine(gap: gap, runGap: runGap, textDirection: textDirection);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderValueLine renderObject) {
    renderObject
      ..gap = gap
      ..runGap = runGap
      ..textDirection = textDirection;
  }
}

class _ValueLineData extends ContainerBoxParentData<RenderBox> {}

class _RenderValueLine extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ValueLineData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ValueLineData> {
  _RenderValueLine({
    required double gap,
    required double runGap,
    required TextDirection textDirection,
  }) : _gap = gap,
       _runGap = runGap,
       _textDirection = textDirection;

  double _gap;
  set gap(double value) {
    if (value != _gap) {
      _gap = value;
      markNeedsLayout();
    }
  }

  double _runGap;
  set runGap(double value) {
    if (value != _runGap) {
      _runGap = value;
      markNeedsLayout();
    }
  }

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value != _textDirection) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ValueLineData) {
      child.parentData = _ValueLineData();
    }
  }

  BoxConstraints _inner(BoxConstraints constraints) {
    return BoxConstraints(maxWidth: constraints.maxWidth);
  }

  /// Whether both fit on one line of [width].
  bool _fits(Size first, Size second, double width) {
    return first.width + _gap + second.width <= width;
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final RenderBox? first = firstChild;

    if (first == null) {
      return constraints.smallest;
    }

    final BoxConstraints inner = _inner(constraints);
    final Size a = first.getDryLayout(inner);
    final RenderBox? second = childAfter(first);

    if (second == null) {
      return constraints.constrain(a);
    }

    final Size b = second.getDryLayout(inner);

    if (_fits(a, b, constraints.maxWidth)) {
      final double aBase = first.getDryBaseline(inner, TextBaseline.alphabetic) ?? a.height;
      final double bBase = second.getDryBaseline(inner, TextBaseline.alphabetic) ?? b.height;
      final double above = math.max(aBase, bBase);
      final double below = math.max(a.height - aBase, b.height - bBase);

      return constraints.constrain(Size(a.width + _gap + b.width, above + below));
    }

    return constraints.constrain(Size(math.max(a.width, b.width), a.height + _runGap + b.height));
  }

  @override
  void performLayout() {
    final RenderBox? first = firstChild;

    if (first == null) {
      size = constraints.smallest;
      return;
    }

    final BoxConstraints inner = _inner(constraints);

    first.layout(inner, parentUsesSize: true);

    final RenderBox? second = childAfter(first);
    final _ValueLineData firstData = first.parentData! as _ValueLineData;

    if (second == null) {
      size = constraints.constrain(first.size);
      firstData.offset = Offset(_start(first.size.width, size.width), 0);
      return;
    }

    second.layout(inner, parentUsesSize: true);

    final _ValueLineData secondData = second.parentData! as _ValueLineData;

    if (_fits(first.size, second.size, constraints.maxWidth)) {
      final double aBase =
          first.getDistanceToBaseline(TextBaseline.alphabetic) ?? first.size.height;
      final double bBase =
          second.getDistanceToBaseline(TextBaseline.alphabetic) ?? second.size.height;
      final double above = math.max(aBase, bBase);
      final double below = math.max(first.size.height - aBase, second.size.height - bBase);
      final double width = first.size.width + _gap + second.size.width;

      size = constraints.constrain(Size(width, above + below));

      final bool rtl = _textDirection == TextDirection.rtl;

      firstData.offset = Offset(rtl ? size.width - first.size.width : 0, above - aBase);
      secondData.offset = Offset(rtl ? size.width - width : first.size.width + _gap, above - bBase);
      return;
    }

    size = constraints.constrain(
      Size(
        math.max(first.size.width, second.size.width),
        first.size.height + _runGap + second.size.height,
      ),
    );
    firstData.offset = Offset(_start(first.size.width, size.width), 0);
    secondData.offset = Offset(_start(second.size.width, size.width), first.size.height + _runGap);
  }

  double _start(double width, double available) {
    return _textDirection == TextDirection.rtl ? available - width : 0;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    double widest = 0;

    for (RenderBox? child = firstChild; child != null; child = childAfter(child)) {
      widest = math.max(widest, child.getMinIntrinsicWidth(height));
    }

    return widest;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    double total = 0;
    int count = 0;

    for (RenderBox? child = firstChild; child != null; child = childAfter(child)) {
      total += child.getMaxIntrinsicWidth(height);
      count += 1;
    }

    return total + (count > 1 ? _gap : 0);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return computeDryLayout(BoxConstraints(maxWidth: width)).height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) => computeMinIntrinsicHeight(width);

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToFirstActualBaseline(baseline);
  }

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
