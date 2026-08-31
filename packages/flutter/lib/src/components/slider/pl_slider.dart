/// A value chosen along a range.
library;

import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How thick the groove is.
///
/// The thumb is deliberately far bigger than it — the thumb is the only part of
/// the control you can actually hit, and one sized to match a 6px rail is a
/// thumb nobody catches on a touchscreen.
const Map<PlassSize, double> _railThickness = <PlassSize, double>{
  PlassSize.xs: 4,
  PlassSize.sm: 6,
  PlassSize.md: 6,
  PlassSize.lg: 8,
  PlassSize.xl: 10,
};

/// How large the thumb is.
const Map<PlassSize, double> _thumbSize = <PlassSize, double>{
  PlassSize.xs: 12,
  PlassSize.sm: 14,
  PlassSize.md: 18,
  PlassSize.lg: 20,
  PlassSize.xl: 24,
};

/// How tall the whole strip is.
///
/// The control is taller than the groove it holds so that the whole strip is a
/// pointer target, not just the rail: pressing the track moves the nearest
/// thumb, and a 6px hit area would make that unusable.
const Map<PlassSize, double> _boxThickness = <PlassSize, double>{
  PlassSize.xs: 16,
  PlassSize.sm: 18,
  PlassSize.md: 20,
  PlassSize.lg: 24,
  PlassSize.xl: 28,
};

/// How far the halo reaches past a hovered thumb, and past a dragged one.
const double _haloHover = 4;
const double _haloDrag = 6;

/// The ring in the page's own surface colour that keeps a thumb from dissolving
/// into the run behind it.
const double _thumbRing = 2;

/// How long a vertical slider is when nothing gives it a length.
const double _verticalLength = 160;

