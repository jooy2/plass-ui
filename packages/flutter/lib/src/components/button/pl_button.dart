/// A control that runs an action.
library;

import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/button_group.dart';
import 'package:plass_ui/src/internal/css.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/glow.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// A control that runs an action.
///
/// Use it for anything the user deliberately triggers — submitting a form,
/// saving, deleting.
///
/// ```dart
/// PlButton(onPressed: save, child: const Text('Save'))
/// ```
///
/// The three [PlassVariant]s are three materials. `solid` is a pane of tinted
/// glass and the primary action; `glass` is a clear sheet with a hairline, for
/// secondary actions; `ghost` has no surface until the pointer is on it, for a
/// toolbar or a row. Keep one `solid` per screen.
///
/// All three carry the interaction light: a soft bloom that follows the pointer
/// across the control, and a brighter flash on press that drains over about
/// 700ms. On a touch screen it follows a finger dragged across the button.
class PlButton extends StatefulWidget {
  /// Creates a button.
  ///
  /// [elevation] is a rung on a four-step ladder; anything outside `0..3` is a
  /// mistake rather than a clamp, so it asserts.
  ///
  /// The five style axes and [disabled] are nullable, and `null` is not a
  /// value: it means *this button did not say*, so a [PlButtonGroup] above it
  /// answers, and failing that the default named on each field does. A button
  /// that states one itself always wins.
  const PlButton({
    this.child,
    this.onPressed,
    this.onLongPress,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.startIcon,
    this.endIcon,
    this.loading = false,
    this.readOnly = false,
    this.fullWidth = false,
    this.disabled,
    this.borderRadius,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    super.key,
  }) : assert(
         elevation == null || (elevation >= plassElevationMin && elevation <= plassElevationMax),
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The label. Omit it and the button goes square for an icon — and then it
  /// needs a [semanticLabel].
  final Widget? child;

  /// Called when the button is activated, by pointer or by keyboard.
  ///
  /// Leaving it `null` disables the button, as it does everywhere else in
  /// Flutter. [disabled] says the same thing explicitly, for a button whose
  /// callback is still wired up.
  final VoidCallback? onPressed;

  /// Called on a long press — the touch equivalent of a context menu.
  final VoidCallback? onLongPress;

  /// What the surface is made of. See [PlassVariant].
  ///
  /// Defaults to [PlassVariant.solid], or to the [PlButtonGroup] above it.
  final PlassVariant? variant;

  /// Height and type scale together: `xs` 24 · `sm` 32 · `md` 40 · `lg` 48 ·
  /// `xl` 56. `md` is the desktop default, and `lg` and `xl` both clear the
  /// 44px mobile touch target.
  ///
  /// Defaults to [PlassSize.md], or to the [PlButtonGroup] above it.
  final PlassSize? size;

  /// Semantic colour role. Six only; arbitrary colours are not accepted.
  ///
  /// On `solid` the family is the gradient and the shadow under it; on `glass`
  /// and `ghost` it is the label — which is why a `glass` button with
  /// [PlassColor.secondary] is the quiet neutral button rather than a fourth
  /// variant.
  ///
  /// Defaults to [PlassColor.primary], or to the [PlButtonGroup] above it.
  final PlassColor? color;

  /// Changes horizontal padding and nothing else. Two buttons of the same
  /// [size] are the same height whatever their density, so a mixed row keeps
  /// its baseline.
  ///
  /// Defaults to [PlassDensity.standard], or to the [PlButtonGroup] above it.
  final PlassDensity? density;

  /// Drop shadow depth, `0`–`3`.
  ///
  /// `1` is the default, because a moulded key **rests on** the sheet rather
  /// than lying flush with it. Hover adds a level and pressing removes one,
  /// which is what puts the key down against the glass under the finger.
  ///
  /// The tinted shadow a `solid` button casts in its own colour is **not** part
  /// of this ladder and does not scale with it.
  ///
  /// Defaults to `1`, or to the [PlButtonGroup] above it.
  final PlassElevation? elevation;

  /// Drawn before the label, at 1.2× the label's size — so it tracks the label
  /// and never needs a size of its own. An [Icon] picks that up from the
  /// surrounding [IconTheme]; anything else should size itself.
  final Widget? startIcon;

  /// Drawn after the label. See [startIcon].
  final Widget? endIcon;

  /// Shows a spinner in place of [startIcon] and stops the button from
  /// activating, while keeping it focusable and visually unchanged otherwise.
  final bool loading;

  /// Inert but not dimmed — the action exists, it just is not available here.
  ///
  /// Keeps its colour, goes flat and drains most of its saturation. Unlike
  /// [disabled] it stays in the focus order: dropping out of it costs keyboard
  /// users their sense of the page.
  final bool readOnly;

  /// Stretches to the width of the container.
  final bool fullWidth;

  /// Unavailable. Loses its light and its shadow, lets the page through, and
  /// leaves the focus order.
  ///
  /// Defaults to `false`, or to the [PlButtonGroup] above it — which is what
  /// lets a whole run be turned off at once.
  final bool? disabled;

  /// The corners, overriding the [size] step of the house radius ladder.
  ///
  /// The one escape hatch on this widget, and it exists for [PlIconButton]: the
  /// React build reaches the same place through an inline `style`, which is a
  /// door Flutter does not have. Nothing else in the library should reach for
  /// it — the fillet is the fillet, and a button with corners of its own is a
  /// button that has stopped matching the field beside it.
  final BorderRadius? borderRadius;

  /// Drive focus from outside. Left out, the button owns one of its own.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  /// The name a screen reader announces. Required on an icon-only button, where
  /// there is no label to read.
  final String? semanticLabel;

  @override
  State<PlButton> createState() => _PlButtonState();
}

class _PlButtonState extends State<PlButton> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focusVisible = false;
  Offset? _pointer;

