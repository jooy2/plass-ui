/// What a Plass surface is made of, and the widget that paints one.
///
/// This is `sheetRestClasses`, `fieldRestClasses` and `disabledClasses` from the
/// React package's `internal/styles.ts`, in Dart — plus the painting order those
/// class strings only imply, because CSS knows where a `backdrop-filter`, an
/// inset shadow and a `::before` go and Flutter has to be told.
///
/// A component describes its surface as a [PlassSurface] and hands it to a
/// [PlassSurfaceBox]. It does not stack the layers itself. The order they go in
/// is load-bearing and identical everywhere — blur, fill, gloss, bloom, content,
/// flash — and a component that assembled its own would be a component free to
/// get it subtly wrong.
///
/// None of this is exported from `plass_ui.dart` — it is the library talking to
/// itself.
library;

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/css.dart';
import 'package:plass_ui/src/internal/glow.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// A resolved surface: everything that decides what a box looks like, and
/// nothing about what is in it.
@immutable
class PlassSurface {
  /// Creates a surface.
  const PlassSurface({
    required this.ink,
    this.fill,
    this.gradient,
    this.border,
    this.blur = false,
    this.insets = const <PlassInsetShadow>[],
    this.shadows = const <BoxShadow>[],
  });

  /// The colour text and glyphs on this surface are drawn in.
  final Color ink;

  /// A flat fill, or `null` for none.
  final Color? fill;

  /// A gradient fill, drawn over [fill] when both are given.
  final Gradient? gradient;

  /// The hairline around it.
  final BoxBorder? border;

  /// Whether what is behind it is blurred and saturated — the glass material.
  final bool blur;

  /// Shadows that fall *inside* the shape: the gloss along a cut edge, the well
  /// a field is sunk into.
  final List<PlassInsetShadow> insets;

  /// Shadows that fall outside it: the elevation ladder and the tinted lift.
  final List<BoxShadow> shadows;

  /// The same surface with [shadows] replaced — for a caller that has already
  /// decided a surface and only needs to change how far off the page it is.
  PlassSurface withShadows(List<BoxShadow> replacement) {
    return PlassSurface(
      ink: ink,
      fill: fill,
      gradient: gradient,
      border: border,
      blur: blur,
      insets: insets,
      shadows: replacement,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PlassSurface &&
        other.ink == ink &&
        other.fill == fill &&
        other.gradient == gradient &&
        other.border == border &&
        other.blur == blur &&
        listEquals(other.insets, insets) &&
        listEquals(other.shadows, shadows);
  }

  @override
  int get hashCode => Object.hash(
    ink,
    fill,
    gradient,
    border,
    blur,
    Object.hashAll(insets),
    Object.hashAll(shadows),
  );
}

/// Paints a [PlassSurface], with the interaction light on top of it if there is
/// any.
///
/// The layers go in the order the stylesheet puts them and no other: the
/// backdrop blur underneath everything, the fill over it, the gloss inside that,
/// the pointer bloom under the content and the press flash over it — which is
/// exactly where `::before` and `::after` sit in the CSS.
class PlassSurfaceBox extends StatelessWidget {
  /// Creates a painted surface around [child].
  const PlassSurfaceBox({
    required this.surface,
    required this.borderRadius,
    required this.child,
    this.pointer,
    this.glow,
    this.glowVisible = false,
    this.flash,
    this.flashVisible = false,
    this.reduceMotion = false,
    this.animate = true,
    this.duration = PlassTokens.duration,
    super.key,
  });

  /// What the box is made of.
  final PlassSurface surface;

  /// Its corners, which the clip, the gloss and the shadows all follow.
  final BorderRadius borderRadius;

  /// What is drawn on it.
  final Widget child;

  /// Where the pointer is, in this box's coordinates.
  final Offset? pointer;

  /// The bloom's colour. `null` leaves the layer out entirely.
  final Color? glow;

  /// Whether the bloom is lit.
  final bool glowVisible;

  /// The press flash's colour. `null` leaves the layer out entirely.
  final Color? flash;

  /// Whether the flash is lit.
  final bool flashVisible;

  /// Whether the platform has asked for less movement.
  final bool reduceMotion;