/// A value chosen along a range.
///
/// ```dart
/// PlSlider(
///   values: <double>[volume],
///   onChanged: (List<double> next) => setState(() => volume = next.first),
///   label: const Text('Volume'),
/// )
/// ```
///
/// Pass more than one value and it becomes a range slider with one thumb per
/// entry — there is no separate `range` parameter, because the shape of the
/// value already says which one this is.
///
/// The rail is the **groove**, the same neutral ink a switch's off state is, so
/// the two controls in a settings panel are visibly made of the same thing. The
/// run over it is the family's gradient, so the filled part is made of exactly
/// the same material as the button that submits the form it is in.
class PlSlider extends StatefulWidget {
  /// Creates a slider.
  const PlSlider({
    required this.values,
    this.onChanged,
    this.onChangeEnd,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.size,
    this.color,
    this.elevation = 1,
    this.orientation = PlassOrientation.horizontal,
    this.length,
    this.label,
    this.description,
    this.showValue = false,
    this.formatValue,
    this.disabled = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(min < max, 'min must be below max'),
       assert(step > 0, 'step must be positive'),
       assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The chosen value, or the ends of the chosen range.
  ///
  /// Deliberately unasserted: `values.length` cannot be read in a `const`
  /// constructor's initialiser list, and a slider that could not be `const` for
  /// the sake of one check is a worse trade than an empty list drawing no
  /// thumbs.
  final List<double> values;

  /// Called as a thumb moves, with every value in order.
  ///
  /// Leaving it `null` disables the slider, as it does everywhere else in
  /// Flutter.
  final ValueChanged<List<double>>? onChanged;

  /// Called once, when the thumb is let go.
  final ValueChanged<List<double>>? onChangeEnd;

  /// The bottom of the range.
  final double min;

  /// The top of it.
  final double max;

  /// How far one press of an arrow key moves a thumb, and what a drag snaps to.
  final double step;

  /// Groove thickness and thumb diameter together.
  final PlassSize? size;

  /// Semantic colour role.
  final PlassColor? color;

  /// Drop shadow depth of the **thumb**.
  ///
  /// `1`, like a button: the thumb is the one part of a slider you press, and it
  /// rests on the sheet.
  final PlassElevation elevation;

  /// Which way the slider runs.
  final PlassOrientation orientation;

  /// How long the run is. A vertical slider has no length of its own, so this is
  /// where one comes from; horizontally it is the width the parent allows.
  final double? length;

  /// The label above the track.
  final Widget? label;

  /// Helper text below it.
  final Widget? description;

  /// Shows the current value beside the label.
  final bool showValue;

  /// Formats that value. Left out, it is printed with no decimals.
  final String Function(List<double> values)? formatValue;

  /// Unavailable. The light goes out.
  final bool disabled;

  /// The name a screen reader announces, for a slider with no visible [label].
  final String? semanticLabel;

  /// Drive focus from outside. Reaches the first thumb.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  @override
  State<PlSlider> createState() => _PlSliderState();
}

class _PlSliderState extends State<PlSlider> {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;

  /// Which thumb the pointer or the keyboard is on, or `null` for none.
  int? _active;
  int? _hovered;

  bool get _disabled => widget.disabled || widget.onChanged == null;

  bool get _vertical => widget.orientation == PlassOrientation.vertical;

  /// Whether the run is mirrored.
  ///
  /// A slider is a value laid along a line, and a line is read in the direction
  /// the page is read: the minimum belongs at the inline start. So three things
  /// turn over together — where the fill is painted, which end a press maps to,
  /// and which way an arrow key counts — and they have to turn over together or
  /// the control disagrees with itself.
  bool get _rtl => Directionality.of(context) == TextDirection.rtl;

  /// Where [value] sits along the run, as 0..1.
  double _fraction(double value) {
    return ((value - widget.min) / (widget.max - widget.min)).clamp(0, 1);
  }

  /// The value at [fraction], snapped to the step and held inside its
  /// neighbours.
  ///
  /// Thumbs cannot cross: a range whose ends have swapped is a range that was
  /// entered backwards, and the fix belongs here rather than in every caller.
  double _valueAt(double fraction, int index) {
    final raw = widget.min + fraction.clamp(0, 1) * (widget.max - widget.min);
    final snapped = widget.min + ((raw - widget.min) / widget.step).round() * widget.step;
    final lower = index > 0 ? widget.values[index - 1] : widget.min;
    final upper = index < widget.values.length - 1 ? widget.values[index + 1] : widget.max;

    return snapped.clamp(lower, upper);
  }

  void _report(int index, double value, {bool ended = false}) {
    final next = <double>[...widget.values]..[index] = value;

    widget.onChanged?.call(next);

    if (ended) {
      widget.onChangeEnd?.call(next);
    }
  }

  /// The thumb nearest a press, which is the one a press on the rail moves.
  int _nearest(double fraction) {
    var best = 0;
    var distance = double.infinity;

    for (var index = 0; index < widget.values.length; index += 1) {
      final gap = (_fraction(widget.values[index]) - fraction).abs();

      if (gap < distance) {
        distance = gap;
        best = index;
      }
    }

    return best;
  }

  double _fractionOf(Offset local, Size box) {
    // A vertical slider runs bottom to top, which is what "up is more" means
    // everywhere outside a scroll bar.
    if (_vertical) {
      return 1 - local.dy / box.height;
    }

    final fraction = local.dx / box.width;

    return _rtl ? 1 - fraction : fraction;
  }

  KeyEventResult _onKey(int index, KeyEvent event) {
    if (_disabled || (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
      return KeyEventResult.ignored;
    }

    final range = widget.max - widget.min;
    double? next;

    // Up and down are up and down in every writing direction; right and left
    // are the ones that mean "further along the line".
    final along = _rtl ? -widget.step : widget.step;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
        next = widget.values[index] + widget.step;
      case LogicalKeyboardKey.arrowDown:
        next = widget.values[index] - widget.step;
      case LogicalKeyboardKey.arrowRight:
        next = widget.values[index] + along;
      case LogicalKeyboardKey.arrowLeft:
        next = widget.values[index] - along;
      case LogicalKeyboardKey.home:
        next = widget.min;
      case LogicalKeyboardKey.end:
        next = widget.max;
      case LogicalKeyboardKey.pageUp:
        next = widget.values[index] + math.max(widget.step, range / 10);
      case LogicalKeyboardKey.pageDown:
        next = widget.values[index] - math.max(widget.step, range / 10);
    }

    if (next == null) {
      return KeyEventResult.ignored;
    }

    _report(index, _valueAt(_fraction(next), index), ended: true);

    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(_color);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final meta = metaText[_size]!;

    final rail = _railThickness[_size]!;
    final thumb = _thumbSize[_size]!;
    final box = _boxThickness[_size]!;

    Widget strip = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final run = _vertical ? constraints.maxHeight : constraints.maxWidth;
        final travel = math.max(0.0, run - thumb);

        // A range's run starts at the first thumb; a single value's starts at
        // the bottom of the range.
        final from = widget.values.length > 1 ? _fraction(widget.values.first) : 0.0;
        final to = _fraction(widget.values.last);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTapDown: _disabled
              ? null
              : (TapDownDetails details) {
                  final fraction = _fractionOf(details.localPosition, constraints.biggest);
                  final index = _nearest(fraction);

                  _report(index, _valueAt(fraction, index), ended: true);
                },
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // The rail, and the run over it.
              Align(
                child: SizedBox(
                  width: _vertical ? rail : null,
                  height: _vertical ? null : rail,
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: tokens.track,
                            // A pill rather than the radius ladder: this is a
                            // channel something travels along, not a sheet.
                            borderRadius: BorderRadius.circular(rail),
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        start: _vertical ? 0 : from * run,
                        end: _vertical ? 0 : (1 - to) * run,
                        top: _vertical ? (1 - to) * run : 0,
                        bottom: _vertical ? from * run : 0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: family.fill,
                            borderRadius: BorderRadius.circular(rail),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              for (var index = 0; index < widget.values.length; index += 1)
                PositionedDirectional(
                  start: _vertical ? null : _fraction(widget.values[index]) * travel,
                  bottom: _vertical ? _fraction(widget.values[index]) * travel : null,
                  child: _Thumb(
                    size: thumb,
                    family: family,
                    tokens: tokens,
                    elevation: widget.elevation,
                    disabled: _disabled,
                    hovered: _hovered == index,
                    dragging: _active == index,
                    reduceMotion: reduceMotion,
                    focusNode: index == 0 ? widget.focusNode : null,
                    autofocus: index == 0 && widget.autofocus,
                    onKey: (KeyEvent event) => _onKey(index, event),
                    onHover: (bool over) => setState(() => _hovered = over ? index : null),
                    onDrag: _disabled
                        ? null
                        : (Offset global, bool ended) {
                            final render = context.findRenderObject()! as RenderBox;
                            final local = render.globalToLocal(global);

                            setState(() => _active = ended ? null : index);
                            _report(
                              index,
                              _valueAt(_fractionOf(local, render.size), index),
                              ended: ended,
                            );
                          },
                  ),
                ),
            ],
          ),
        );
      },
    );

