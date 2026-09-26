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
import 'package:flutter/rendering.dart';
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

  /// Whether anything is painted behind what the surface holds: the glass, a
  /// gradient or a flat fill. An edge alone does not count.
  bool get paints => blur || fill != null || gradient != null;

  /// The same surface with no border at all — for a control whose edge is being
  /// drawn by something else.
  ///
  /// A notched field is the one caller: the line round it has a gap in it where
  /// the label sits, and a gap is not something a [BoxBorder] can have. See
  /// `internal/notch`.
  PlassSurface withoutBorder() {
    return PlassSurface(
      ink: ink,
      fill: fill,
      gradient: gradient,
      blur: blur,
      insets: insets,
      shadows: shadows,
    );
  }

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
///
/// A glass box reads the backdrop in the [BackdropGroup] above it, and any box
/// that paints something, glass or a fill, puts what it holds in a group of its
/// own, through a [PlassContentsGroup]. Filters that share a backdrop key share one read of the backdrop, taken
/// where the first of them is painted, so a glass field on a card that shared
/// the card's key would blur what was behind the *card*, read before the card
/// was drawn, and show the page through it. The same goes for a glass control
/// on a solid key or a tinted wash, whose fill is just as missing from a read
/// taken before it. With a group of its own the field reads the card it sits
/// on, the fields on one card still share that one read, and the card itself
/// still joins whatever group the app put above it.
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
    this.reduceMotion,
    this.animate = true,
    this.duration,
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

  /// The bloom's colour. `null` paints no bloom at all.
  final Color? glow;

  /// Whether the bloom is lit.
  final bool glowVisible;

  /// The press flash's colour. `null` paints no flash at all.
  final Color? flash;

  /// Whether the flash is lit.
  final bool flashVisible;

  /// Whether the platform has asked for less movement, or `null` to ask it:
  /// [MediaQueryData.disableAnimations] where the box is built.
  ///
  /// Under less movement a change of surface arrives at once and the light
  /// goes out at once, as every surface in the React build does under
  /// `prefers-reduced-motion`. `null` rather than a `false` default, so a box
  /// whose caller says nothing still answers the platform.
  final bool? reduceMotion;

  /// Whether a change of surface is eased. `false` for a box whose colours are
  /// already being animated by something outside it.
  final bool animate;

  /// How long that easing takes, or `null` for the theme's
  /// [PlassTokens.motionDuration]. [PlassTokens.motionDurationSlow] for
  /// anything larger than a control.
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final glow = this.glow;
    final flash = this.flash;
    final reduceMotion = this.reduceMotion ?? MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final motion = animate && !reduceMotion ? duration ?? tokens.motionDuration : Duration.zero;

    Widget box = Stack(
      alignment: Alignment.center,
      // Every layer keeps its place whatever the state, and only what is in it
      // changes. A layer that came and went would move every layer after it to
      // another place in the stack, which Flutter builds again from scratch.
      children: <Widget>[
        // The blur too, although a surface only has one while it is glass: a
        // `solid` toggle is glass while it is off and a gradient key while it
        // is on, and a blur that came and went with it built the fill again,
        // so the gradient arrived in one frame instead of easing in. An empty
        // box stands in rather than a disabled filter, because a
        // `BackdropFilter` asks what is above it to composite whether it is
        // enabled or not.
        Positioned.fill(
          child: surface.blur
              // `.grouped` rather than the plain constructor: with no
              // `BackdropGroup` above it this resolves to the same null
              // backdrop key and is the same widget, and with one above it
              // every sheet in that group reads the backdrop once instead of
              // once each. Where the group goes is the app's to say — a σ22
              // read shared between two sheets that overlap shows as one blur
              // across the overlap, and only the app knows whether its own
              // sheets overlap. A sheet *inside* this one is the exception the
              // library can see for itself, and the group round [child] below
              // is its answer. See the Flutter half of the design language
              // page.
              ? BackdropFilter.grouped(
                  filter: ui.ImageFilter.compose(
                    outer: saturationFilter(tokens.saturation),
                    inner: ui.ImageFilter.blur(sigmaX: tokens.blurSigma, sigmaY: tokens.blurSigma),
                  ),
                  child: const SizedBox.expand(),
                )
              : const SizedBox(),
        ),
        Positioned.fill(
          child: AnimatedContainer(
            duration: motion,
            curve: tokens.motionEase,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: surface.fill,
              gradient: surface.gradient,
              border: surface.border,
            ),
          ),
        ),
        // `readOnly` and `disabled` take the gloss off a glass surface and put
        // the light out, and a layer that came and went with them would move
        // what the box holds as well: a field would come back with a new
        // editor.
        Positioned.fill(
          child: CustomPaint(
            painter: surface.insets.isEmpty
                ? null
                : PlassInsetShadowPainter(shadows: surface.insets, borderRadius: borderRadius),
          ),
        ),
        Positioned.fill(
          child: glow == null
              ? const SizedBox()
              : RepaintBoundary(
                  child: PlassGlowLayer(
                    pointer: pointer,
                    visible: glowVisible,
                    color: glow,
                    radius: glowRadius,
                    duration: PlassTokens.glowDuration,
                    reduceMotion: reduceMotion,
                  ),
                ),
        ),
        PlassContentsGroup(paints: surface.paints, child: child),
        Positioned.fill(
          child: flash == null
              ? const SizedBox()
              : RepaintBoundary(
                  child: PlassGlowLayer(
                    pointer: pointer,
                    visible: flashVisible,
                    color: flash,
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
      curve: tokens.motionEase,
      decoration: BoxDecoration(borderRadius: borderRadius, boxShadow: surface.shadows),
      child: box,
    );
  }
}

/// Puts [child] in the [BackdropGroup] what a surface holds reads the backdrop
/// in: one of its own while [paints], and the one around it otherwise.
///
/// A [PlassSurfaceBox] and a `PlButton` put what they hold in one, and so does
/// every fill painted without them: a row's wash, a table's header band, a
/// window's body. A surface that paints anything hands what it holds a group of
/// its own, for the reason [PlassSurfaceBox] gives. A surface that paints
/// nothing passes the group above it straight through, so a ghost container
/// changes nothing about what its contents share with the rest of the page.
/// Pass it the fill's own test rather than `true` wherever the fill comes and
/// goes, so an unpainted row leaves what it holds in the group around it.
///
/// The group is in the tree either way, and only its key changes. A ghost
/// control paints a wash only while it is hovered, pressed or focused, and a
/// group that came and went with the wash would change the shape of the tree
/// above what the control holds, which Flutter builds again from scratch: a
/// ghost field would lose its editor, and the focus with it, the moment it was
/// focused. With no group above to pass through, the group's own key stands in,
/// so what an unpainted surface holds on a page with no group shares one read,
/// as it does on a painted one.
class PlassContentsGroup extends StatefulWidget {
  /// Puts [child] in a group of its own while [paints].
  const PlassContentsGroup({required this.paints, required this.child, super.key});

  /// Whether a fill is painted behind [child].
  final bool paints;

  /// What is drawn on the fill.
  final Widget child;

  @override
  State<PlassContentsGroup> createState() => _PlassContentsGroupState();
}

class _PlassContentsGroupState extends State<PlassContentsGroup> {
  /// Held for the life of the group rather than made in `build`: a group whose
  /// key changes tells every filter under it to rebuild, and hands the engine a
  /// backdrop it has not seen before on every frame.
  final BackdropKey _own = BackdropKey();

  @override
  Widget build(BuildContext context) {
    return BackdropGroup(
      backdropKey: widget.paints ? _own : BackdropGroup.of(context)?.backdropKey ?? _own,
      child: widget.child,
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

/// A mark that **is** the thing being coloured, and is never pressed — an
/// avatar, a badge.
///
/// Between [controlSurface] and [sheetSurface], and it needs to be: the sheet
/// takes the tint the way a control's does, because a portrait of one person and
/// a count of one thing are both about the thing they are coloured for. But
/// there is no pointer to answer, so there is no hover ladder, and the edge is
/// the neutral hairline rather than the sheet's own white one — a mark is very
/// often laid on something opaque, where white light on a cut edge is a claim
/// about a page wash that is not behind it.
///
/// `ghost` keeps a wash at rest rather than being bare, which is the difference
/// between a mark and a control: a ghost button has nothing until the pointer
/// arrives, and a ghost badge with nothing in it is not a badge.
PlassSurface markSurface(
  PlassTokens tokens,
  PlassColorFamily family, {
  required PlassVariant variant,
  required int elevation,
  bool lifted = true,
}) {
  switch (variant) {
    case PlassVariant.solid:
      return PlassSurface(
        gradient: family.fill,
        ink: family.onSolid,
        shadows: <BoxShadow>[...tokens.elevation(elevation), if (lifted) tokens.lift(family)],
      );
    case PlassVariant.glass:
      return PlassSurface(
        fill: tokens.glass,
        border: Border.all(color: tokens.border, width: hairline),
        insets: <PlassInsetShadow>[tokens.glossGlass],
        ink: family.accent,
        blur: true,
        shadows: tokens.elevation(elevation),
      );
    case PlassVariant.ghost:
      return PlassSurface(
        fill: family.softPress,
        ink: family.accent,
        shadows: tokens.elevation(elevation),
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
/// a field, a sheet — and leaves the brightness alone. It says what the surface
/// is rather than what state it is in, so a caller passes the same value on
/// every build.
///
/// The tree this returns has one shape whatever the state, and only its
/// settings change. A filter or an opacity that came and went with `disabled`,
/// `readOnly`, a hover or a press would change the shape of the tree above the
/// content, and Flutter builds a changed shape from scratch: what the surface
/// holds would be built again, and a field in it would lose what was typed.
///
/// [reduceMotion] is whether the platform has asked for less movement, which
/// puts the brightness on at once. `null` asks the platform where the filter is
/// built, as a [PlassSurfaceBox] does.
Widget plassStateFilter({
  required Widget child,
  bool disabled = false,
  bool readOnly = false,
  bool hovered = false,
  bool pressed = false,
  bool? reduceMotion,
  bool lit = true,
}) {
  final saturation = disabled
      ? disabledSaturation
      : readOnly
      ? readOnlySaturation
      : null;
  final drained = saturation == null ? null : saturationFilter(saturation);
  final opacity = disabled ? disabledOpacity : 1.0;

  if (!lit) {
    return PlassFiltered(colorFilter: drained, opacity: opacity, child: child);
  }

  // A drained surface does not answer the pointer, so its brightness settles
  // back to 1 underneath the saturation, ready for when it is available again.
  final brightness = drained != null
      ? 1.0
      : pressed
      ? pressBrightness
      : hovered
      ? hoverBrightness
      : 1.0;

  return _Lit(
    brightness: brightness,
    drained: drained,
    opacity: opacity,
    reduceMotion: reduceMotion,
    child: child,
  );
}

/// The brightness a lit surface answers the pointer with, eased over the
/// theme's duration and curve, or [drained] in its place while the surface is
/// unavailable.
///
/// A widget of its own rather than a builder in [plassStateFilter], because
/// that is a function with no context to read the theme from, and a widget in
/// its place reads it where it is built.
class _Lit extends StatelessWidget {
  const _Lit({
    required this.brightness,
    required this.drained,
    required this.opacity,
    required this.reduceMotion,
    required this.child,
  });

  final double brightness;
  final ColorFilter? drained;
  final double opacity;
  final bool? reduceMotion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final still = reduceMotion ?? MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: brightness),
      duration: still ? Duration.zero : tokens.motionDuration,
      curve: tokens.motionEase,
      child: child,
      // In the tree at rest and while drained too, with only its settings
      // changing, for the reason `plassStateFilter` gives.
      builder: (BuildContext context, double value, Widget? child) {
        return PlassFiltered(
          colorFilter: drained ?? (value == 1 ? null : brightnessFilter(value)),
          opacity: opacity,
          child: child,
        );
      },
    );
  }
}

/// Paints [child] through [colorFilter] and at [opacity], and straight onto the
/// canvas when there is neither to apply.
///
/// A [ColorFiltered] adds a layer whatever its filter is, the identity
/// included, and an [Opacity] adds one at an opacity of 1, so a control that
/// kept either in the tree while available would carry a layer for nothing.
/// Taking them out is worse, because that changes the shape of the tree above
/// what the control holds, which Flutter builds again from scratch. This keeps
/// the shape and adds a layer only for what there is to apply.
///
/// At an opacity of 0 it paints nothing at all, as an [Opacity] does, rather
/// than a layer that shows none of what is in it. What it holds is still laid
/// out, still hit and still read out, as CSS `opacity: 0` leaves an element,
/// unless [alwaysIncludeSemantics] says otherwise.
class PlassFiltered extends SingleChildRenderObjectWidget {
  /// Paints [child] through [colorFilter] and at [opacity].
  const PlassFiltered({
    required this.colorFilter,
    this.opacity = 1,
    this.alwaysIncludeSemantics = true,
    super.child,
    super.key,
  }) : assert(opacity >= 0 && opacity <= 1);

  /// The filter, or `null` to paint [child] in its own colours.
  final ColorFilter? colorFilter;

  /// How opaque [child] is, from 0 to 1. Applied after [colorFilter], as CSS
  /// applies `opacity` after `filter`.
  final double opacity;

  /// Whether [child] is still read out at an opacity of 0.
  ///
  /// `false` leaves it out of the semantics while it paints nothing, which is
  /// what an [Opacity] does by default, for a widget that took the place of
  /// one and has to keep the reading it gave.
  final bool alwaysIncludeSemantics;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderFiltered(
      colorFilter: colorFilter,
      opacity: opacity,
      alwaysIncludeSemantics: alwaysIncludeSemantics,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderFiltered)
      ..colorFilter = colorFilter
      ..opacity = opacity
      ..alwaysIncludeSemantics = alwaysIncludeSemantics;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ColorFilter>('colorFilter', colorFilter, defaultValue: null))
      ..add(DoubleProperty('opacity', opacity, defaultValue: 1.0))
      ..add(
        FlagProperty(
          'alwaysIncludeSemantics',
          value: alwaysIncludeSemantics,
          ifFalse: 'left out of the semantics at 0',
        ),
      );
  }
}

class _RenderFiltered extends RenderProxyBox {
  _RenderFiltered({
    required ColorFilter? colorFilter,
    required double opacity,
    required bool alwaysIncludeSemantics,
  }) : _colorFilter = colorFilter,
       _alpha = ui.Color.getAlphaFromOpacity(opacity),
       _alwaysIncludeSemantics = alwaysIncludeSemantics;

  ColorFilter? _colorFilter;

  int _alpha;

  bool _alwaysIncludeSemantics;

  /// The filter's layer while it sits inside the opacity's, which is then the
  /// one in [layer].
  final LayerHandle<ColorFilterLayer> _filterLayer = LayerHandle<ColorFilterLayer>();

  set colorFilter(ColorFilter? value) {
    if (value != _colorFilter) {
      _change(() => _colorFilter = value);
    }
  }

  set opacity(double value) {
    final alpha = ui.Color.getAlphaFromOpacity(value);

    if (alpha != _alpha) {
      final bool wasShown = _alpha != 0;

      _change(() => _alpha = alpha);

      if (wasShown != (_alpha != 0) && !_alwaysIncludeSemantics) {
        markNeedsSemanticsUpdate();
      }
    }
  }

  set alwaysIncludeSemantics(bool value) {
    if (value != _alwaysIncludeSemantics) {
      _alwaysIncludeSemantics = value;
      markNeedsSemanticsUpdate();
    }
  }

  void _change(VoidCallback change) {
    final bool composited = alwaysNeedsCompositing;
    change();

    if (composited != alwaysNeedsCompositing) {
      markNeedsCompositingBitsUpdate();
    }

    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing {
    return child != null && _alpha != 0 && (_colorFilter != null || _alpha != 255);
  }

  @override
  bool paintsChild(RenderBox child) => _alpha != 0;

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    final RenderBox? held = child;

    if (held != null && (_alpha != 0 || _alwaysIncludeSemantics)) {
      visitor(held);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final ContainerLayer? old = layer;

    if (child == null || _alpha == 0) {
      layer = null;
      _filterLayer.layer = null;

      return;
    }

    if (_alpha == 255) {
      _filterLayer.layer = null;
      layer = _paintFiltered(context, offset, old is ColorFilterLayer ? old : null);

      return;
    }

    layer = context.pushOpacity(offset, _alpha, (PaintingContext context, Offset offset) {
      _filterLayer.layer = _paintFiltered(context, offset, _filterLayer.layer);
    }, oldLayer: old is OpacityLayer ? old : null);
  }

  /// Paints the child through the filter, and returns the layer that took, or
  /// `null` when there is no filter and the child went straight onto the
  /// canvas.
  ColorFilterLayer? _paintFiltered(
    PaintingContext context,
    Offset offset,
    ColorFilterLayer? oldLayer,
  ) {
    final ColorFilter? filter = _colorFilter;

    if (filter == null) {
      super.paint(context, offset);

      return null;
    }

    return context.pushColorFilter(offset, filter, super.paint, oldLayer: oldLayer);
  }

  @override
  void dispose() {
    _filterLayer.layer = null;
    super.dispose();
  }
}