  /// Whether a change of surface is eased. `false` for a box whose colours are
  /// already being animated by something outside it.
  final bool animate;

  /// How long that easing takes. [PlassTokens.durationSlow] for anything larger
  /// than a control.
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final motion = animate && !reduceMotion ? duration : Duration.zero;

    Widget box = Stack(
      alignment: Alignment.center,
      children: <Widget>[
        if (surface.blur)
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.compose(
                outer: saturationFilter(tokens.saturation),
                inner: ui.ImageFilter.blur(sigmaX: tokens.blurSigma, sigmaY: tokens.blurSigma),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        Positioned.fill(
          child: AnimatedContainer(
            duration: motion,
            curve: PlassTokens.ease,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: surface.fill,
              gradient: surface.gradient,
              border: surface.border,
            ),
          ),
        ),
        if (surface.insets.isNotEmpty)
          Positioned.fill(
            child: CustomPaint(
              painter: PlassInsetShadowPainter(shadows: surface.insets, borderRadius: borderRadius),
            ),
          ),
        if (glow != null)
          Positioned.fill(
            child: RepaintBoundary(
              child: PlassGlowLayer(
                pointer: pointer,
                visible: glowVisible,
                color: glow!,
                radius: glowRadius,
                duration: PlassTokens.glowDuration,
                reduceMotion: reduceMotion,
              ),
            ),
          ),
        child,
        if (flash != null)
          Positioned.fill(
            child: RepaintBoundary(
              child: PlassGlowLayer(
                pointer: pointer,
                visible: flashVisible,
                color: flash!,
                radius: flashRadius,
                duration: PlassTokens.flashDuration,
                curve: PlassTokens.flashEase,
                instant: true,
                reduceMotion: reduceMotion,
              ),
            ),
          ),
      ],
    );

    box = ClipRRect(borderRadius: borderRadius, child: box);

    // The drop shadows cannot live inside the clip that keeps the glass and the
    // light inside the corners, so they are the box around it.
    return AnimatedContainer(
      duration: motion,
      curve: PlassTokens.ease,
      decoration: BoxDecoration(borderRadius: borderRadius, boxShadow: surface.shadows),
      child: box,
    );
  }
}

/* ---------------------------------------------------------------------------
 * The three surfaces
 *
 * A control is pressed, a sheet holds content, a field holds a value. Each has
 * its own answer to what the three variants mean, and the differences between
 * them are decisions rather than accidents — a `solid` field is not a moulded
 * key, because a caret and a text selection have to stay legible on it.
 * ------------------------------------------------------------------------ */

/// A control's surface — something that is **pressed**.
///
/// The elevation ladder moves with the pointer: hovering adds a level and
/// pressing removes one, which is what puts a key down against the sheet under
/// the finger. The tinted lift is separate and does not scale with it.
PlassSurface controlSurface(
  PlassTokens tokens,
  PlassColorFamily family, {
  required PlassVariant variant,
  required int elevation,
  bool hovered = false,
  bool pressed = false,
  bool readOnly = false,
  bool disabled = false,
}) {
  if (disabled) {
    switch (variant) {
      case PlassVariant.solid:
        return PlassSurface(gradient: family.fill, ink: family.onSolid);
      case PlassVariant.glass:
        return PlassSurface(
          fill: tokens.glass,
          border: Border.all(color: tokens.border, width: hairline),
          // The neutral foreground, not the family's: a disabled control has
          // stopped being a `danger` button and become a shape.
          ink: tokens.fg,
          blur: true,
        );
      case PlassVariant.ghost:
        return PlassSurface(ink: family.accent);
    }
  }

  if (readOnly) {
    switch (variant) {
      case PlassVariant.solid:
        return PlassSurface(gradient: family.fill, ink: family.onSolid);
      case PlassVariant.glass:
        return PlassSurface(
          fill: tokens.glass,
          border: Border.all(color: tokens.glassLine, width: hairline),
          insets: <PlassInsetShadow>[tokens.glossGlass],
          ink: family.accent,
          blur: true,
        );
      case PlassVariant.ghost:
        return PlassSurface(ink: family.accent);
    }
  }

  final level = pressed
      ? elevation - 1
      : hovered
      ? elevation + 1
      : elevation;

  switch (variant) {
    case PlassVariant.solid:
      return PlassSurface(
        gradient: family.fill,
        ink: family.onSolid,
        shadows: <BoxShadow>[
          ...tokens.elevation(level),
          if (pressed)
            tokens.liftPress(family)
          else if (hovered)
            tokens.liftHover(family)
          else
            tokens.lift(family),
        ],
      );
    case PlassVariant.glass:
      return PlassSurface(
        fill: pressed
            ? tokens.glassPress
            : hovered
            ? tokens.glassHover
            : tokens.glass,
        border: Border.all(
          color: hovered || pressed ? family.line : tokens.glassLine,
          width: hairline,
        ),
        insets: <PlassInsetShadow>[tokens.glossGlass],
        ink: family.accent,
        blur: true,
        shadows: tokens.elevation(level),
      );
    case PlassVariant.ghost:
      // Nothing to catch the light on, and nothing to cast a shadow.
      return PlassSurface(
        fill: pressed
            ? family.softHover
            : hovered
            ? family.soft
            : null,
        ink: family.accent,
      );
  }
}