    strip = SizedBox(
      width: _vertical ? box : widget.length,
      height: _vertical ? (widget.length ?? _verticalLength) : box,
      child: strip,
    );

    strip = plassStateFilter(child: strip, disabled: _disabled, lit: false);

    final header = widget.label != null || widget.showValue
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (widget.label != null)
                DefaultTextStyle.merge(
                  style: TextStyle(
                    color: _disabled ? tokens.mutedFg : tokens.fg,
                    fontSize: meta,
                    fontWeight: FontWeight.w600,
                  ),
                  child: widget.label!,
                ),
              if (widget.showValue) ...<Widget>[
                const Spacer(),
                Text(
                  widget.formatValue?.call(widget.values) ??
                      widget.values.map((double one) => one.round().toString()).join(' – '),
                  style: TextStyle(
                    color: tokens.mutedFg,
                    fontSize: meta,
                    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ],
          )
        : null;

    return Semantics(
      container: true,
      slider: true,
      enabled: !_disabled,
      label: widget.semanticLabel,
      value: widget.values.map((double one) => one.round().toString()).join(' – '),
      child: Column(
        crossAxisAlignment: _vertical ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: _vertical ? 8 : 6,
        children: <Widget>[
          ?header,
          strip,
          if (widget.description != null)
            DefaultTextStyle.merge(
              style: TextStyle(color: tokens.mutedFg, fontSize: meta),
              child: widget.description!,
            ),
        ],
      ),
    );
  }
}

