/// Content that is covered until somebody asks for it.
library;

import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/button/pl_button.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How much of the page's own surface goes over the blur.
///
/// Blur alone is not cover. It takes a paragraph apart but leaves its colour and
/// its rhythm — a photograph blurred at 10 is still recognisably a photograph of
/// a face — and it leaves the button standing on whatever happened to be
/// underneath it. Mixing the screen's own surface over the top settles both.
const double _scrim = 0.55;

/// The gap between the notice and the button under it.
const double _coverGap = 8;

/// Content that is covered until somebody asks for it.
///
/// ```dart
/// PlSpoiler(
///   revealed: showing,
///   onRevealedChanged: (bool next) => setState(() => showing = next),
///   reversible: true,
///   child: const Text('Rosebud was the name painted on the sled he had as a child.'),
/// )
/// ```
///
/// The cover is a **blur** rather than a hidden box, which is the whole point: a
/// reader can see that there is something there, roughly how much of it there
/// is, and — with [maxHeight] — that it has been clamped. What they cannot do is
/// read it by accident, which is the one thing a spoiler is for.
///
/// While it is covered the content is taken out of the focus order, off the
/// semantics tree and out of reach of the pointer. A spoiler somebody can tab
/// into is not a spoiler.
///
/// The sheet is never dyed, exactly as on a [PlCard]: what a spoiler holds is a
/// photograph, a paragraph, a plot twist, and it arrives with its own colours.
/// The family shows up on the button and in the hairline and stops there.
///
/// **The box is the same height covered and uncovered**, which takes both of the
/// things that could move it. The cover is an unpositioned child of the same
/// stack as the content rather than something laid over it, so a cover taller
/// than a one-line spoiler makes the sheet taller instead of being clipped by
/// it; and the [reversible] Hide row is built from the start and merely held
/// invisible, so it is not a button's worth of height that arrives on the way in
/// and leaves again on the way out.
class PlSpoiler extends StatefulWidget {
  /// Creates a spoiler.
  const PlSpoiler({
    this.child,
    this.revealed,
    this.onRevealedChanged,
    this.label,
    this.hideLabel,
    this.description = const Text('This may contain spoilers'),
    this.action,
    this.reversible = false,
    this.maxHeight,
    this.blur = 10,
    this.padded = true,
    this.variant = PlassVariant.glass,
    this.size,
    this.color,
    this.density,
    this.elevation = 0,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// What is being covered.
  final Widget? child;

  /// Whether the content is uncovered.
  ///
  /// The one widget in the package that is happy **uncontrolled**, and the
  /// reason is what the state is: not a value the screen owns but a thing the
  /// reader did to this box. A page of a dozen spoilers should not be a dozen
  /// booleans on a `State` somewhere else. Pass it — with
  /// [onRevealedChanged] — for the cases where the screen genuinely does own it.
  final bool? revealed;

  /// Called when the reveal or hide button is pressed.
  final ValueChanged<bool>? onRevealedChanged;

  /// The name a screen reader gives the reveal button, and what it says.
  final String? label;

  /// The same for the hide button, when [reversible] is on.
  final String? hideLabel;

  /// The line above the button, saying why the content is covered. `null` is a
  /// cover with nothing written on it.
  final Widget? description;

  /// Replaces the default reveal button entirely.
  ///
  /// The replacement is yours to wire up: pass [revealed] and
  /// [onRevealedChanged] and drive it from your own control.
  final Widget? action;

  /// Keeps the content coverable: once revealed, a hide button appears under it.
  final bool reversible;

  /// Clamps the covered box to this height, in logical pixels.
  ///
  /// Revealing releases it and the content takes whatever height it needs — the
  /// clamp is only ever on the covered state, because revealing something and
  /// leaving it in a box with a scrollbar is answering the wrong question.
  final double? maxHeight;

  /// How hard the content is blurred.
  ///
  /// The same unit the React build writes as a CSS `blur()` radius, which is a
  /// Gaussian standard deviation either way — so the two packages smear the
  /// same amount for the same number.
  final double blur;

  /// Inner padding around the content. Turn it off for something that should
  /// reach the edges — a picture, a video.
  final bool padded;

  /// What the sheet is made of. Never dyed. [PlassVariant.ghost] draws no box at
  /// all, which is what a spoiler inside running prose usually wants.
  final PlassVariant variant;

  /// The sheet's radius, and the size of the button on it.
  final PlassSize? size;

  /// Semantic colour role. It reaches the button and the hairline.
  final PlassColor? color;

  /// Padding around the cover's own text and button.
  final PlassDensity? density;

  /// Drop shadow depth, `0`–`3`. `0` and flat.
  final PlassElevation elevation;

  @override
  State<PlSpoiler> createState() => _PlSpoilerState();
}

class _PlSpoilerState extends State<PlSpoiler> {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

  late bool _uncontrolled = widget.revealed ?? false;

  bool get _open => widget.revealed ?? _uncontrolled;

  void _change(bool next) {
    if (widget.revealed == null) {
      setState(() => _uncontrolled = next);
    }

    widget.onRevealedChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final radius = BorderRadius.circular(PlassTokens.radius[_size]!);
    final insetX = sheetPaddingX[_density]![_size]!;
    final insetY = sheetPaddingY[_density]![_size]!;

    Widget content = widget.child ?? const SizedBox.shrink();

    if (widget.padded) {
      content = Padding(
        padding: EdgeInsets.symmetric(horizontal: insetX, vertical: insetY),
        child: content,
      );
    }

    if (!_open) {
      if (widget.maxHeight != null) {
        content = ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: widget.maxHeight!),
              child: content,
            ),
          ),
        );
      }