/// The sheet a **container** is drawn on — a card, an accordion, a table, a
/// modal's panel. Everything that holds other people's content rather than
/// being pressed.
///
/// The three variants say what they say everywhere else, read as a *material*
/// rather than as an appearance, and the ladder between them is opacity:
///
/// - `solid` — the clear glass at its most opaque, for a panel that has to sit
///   forward of everything around it. No border, because a slab that dense has
///   no edge left to catch light on.
/// - `glass` — the canonical Plass sheet, and the default on every container.
/// - `ghost` — no sheet at all, for a container inside a container.
///
/// None of the three is dyed, and no colour family reaches this function. What a
/// container holds arrives with its own colours, and tinting the sheet under
/// them puts every one on a background it was not chosen against; the family
/// shows up in the hairline, the focus ring and the caret and stops there.
PlassSurface sheetSurface(
  PlassTokens tokens, {
  required PlassVariant variant,
  required int elevation,
}) {
  switch (variant) {
    case PlassVariant.solid:
      return PlassSurface(
        fill: tokens.glassPress,
        ink: tokens.fg,
        blur: true,
        insets: <PlassInsetShadow>[tokens.glossGlass],
        shadows: tokens.elevation(elevation),
      );
    case PlassVariant.glass:
      return PlassSurface(
        fill: tokens.glass,
        border: Border.all(color: tokens.glassLine, width: hairline),
        ink: tokens.fg,
        blur: true,
        insets: <PlassInsetShadow>[tokens.glossGlass],
        shadows: tokens.elevation(elevation),
      );
    case PlassVariant.ghost:
      return PlassSurface(ink: tokens.fg);
  }
}