/// One thumb: a key of tinted glass on the same gradient as the run behind it,
/// separated from it by a ring in the page's own surface colour — white on a
/// light page, near-black on a dark one — so it never dissolves into the
/// indicator it is sitting on.
///
/// It grows a **halo** on hover and while dragging rather than growing itself.
/// The no-transform rule is not relaxed just because this particular part
/// carries no label.
class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.size,
    required this.family,
    required this.tokens,
    required this.elevation,
    required this.disabled,
    required this.hovered,
    required this.dragging,
    required this.reduceMotion,
    required this.focusNode,
    required this.autofocus,
    required this.onKey,
    required this.onHover,
    required this.onDrag,
  });

  final double size;
  final PlassColorFamily family;
  final PlassTokens tokens;
  final int elevation;
  final bool disabled;
  final bool hovered;
  final bool dragging;
  final bool reduceMotion;
  final FocusNode? focusNode;
  final bool autofocus;
  final KeyEventResult Function(KeyEvent event) onKey;
  final ValueChanged<bool> onHover;
  final void Function(Offset global, bool ended)? onDrag;

  @override
  Widget build(BuildContext context) {
    final halo = dragging
        ? _haloDrag
        : hovered
        ? _haloHover
        : 0.0;
    final level = dragging
        ? elevation - 1
        : hovered
        ? elevation + 1
        : elevation;

    return Focus(
      focusNode: focusNode,
      autofocus: autofocus,
      canRequestFocus: !disabled,
      onKeyEvent: (FocusNode node, KeyEvent event) => onKey(event),
      child: Builder(
        builder: (BuildContext context) {
          final focusVisible = Focus.of(context).hasPrimaryFocus;

          Widget mark = AnimatedContainer(
            duration: reduceMotion ? Duration.zero : PlassTokens.duration,
            curve: PlassTokens.ease,
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: family.fill,
              border: Border.all(color: tokens.surface, width: _thumbRing),
              boxShadow: <BoxShadow>[
                ...tokens.elevation(level),
                if (dragging)
                  tokens.liftPress(family)
                else if (hovered)
                  tokens.liftHover(family)
                else
                  tokens.lift(family),
                if (halo > 0)
                  BoxShadow(color: dragging ? family.softHover : family.soft, spreadRadius: halo),
              ],
            ),
          );

          if (focusVisible) {
            mark = CustomPaint(
              foregroundPainter: PlassFocusRingPainter(
                color: family.ring,
                borderRadius: BorderRadius.circular(size),
              ),
              child: mark,
            );
          }

          return MouseRegion(
            cursor: disabled
                ? SystemMouseCursors.forbidden
                : dragging
                ? SystemMouseCursors.grabbing
                : SystemMouseCursors.grab,
            onEnter: (PointerEnterEvent event) => onHover(true),
            onExit: (PointerExitEvent event) => onHover(false),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onHorizontalDragUpdate: onDrag == null
                  ? null
                  : (DragUpdateDetails details) => onDrag!(details.globalPosition, false),
              onHorizontalDragEnd: onDrag == null
                  ? null
                  : (DragEndDetails details) => onDrag!(details.globalPosition, true),
              onVerticalDragUpdate: onDrag == null
                  ? null
                  : (DragUpdateDetails details) => onDrag!(details.globalPosition, false),
              onVerticalDragEnd: onDrag == null
                  ? null
                  : (DragEndDetails details) => onDrag!(details.globalPosition, true),
              child: mark,
            ),
          );
        },
      ),
    );
  }
}