      content = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
        child: content,
      );

      // Out of the focus order, off the semantics tree and out of reach of the
      // pointer — the three things `inert` does in the other package, said as
      // the three widgets that do them here. A spoiler somebody can tab into is
      // not a spoiler.
      content = ExcludeSemantics(
        child: ExcludeFocus(child: IgnorePointer(child: content)),
      );
    }

    // The wash fills whatever the stack ends up being, and the cover's own text
    // and button are an *unpositioned* child so they count toward that size.
    // Together that is what keeps a one-line spoiler as tall as the button it is
    // asking somebody to press, rather than clipping it.
    final sheet = Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[content, if (widget.reversible) _hideRow(insetX, insetY)],
        ),
        if (!_open)
          Positioned.fill(
            child: ColoredBox(color: tokens.surface.withValues(alpha: tokens.surface.a * _scrim)),
          ),
        if (!_open) _cover(tokens, insetX, insetY),
      ],
    );

    return PlassSurfaceBox(
      surface: sheetSurface(tokens, variant: widget.variant, elevation: widget.elevation),
      borderRadius: radius,
      duration: PlassTokens.durationSlow,
      child: ClipRRect(borderRadius: radius, child: sheet),
    );
  }

  /// The way back out, drawn whether or not it can be seen.
  ///
  /// It used to be built only once the spoiler was open, which grew the sheet by
  /// the height of a button on the way in and shrank it back on the way out —
  /// the page moving twice around the control somebody is pressing. The row is
  /// in the column from the start now and merely held invisible, so its space is
  /// paid for once; the cover is painted over it, so what is reserved reads as
  /// part of the covered sheet rather than as a gap under the blur.
  ///
  /// [Visibility] with `maintainSize` keeps the space and takes the row off the
  /// pointer and out of the semantics, and [ExcludeFocus] takes it out of the
  /// traversal — between them the three things `inert` does in the other
  /// package, which is the same trio the covered content is wrapped in.
  Widget _hideRow(double insetX, double insetY) {
    final Widget row = Padding(
      // The row takes the sheet's padding and then gives the top back: padded
      // content already ends with a full gap, and two of them stacked is a hole
      // between the text and the way back out.
      padding: EdgeInsetsDirectional.only(start: insetX, end: insetX, bottom: insetY),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: PlButton(
          variant: PlassVariant.ghost,
          size: _size,
          color: _color,
          density: _density,
          onPressed: () => _change(false),
          child: Text(widget.hideLabel ?? PlassTheme.labelsOf(context).hide),
        ),
      ),
    );

    if (_open) {
      return row;
    }

    return ExcludeFocus(
      child: Visibility(
        visible: false,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: row,
      ),
    );
  }

  /// The notice and the button that lifts the cover.
  ///
  /// The wash is drawn separately, behind this, because the two answer different
  /// questions: the wash has to fill the sheet however tall the content made it,
  /// and this has to be able to *make* the sheet taller when the content is
  /// shorter than a button.
  Widget _cover(PlassTokens tokens, double insetX, double insetY) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: insetX, vertical: insetY),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: _coverGap,
        children: <Widget>[
          if (widget.description != null)
            DefaultTextStyle.merge(
              style: TextStyle(color: tokens.mutedFg, fontSize: metaText[_size]!),
              textAlign: TextAlign.center,
              child: widget.description!,
            ),
          widget.action ??
              PlButton(
                size: _size,
                color: _color,
                density: _density,
                onPressed: () => _change(true),
                child: Text(widget.label ?? PlassTheme.labelsOf(context).reveal),
              ),
        ],
      ),
    );
  }
}
