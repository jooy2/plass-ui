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
class PlSpoiler extends StatefulWidget {
  /// Creates a spoiler.
  const PlSpoiler({
    this.child,
    this.revealed,
    this.onRevealedChanged,
    this.label = 'Reveal',
    this.hideLabel = 'Hide',
    this.description = const Text('This may contain spoilers'),
    this.action,
    this.reversible = false,
    this.maxHeight,
    this.blur = 10,
    this.padded = true,
    this.variant = PlassVariant.glass,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
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
  final String label;

  /// The same for the hide button, when [reversible] is on.
  final String hideLabel;

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
  final PlassSize size;

  /// Semantic colour role. It reaches the button and the hairline.
  final PlassColor color;

  /// Padding around the cover's own text and button.
  final PlassDensity density;

  /// Drop shadow depth, `0`–`3`. `0` and flat.
  final PlassElevation elevation;

  @override
  State<PlSpoiler> createState() => _PlSpoilerState();
}

class _PlSpoilerState extends State<PlSpoiler> {
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
    final radius = BorderRadius.circular(PlassTokens.radius[widget.size]!);
    final insetX = sheetPaddingX[widget.density]![widget.size]!;
    final insetY = sheetPaddingY[widget.density]![widget.size]!;

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

    final sheet = Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            content,
            if (_open && widget.reversible)
              Padding(
                // The row takes the sheet's padding and then gives the top back:
                // padded content already ends with a full gap, and two of them
                // stacked is a hole between the text and the way back out.
                padding: EdgeInsets.only(left: insetX, right: insetX, bottom: insetY),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: PlButton(
                    variant: PlassVariant.ghost,
                    size: widget.size,
                    color: widget.color,
                    density: widget.density,
                    onPressed: () => _change(false),
                    child: Text(widget.hideLabel),
                  ),
                ),
              ),
          ],
        ),
        if (!_open) Positioned.fill(child: _cover(tokens, insetX, insetY)),
      ],
    );

    return PlassSurfaceBox(
      surface: sheetSurface(tokens, variant: widget.variant, elevation: widget.elevation),
      borderRadius: radius,
      duration: PlassTokens.durationSlow,
      child: ClipRRect(borderRadius: radius, child: sheet),
    );
  }

  /// The wash, the notice and the button that lifts them.
  Widget _cover(PlassTokens tokens, double insetX, double insetY) {
    return ColoredBox(
      color: tokens.surface.withValues(alpha: tokens.surface.a * _scrim),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: insetX, vertical: insetY),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: _coverGap,
          children: <Widget>[
            if (widget.description != null)
              DefaultTextStyle.merge(
                style: TextStyle(color: tokens.mutedFg, fontSize: metaText[widget.size]!),
                textAlign: TextAlign.center,
                child: widget.description!,
              ),
            widget.action ??
                PlButton(
                  size: widget.size,
                  color: widget.color,
                  density: widget.density,
                  onPressed: () => _change(true),
                  child: Text(widget.label),
                ),
          ],
        ),
      ),
    );
  }
}
