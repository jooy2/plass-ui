/// A button that stays down.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/button_group.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/internal/toggle_group.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// A button that stays down.
///
/// ```dart
/// PlToggle(
///   pressed: bold,
///   onPressedChanged: (bool next) => setState(() => bold = next),
///   child: const Text('Bold'),
/// )
/// ```
///
/// The difference from a [PlSwitch] is what the press *is*: a switch changes a
/// setting and the change is the point; a toggle changes the state of the thing
/// beside it — bold on the selected words, the grid on the canvas, the filter on
/// the list. The difference from a [PlCheckbox] is that this one is a control
/// rather than an answer, so it never goes in a form.
///
/// **Off is neutral**, and that is the whole difference from a [PlButton]: a
/// button at rest is an action waiting to be taken, and a toggle at rest is a
/// state that is currently *false*. Accent ink on an unpressed toggle would say
/// it was on.
///
/// The elevation does **not** move with the state. On and off sit at the same
/// height and only the colour changes, because "on" is a fact about the thing
/// beside the toggle rather than about how far the key is off the screen.
class PlToggle extends StatefulWidget {
  /// Creates a toggle.
  ///
  /// The five style axes and [disabled] are nullable, and `null` is not a
  /// value: it means *this toggle did not say*, so a [PlToggleGroup] or a
  /// [PlButtonGroup] above it answers, and failing that the default named on
  /// each field does.
  const PlToggle({
    this.child,
    this.pressed,
    this.defaultPressed = false,
    this.onPressedChanged,
    this.value,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.startIcon,
    this.endIcon,
    this.fullWidth = false,
    this.disabled,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// The label. Left out, the toggle goes square around whatever icon it was
  /// given — which is what a toolbar toggle is, and which still needs a
  /// [semanticLabel].
  final Widget? child;

  /// Whether it is on. Passing it makes the toggle controlled.
  final bool? pressed;

  /// Whether it starts on, for an uncontrolled one.
  final bool defaultPressed;

  /// Called when it goes on or off.
  final ValueChanged<bool>? onPressedChanged;

  /// Identifies the toggle inside a [PlToggleGroup].
  final String? value;

  /// What the key is made of while it is **off**. On is always the colour
  /// family asserting itself, whichever material was asked for.
  final PlassVariant? variant;

  /// The control ladder, unchanged: a `md` toggle is 40 and lines up with the
  /// field and the button beside it.
  final PlassSize? size;

  /// Semantic colour role. It arrives with the press and not before it.
  final PlassColor? color;

  /// Changes the padding and nothing else.
  final PlassDensity? density;

  /// Drop shadow depth, `0`–`3`.
  ///
  /// `0` by default and one below a [PlButton]'s: a toggle is a state rather
  /// than an action, and a state does not float off the screen waiting to be
  /// taken.
  final PlassElevation? elevation;

  /// Content placed before the label, sized against it.
  final Widget? startIcon;

  /// Content placed after the label.
  final Widget? endIcon;

  /// Stretches to the width of what is around it.
  final bool fullWidth;

  /// Makes it unpressable and takes it out of the focus order.
  final bool? disabled;

  /// The name a screen reader gives it.
  ///
  /// Required in practice on a toggle with an icon and no label, which has no
  /// accessible name otherwise.
  final String? semanticLabel;

  /// An external focus node, for a caller that has to move focus here itself.
  final FocusNode? focusNode;

  /// Whether it takes focus when it is first built.
  final bool autofocus;

  @override
  State<PlToggle> createState() => _PlToggleState();
}

class _PlToggleState extends State<PlToggle> {
  late bool _ownPressed = widget.defaultPressed;

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);
    final PlassButtonGroupScope? group = PlassButtonGroupScope.maybeOf(context);
    final PlassToggleGroupScope? set = PlassToggleGroupScope.maybeOf(context);

    final PlassVariant variant = widget.variant ?? group?.variant ?? PlassVariant.glass;
    final PlassSize size = widget.size ?? group?.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final PlassColor color =
        widget.color ?? group?.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
    final PlassDensity density =
        widget.density ?? group?.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;
    final PlassElevation elevation = widget.elevation ?? group?.elevation ?? 0;
    final bool disabled = widget.disabled ?? group?.disabled ?? false;

    final String? value = widget.value;
    final bool inSet = set != null && value != null;
    final bool on = inSet ? set.value.contains(value) : widget.pressed ?? _ownPressed;

    void activate() {
      final bool next = !on;

      if (inSet) {
        set.onToggle(value);
      } else if (widget.pressed == null) {
        setState(() => _ownPressed = next);
      }

      widget.onPressedChanged?.call(next);
    }

    final PlassColorFamily family = tokens.family(color);
    final bool reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final TextDirection direction = Directionality.maybeOf(context) ?? TextDirection.ltr;
    final double height = controlHeight[size]!;
    final double fontSize = controlText[size]!;
    final double step = PlassTokens.radius[size]!;
    final BorderRadius radius = group?.corners(step, direction) ?? BorderRadius.circular(step);
    final bool iconOnly = widget.child == null;

    BoxBorder edge(Color colour) {
      final BorderSide side = BorderSide(color: colour, width: hairline);

      return group?.border(side, direction) ?? Border.fromBorderSide(side);
    }

    Widget shell(PlassInteraction state) {
      final bool hovered = !disabled && state.hovered;
      final bool pressed = !disabled && state.pressed;

      final PlassSurface surface = disabled
          ? controlSurface(tokens, family, variant: variant, elevation: elevation, disabled: true)
          : on
          ? _on(
              tokens,
              family,
              variant: variant,
              elevation: elevation,
              hovered: hovered,
              pressed: pressed,
              edge: edge,
            )
          : _off(
              tokens,
              family,
              variant: variant,
              elevation: elevation,
              hovered: hovered,
              pressed: pressed,
              edge: edge,
            );

      Widget content = DefaultTextStyle.merge(
        style: TextStyle(
          color: surface.ink,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          height: 1,
          leadingDistribution: TextLeadingDistribution.even,
        ),
        maxLines: 1,
        softWrap: false,
        textAlign: TextAlign.center,
        child: IconTheme.merge(
          data: IconThemeData(color: surface.ink, size: fontSize * iconScale),
          child: Row(
            mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: gap[size]!,
            children: <Widget>[?widget.startIcon, ?widget.child, ?widget.endIcon],
          ),
        ),
      );

      content = Padding(
        padding: EdgeInsets.symmetric(horizontal: iconOnly ? 0 : paddingX[density]![size]!),
        child: content,
      );

      Widget toggle = SizedBox(
        height: height,
        width: widget.fullWidth
            ? double.infinity
            : iconOnly
            ? height
            : null,
        child: PlassSurfaceBox(
          surface: surface,
          borderRadius: radius,
          pointer: state.pointer,
          // The interaction light is on every variant, because it is about
          // where the pointer is rather than about what the surface is made of.
          glow: disabled ? null : tokens.glow(family, variant),
          glowVisible: hovered,
          flash: disabled ? null : tokens.flash(family, variant),
          flashVisible: pressed,
          reduceMotion: reduceMotion,
          child: content,
        ),
      );

      toggle = plassStateFilter(
        child: toggle,
        disabled: disabled,
        hovered: hovered,
        pressed: pressed,
        reduceMotion: reduceMotion,
      );

      if (state.focusVisible) {
        toggle = CustomPaint(
          foregroundPainter: PlassFocusRingPainter(color: family.ring, borderRadius: radius),
          child: toggle,
        );
      }

      return toggle;
    }

    return MergeSemantics(
      child: Semantics(
        button: true,
        toggled: on,
        enabled: !disabled,
        label: widget.semanticLabel,
        onTap: disabled ? null : activate,
        child: PlassInteractive(
          enabled: !disabled,
          // `enabled` decides whether it can be focused; `interactive` decides
          // whether it answers at all. A disabled toggle does neither.
          interactive: !disabled,
          cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
          onTap: activate,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          builder: (BuildContext context, PlassInteraction state) => shell(state),
        ),
      ),
    );
  }
}