  /// The run this button is in, or `null`. Read here rather than in `build`
  /// because the resolved values below are wanted by the gesture callbacks too,
  /// and a callback has no build context to ask with.
  PlassButtonGroupScope? _group;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _group = PlassButtonGroupScope.maybeOf(context);
  }

  /* The six axes a group may answer for. `null` on the widget is "this button
     did not say", so the group is asked next and the house default last. */

  PlassVariant get _variant => widget.variant ?? _group?.variant ?? PlassVariant.solid;

  PlassSize get _size => widget.size ?? _group?.size ?? PlassSize.md;

  PlassColor get _color => widget.color ?? _group?.color ?? PlassColor.primary;

  PlassDensity get _density => widget.density ?? _group?.density ?? PlassDensity.standard;

  PlassElevation get _elevation => widget.elevation ?? _group?.elevation ?? 1;

  /// `loading` and `readOnly` stop the button firing without changing whether
  /// it can be reached; `disabled` does both.
  bool get _inert => widget.loading || widget.readOnly;

  bool get _disabled => (widget.disabled ?? _group?.disabled ?? false) || widget.onPressed == null;

  bool get _interactive => !_disabled && !_inert;

  void _setPointer(Offset position) {
    // Written on every pointer frame, so it is deliberately not `setState` for
    // its own sake — but the gradient has to be rebuilt to move, and a
    // `RepaintBoundary` around the light keeps that repaint off the label.
    //
    // It runs while a finger is down too, which is what makes the light follow
    // a drag on a touch screen: there is no hover there, and the press layer is
    // the one doing the work.
    if (_pointer != position) {
      setState(() => _pointer = position);
    }
  }

  void _activate() {
    if (_interactive) {
      widget.onPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(_color);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final height = controlHeight[_size]!;
    final fontSize = controlText[_size]!;
    final iconOnly = widget.child == null;
    final glyph = fontSize * iconScale;

    final direction = Directionality.maybeOf(context) ?? TextDirection.ltr;
    final group = _group;
    final step = PlassTokens.radius[_size]!;

    /* The corners that face a neighbour are squared off. `borderRadius` still
       wins, which is what keeps a `PlIconButton` a disc inside a run — the same
       thing its inline `border-radius` does in the React build. */
    final radius =
        widget.borderRadius ?? group?.corners(step, direction) ?? BorderRadius.circular(step);

    /// A hairline, with the sides that face a neighbour dropped so a seam is
    /// one line rather than two. See `internal/button_group.dart`.
    BoxBorder edge(Color color) {
      final side = BorderSide(color: color, width: hairline);

      return group?.border(side, direction) ?? Border.fromBorderSide(side);
    }

    // Hover and press only *look* like anything while the button can be used.
    final hovered = _interactive && _hovered;
    final pressed = _interactive && _pressed;

    final glass = _variant == PlassVariant.glass;

    /* -----------------------------------------------------------------------
     * The surface
     *
     * Written as an if/else ladder rather than as layered state modifiers,
     * because `disabled`, `readOnly` and the resting states are three different
     * surfaces rather than three adjustments to one — and a ladder is the one
     * shape where that cannot be got subtly wrong.
     * -------------------------------------------------------------------- */

    Color? fill;
    Gradient? gradient;
    BoxBorder? border;
    Color ink;
    List<BoxShadow> shadows = const <BoxShadow>[];
    PlassInsetShadow? gloss;

    if (_disabled) {
      switch (_variant) {
        case PlassVariant.solid:
          gradient = family.fill;
          ink = family.onSolid;
        case PlassVariant.glass:
          fill = tokens.glass;
          border = edge(tokens.border);
          // The neutral foreground, not the family's: a disabled control has
          // stopped being a `danger` button and become a shape.
          ink = tokens.fg;
        case PlassVariant.ghost:
          ink = family.accent;
      }
    } else if (widget.readOnly) {
      switch (_variant) {
        case PlassVariant.solid:
          gradient = family.fill;
          ink = family.onSolid;
        case PlassVariant.glass:
          fill = tokens.glass;
          border = edge(tokens.glassLine);
          gloss = tokens.glossGlass;
          ink = family.accent;
        case PlassVariant.ghost:
          ink = family.accent;
      }
    } else {
      final level = pressed
          ? _elevation - 1
          : hovered
          ? _elevation + 1
          : _elevation;

      switch (_variant) {
        case PlassVariant.solid:
          gradient = family.fill;
          ink = family.onSolid;
          shadows = <BoxShadow>[
            ...tokens.elevation(level),
            if (pressed)
              tokens.liftPress(family)
            else if (hovered)
              tokens.liftHover(family)
            else
              tokens.lift(family),
          ];
        case PlassVariant.glass:
          fill = pressed
              ? tokens.glassPress
              : hovered
              ? tokens.glassHover
              : tokens.glass;
          border = edge(hovered || pressed ? family.line : tokens.glassLine);
          gloss = tokens.glossGlass;
          ink = family.accent;
          shadows = tokens.elevation(level);
        case PlassVariant.ghost:
          // Nothing to catch the light on, and nothing to cast a shadow.
          fill = pressed
              ? family.softHover
              : hovered
              ? family.soft
              : null;
          ink = family.accent;
      }
    }

    /* -----------------------------------------------------------------------
     * The layers
     * -------------------------------------------------------------------- */

    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: iconOnly ? 0 : paddingX[_density]![_size]!),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: ink,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          // `leading-none`: the label is one line, so the line box is the type
          // size and the button's own height does the centring.
          height: 1,
          // Which is only true with the leading split evenly. Flutter's default
          // hands the (here negative) leading out in proportion to the font's
          // ascent and descent, which pushes every label up by two or three
          // pixels — visible on a 24px control and wrong on all of them. CSS
          // splits it in half, and so does this.
          leadingDistribution: TextLeadingDistribution.even,
        ),
        maxLines: 1,
        softWrap: false,
        textAlign: TextAlign.center,
        child: IconTheme.merge(
          data: IconThemeData(color: ink, size: glyph),
          child: Row(
            mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: _slots(glyph: glyph, ink: ink),
          ),
        ),
      ),
    );

    Widget surface = Stack(
      // The label is the one child that sizes the stack, and a stack aligns to
      // its top-left unless told otherwise — which puts every label against the
      // top edge of the control it names.
      alignment: Alignment.center,
      children: <Widget>[
        if (glass)
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
            duration: reduceMotion ? Duration.zero : PlassTokens.duration,
            curve: PlassTokens.ease,
            decoration: BoxDecoration(
              borderRadius: radius,
              color: fill,
              gradient: gradient,
              border: border,
            ),
          ),
        ),
        if (gloss != null)
          Positioned.fill(
            child: CustomPaint(
              painter: PlassInsetShadowPainter(
                shadows: <PlassInsetShadow>[gloss],
                borderRadius: radius,
              ),
            ),
          ),
        // The bloom sits under the label and the flash sits over it, which is
        // where `::before` and `::after` sit in the stylesheet.
        if (_interactive)
          Positioned.fill(
            child: RepaintBoundary(
              child: PlassGlowLayer(
                pointer: _pointer,
                visible: hovered,
                color: tokens.glow(family, _variant),
                radius: glowRadius,
                duration: PlassTokens.glowDuration,
                reduceMotion: reduceMotion,
              ),
            ),
          ),
        content,
        if (_interactive)
          Positioned.fill(
            child: RepaintBoundary(
              child: PlassGlowLayer(
                pointer: _pointer,
                visible: pressed,
                color: tokens.flash(family, _variant),
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

    surface = ClipRRect(borderRadius: radius, child: surface);

    // The drop shadows cannot be inside the clip that keeps the glass and the
    // light inside the corners, so they are the box around it.
    surface = AnimatedContainer(
      duration: reduceMotion ? Duration.zero : PlassTokens.duration,
      curve: PlassTokens.ease,
      decoration: BoxDecoration(borderRadius: radius, boxShadow: shadows),
      child: surface,
    );

    // Sized outside the animation, deliberately. The stylesheet transitions
    // colour, shadow and filter and nothing else — a button whose `size` changes
    // becomes a different size, it does not glide there, and a row of controls
    // re-laying itself out over 150ms is a row that looks broken.
    surface = SizedBox(
      height: height,
      width: widget.fullWidth
          ? double.infinity
          : iconOnly
          ? height
          : null,
      child: surface,
    );

    /* -----------------------------------------------------------------------
     * The filters
     *
     * CSS applies `opacity` and `filter` to the whole element — its fill, its
     * label and the shadow it casts — so both wrap everything above. The two
     * are mutually exclusive in practice: brightness is a resting state's
     * response to the pointer, saturation is what read-only and disabled drain.
     * -------------------------------------------------------------------- */

    final saturation = _disabled
        ? disabledSaturation
        : widget.readOnly
        ? readOnlySaturation
        : null;

    if (saturation != null) {
      surface = ColorFiltered(colorFilter: saturationFilter(saturation), child: surface);
    } else {
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

    if (_disabled) {
      surface = Opacity(opacity: disabledOpacity, child: surface);
    }

    if (_focusVisible) {
      surface = CustomPaint(
        foregroundPainter: PlassFocusRingPainter(color: family.ring, borderRadius: radius),
        child: surface,
      );
    }

    /* -----------------------------------------------------------------------
     * The behaviour
     * -------------------------------------------------------------------- */

    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: _interactive,
        label: widget.semanticLabel,
        onTap: _interactive ? _activate : null,
        onLongPress: _interactive ? widget.onLongPress : null,
        child: FocusableActionDetector(
          // `readOnly` and `loading` keep focus; only `disabled` gives it up.
          enabled: !_disabled,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          mouseCursor: _cursor,
          // The focus ring only appears on what CSS calls `:focus-visible` — a
          // keyboard reaching the control, never a mouse clicking it. This is
          // Flutter's name for the same distinction.
          //
          // Hover is deliberately *not* taken from this widget's own
          // `onShowHoverHighlight`, which is gated on the focus system's
          // highlight mode: whether the pointer is over the control is the
          // whole question, and the `MouseRegion` below answers exactly it. It
          // is also the right analogue of `@media (hover: hover)` — a
          // `MouseRegion` never fires for a finger.
          onShowFocusHighlight: (bool value) => setState(() => _focusVisible = value),
          // Declared rather than inherited, so a button works the same in a bare
          // `WidgetsApp`, inside somebody else's shortcut scope, or with no app
          // widget above it at all. The scope is this button, so nothing an app
          // binds elsewhere is shadowed.
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          },
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (ActivateIntent intent) {
                _activate();
                return null;
              },
            ),
            ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
              onInvoke: (ButtonActivateIntent intent) {
                _activate();
                return null;
              },
            ),
          },
          child: MouseRegion(
            onEnter: (PointerEnterEvent event) {
              _setPointer(event.localPosition);
              setState(() => _hovered = true);
            },
            onExit: (PointerExitEvent event) => setState(() => _hovered = false),
            onHover: (PointerHoverEvent event) => _setPointer(event.localPosition),
            child: Listener(
              onPointerDown: (PointerDownEvent event) => _setPointer(event.localPosition),
              onPointerMove: (PointerMoveEvent event) => _setPointer(event.localPosition),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                // Described by the `Semantics` above, which knows about
                // `readOnly` and `loading` and this does not.
                excludeFromSemantics: true,
                // Always present, even when nothing will happen: the recogniser
                // is what stops a tap on an unavailable button reaching whatever
                // is behind it. A row that navigates should not navigate because
                // someone tried the disabled button inside it.
                onTap: _activate,
                onLongPress: _interactive ? widget.onLongPress : null,
                onTapDown: (TapDownDetails details) => setState(() => _pressed = true),
                onTapUp: (TapUpDetails details) => setState(() => _pressed = false),
                onTapCancel: () => setState(() => _pressed = false),
                child: surface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  MouseCursor get _cursor {
    if (_disabled) {
      return SystemMouseCursors.forbidden;
    }

    if (widget.loading) {
      return SystemMouseCursors.progress;
    }

    if (widget.readOnly) {
      return SystemMouseCursors.basic;
    }

    return SystemMouseCursors.click;
  }

  /// The label and whatever flanks it, with the size's gap between them.
  List<Widget> _slots({required double glyph, required Color ink}) {
    final leading = widget.loading ? PlassSpinner(size: glyph, color: ink) : widget.startIcon;

    final parts = <Widget>[
      ?leading,
      if (widget.child != null) Flexible(child: widget.child!),
      ?widget.endIcon,
    ];

    if (parts.length < 2) {
      return parts;
    }

    final spacing = gap[_size]!;
    final spaced = <Widget>[parts.first];

    for (final part in parts.skip(1)) {
      spaced
        ..add(SizedBox(width: spacing))
        ..add(part);
    }

    return spaced;
  }
}