/// The shell a field-shaped control is drawn on — a text field's box, a select's
/// trigger, a number field's — which have to be indistinguishable, or a form
/// looks like two different forms stacked on each other.
///
/// One deliberate difference from [controlSurface]: `solid` is not a moulded
/// key. What a field holds is user data, and a caret, a selection and a
/// placeholder all have to stay legible on top of it, which they are not on a
/// gradient. So a `solid` field is the **well** — the glass at its most opaque
/// with an inset shadow falling into it, the one shadow in the library that
/// points downward — and the family shows up in the hairline, the ring and the
/// caret instead.
///
/// The edge is [PlassTokens.border] rather than the sheet's own
/// [PlassTokens.glassLine], and that is the same correction a checkbox's tick
/// and a radio's ring carry: white light on a cut edge is a claim about the page
/// wash behind the pane, and a field is very often *not* on the page — it is on
/// a card, where a white hairline round a white box is a field a reader cannot
/// see the shape of.
PlassSurface fieldSurface(
  PlassTokens tokens,
  PlassColorFamily family, {
  required PlassVariant variant,
  required int elevation,
  bool hovered = false,
  bool focused = false,
  bool readOnly = false,
  bool disabled = false,
}) {
  if (disabled) {
    switch (variant) {
      case PlassVariant.solid:
        return PlassSurface(
          fill: tokens.glassPress,
          ink: tokens.fg,
          blur: true,
          insets: <PlassInsetShadow>[tokens.well],
        );
      case PlassVariant.glass:
        return PlassSurface(
          fill: tokens.glassHover,
          border: Border.all(color: tokens.border, width: hairline),
          ink: tokens.fg,
          blur: true,
        );
      case PlassVariant.ghost:
        return PlassSurface(ink: tokens.fg);
    }
  }

  if (readOnly) {
    switch (variant) {
      case PlassVariant.solid:
        return PlassSurface(
          fill: tokens.glassPress,
          ink: tokens.fg,
          blur: true,
          insets: <PlassInsetShadow>[tokens.well],
        );
      case PlassVariant.glass:
        return PlassSurface(
          fill: tokens.glassHover,
          border: Border.all(color: tokens.border, width: hairline),
          ink: tokens.fg,
          blur: true,
          insets: <PlassInsetShadow>[tokens.glossGlass],
        );
      case PlassVariant.ghost:
        return PlassSurface(ink: tokens.fg);
    }
  }

  switch (variant) {
    case PlassVariant.solid:
      return PlassSurface(
        // A well lightens as it is engaged rather than darkening: the shadow
        // falling into it is what says it is sunk, and the fill is the light it
        // is holding.
        fill: focused
            ? tokens.glassPress
            : hovered
            ? tokens.glassHover
            : tokens.glassPress,
        ink: tokens.fg,
        blur: true,
        insets: <PlassInsetShadow>[tokens.well],
        shadows: tokens.elevation(elevation),
      );
    case PlassVariant.glass:
      return PlassSurface(
        fill: hovered || focused ? tokens.glassPress : tokens.glassHover,
        border: Border.all(
          color: focused
              ? family.lineHover
              : hovered
              ? family.line
              : tokens.border,
          width: hairline,
        ),
        ink: tokens.fg,
        blur: true,
        insets: <PlassInsetShadow>[tokens.glossGlass],
        shadows: tokens.elevation(elevation),
      );
    case PlassVariant.ghost:
      // No surface until it is wanted — the field in a table cell that only
      // looks like a field once you go near it.
      return PlassSurface(
        fill: focused
            ? family.softHover
            : hovered
            ? family.soft
            : null,
        ink: tokens.fg,
      );
  }
}

/* ---------------------------------------------------------------------------
 * The filters
 *
 * CSS applies `opacity` and `filter` to the whole element — its fill, its label
 * and the shadow it casts — so both wrap a finished surface rather than being
 * mixed into it. The two are mutually exclusive in practice: brightness is a
 * resting state's response to the pointer, saturation is what read-only and
 * disabled drain.
 * ------------------------------------------------------------------------ */

/// Wraps a finished surface in whatever `filter` and `opacity` its state calls
/// for.
///
/// [lit] is `false` for a surface that does not answer the pointer with light —
/// a field, a sheet — and leaves the brightness alone.
Widget plassStateFilter({
  required Widget child,
  bool disabled = false,
  bool readOnly = false,
  bool hovered = false,
  bool pressed = false,
  bool reduceMotion = false,
  bool lit = true,
}) {
  Widget surface = child;

  final saturation = disabled
      ? disabledSaturation
      : readOnly
      ? readOnlySaturation
      : null;

  if (saturation != null) {
    surface = ColorFiltered(colorFilter: saturationFilter(saturation), child: surface);
  } else if (lit) {
    final brightness = pressed
        ? pressBrightness
        : hovered
        ? hoverBrightness
        : 1.0;

    surface = TweenAnimationBuilder<double>(
      tween: Tween<double>(end: brightness),
      duration: reduceMotion ? Duration.zero : PlassTokens.duration,
      curve: PlassTokens.ease,
      child: surface,
      builder: (BuildContext context, double value, Widget? child) {
        if (value == 1) {
          return child!;
        }

        return ColorFiltered(colorFilter: brightnessFilter(value), child: child);
      },
    );
  }

  if (disabled) {
    surface = Opacity(opacity: disabledOpacity, child: surface);
  }

  return surface;
}