/// Off.
///
/// The ink is the muted foreground in all three and none of them is dyed: an
/// off toggle is a piece of clear glass, and the family arrives with the press.
PlassSurface _off(
  PlassTokens tokens,
  PlassColorFamily family, {
  required PlassVariant variant,
  required int elevation,
  required bool hovered,
  required bool pressed,
  required BoxBorder Function(Color colour) edge,
}) {
  final Color ink = hovered || pressed ? tokens.fg : tokens.mutedFg;
  final List<BoxShadow> shadows = tokens.elevation(
    pressed
        ? elevation - 1
        : hovered
        ? elevation + 1
        : elevation,
  );

  switch (variant) {
    case PlassVariant.solid:
      return PlassSurface(
        fill: hovered || pressed ? tokens.glassPress : tokens.glassHover,
        ink: ink,
        blur: true,
        insets: <PlassInsetShadow>[tokens.glossGlass],
        shadows: shadows,
      );
    case PlassVariant.glass:
      return PlassSurface(
        fill: pressed
            ? tokens.glassPress
            : hovered
            ? tokens.glassHover
            : tokens.glass,
        border: edge(hovered || pressed ? family.line : tokens.glassLine),
        ink: ink,
        blur: true,
        insets: <PlassInsetShadow>[tokens.glossGlass],
        shadows: shadows,
      );
    case PlassVariant.ghost:
      return PlassSurface(
        fill: pressed
            ? family.softHover
            : hovered
            ? family.soft
            : null,
        ink: ink,
      );
  }
}

/// On.
///
/// The same two answers the chosen segment of a [PlSegmentedButton] gives:
/// `solid` takes the family's gradient and the on-fill ink, the other two light
/// the sheet and leave the label in the accent.
PlassSurface _on(
  PlassTokens tokens,
  PlassColorFamily family, {
  required PlassVariant variant,
  required int elevation,
  required bool hovered,
  required bool pressed,
  required BoxBorder Function(Color colour) edge,
}) {
  final int level = pressed
      ? elevation - 1
      : hovered
      ? elevation + 1
      : elevation;

  final Color wash = pressed
      ? family.softPress
      : hovered
      ? family.softHover
      : family.soft;

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
        fill: wash,
        border: edge(family.lineHover),
        ink: family.accent,
        blur: true,
        insets: <PlassInsetShadow>[tokens.glossGlass],
        shadows: tokens.elevation(level),
      );
    case PlassVariant.ghost:
      return PlassSurface(fill: wash, ink: family.accent);
  }
}
