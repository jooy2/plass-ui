/// A compact token: a tag, a filter, a status, an entity plucked out of a list.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/date.dart';
import 'package:plass_ui/src/internal/dismiss.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/internal/target.dart';
import 'package:plass_ui/src/internal/text.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// A chip sits one step down the control ladder from everything else: an `md`
/// chip is an `sm` control — 32px, not 40px.
///
/// This is the whole size difference between a chip and a button, and it is
/// deliberate. A chip is a token *inside* a row of content, not a control the
/// row lines up against; at full control height a `glass` chip and a `glass`
/// button are the same object, and a screen full of them says nothing about
/// which one can be pressed.
///
/// Shifting the index rather than inventing a second set of numbers keeps a chip
/// inside the same five-step vocabulary, and keeps `xs` from falling off the
/// bottom of it.
const Map<PlassSize, PlassSize> _chipScale = <PlassSize, PlassSize>{
  PlassSize.xs: PlassSize.xs,
  PlassSize.sm: PlassSize.xs,
  PlassSize.md: PlassSize.sm,
  PlassSize.lg: PlassSize.md,
  PlassSize.xl: PlassSize.lg,
};

/// How large the count plate's digits are, against the chip's own label.
const double _countScale = 0.85;

/// A compact token: a tag, a filter, a status, an entity plucked out of a list.
///
/// ```dart
/// PlChip(onPressed: toggle, selected: on, child: const Text('Unread'))
/// ```
///
/// The three materials say what they say everywhere else, said the way a
/// *control* says them: a chip **is** the thing being coloured — a tag names one
/// particular thing — so unlike a card its sheet takes the tint.
/// [PlassVariant.glass] is the default rather than `solid`, because a filter bar
/// is a row of chips and a row of gradient keys is a row in which nothing is the
/// primary action because everything is.
///
/// A chip that can be pressed and a chip that can be removed are two separate
/// focus stops, and neither is inside the other — which is the same shape the
/// React build reaches for, there because a `<button>` inside a `<button>` is
/// invalid and here because a nested [PlassInteractive] would take a tap twice.
class PlChip extends StatelessWidget {
  /// Creates a chip.
  const PlChip({
    this.child,
    this.onPressed,
    this.onDeleted,
    this.deleteLabel,
    this.variant = PlassVariant.glass,
    this.size,
    this.color,
    this.density,
    this.elevation = 0,
    this.startIcon,
    this.endIcon,
    this.count,
    this.selected = false,
    this.disabled = false,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The label.
  final Widget? child;

  /// Called when the chip is activated. Passing it is what makes the chip
  /// pressable — and gives it a focus stop of its own.
  final VoidCallback? onPressed;

  /// Called when the chip's delete affordance is pressed. Passing it is what
  /// makes the affordance appear.
  final VoidCallback? onDeleted;

  /// The name a screen reader gives the delete affordance. Never drawn.
  ///
  /// Left out, it is the label pack's [PlassLabels.removeItem] handed the chip's
  /// text when [child] is a [Text], so a row of tags does not read as the same
  /// "Remove" over and over, and each language puts the name where it goes. A
  /// chip whose child is some other widget is named by [PlassLabels.remove]
  /// alone, and is the one to give a [deleteLabel] that says which chip it
  /// removes. Given, it is the whole name.
  final String? deleteLabel;

  /// What the surface is made of. See [PlassVariant].
  final PlassVariant variant;

  /// The chip's own step of the ladder — one below a control's. See [_chipScale].
  final PlassSize? size;

  /// Semantic colour role.
  final PlassColor? color;

  /// Changes horizontal padding and nothing else.
  final PlassDensity? density;

  /// Drop shadow depth, `0`–`3`.
  ///
  /// `0` is the default — a chip is a token sitting *on* something else, so it
  /// is raised even less often than a button.
  final PlassElevation elevation;

  /// Drawn before the label — an icon, a status dot, an avatar.
  final Widget? startIcon;

  /// Drawn after the label, before any [count].
  final Widget? endIcon;

  /// A number set into the end of the chip.
  ///
  /// Drawn on its own small plate, so "Errors 12" reads as one token with a
  /// count rather than as two words.
  final Widget? count;

  /// Marks the chip as chosen — a filter that is on.
  ///
  /// It moves the chip one step up the ladder its own variant already sits on,
  /// rather than changing the colour family, so a row of chips stays one row of
  /// chips.
  final bool selected;

  /// Unavailable. The light goes out, the same way it does everywhere else.
  final bool disabled;

  /// Drive the pressable chip's focus from outside.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final color = this.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;

    final tokens = PlassTheme.of(context);
    final family = tokens.family(color);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final step = _chipScale[size]!;
    final height = controlHeight[step]!;
    final fontSize = controlText[step]!;
    final radius = BorderRadius.circular(PlassTokens.radius[step]!);
    final interactive = onPressed != null && !disabled;

    if (!interactive) {
      return _shell(
        context,
        tokens: tokens,
        family: family,
        step: step,
        height: height,
        fontSize: fontSize,
        radius: radius,
        reduceMotion: reduceMotion,
        state: const PlassInteraction(),
        focusVisible: false,
        padded: true,
      );
    }

    return PlassInteractive(
      onTap: onPressed,
      focusNode: focusNode,
      autofocus: autofocus,
      builder: (BuildContext context, PlassInteraction state) {
        return Semantics(
          container: true,
          button: true,
          selected: selected,
          enabled: true,
          onTap: onPressed,
          child: _shell(
            context,
            tokens: tokens,
            family: family,
            step: step,
            height: height,
            fontSize: fontSize,
            radius: radius,
            reduceMotion: reduceMotion,
            state: state,
            // The chip's own focus. A focus node counts a focused descendant
            // as focus, and the × inside the chip is a stop of its own that
            // draws its own ring.
            focusVisible: state.focusVisible && Focus.of(context).hasPrimaryFocus,
            padded: true,
          ),
        );
      },
    );
  }

  Widget _shell(
    BuildContext context, {
    required PlassTokens tokens,
    required PlassColorFamily family,
    required PlassSize step,
    required double height,
    required double fontSize,
    required BorderRadius radius,
    required bool reduceMotion,
    required PlassInteraction state,
    required bool focusVisible,
    required bool padded,
  }) {
    final density = this.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

    var surface = controlSurface(
      tokens,
      family,
      variant: variant,
      elevation: elevation,
      hovered: state.hovered,
      pressed: state.pressed,
      disabled: disabled,
    );

    // Chosen is one step further up the ladder the chip is already on — the
    // sheet holds more light. Deliberately not a different colour family: a
    // filter that is on is still the same filter.
    //
    // `solid` has no opacity ladder to climb, because a gradient fill is the
    // fill. So it answers the other way the design language allows: it casts its
    // own colour onto the sheet under it. A chosen key lifts; an unchosen one
    // lies flat.
    if (selected && !disabled) {
      switch (variant) {
        case PlassVariant.solid:
          surface = surface.withShadows(<BoxShadow>[
            ...tokens.elevation(elevation),
            tokens.lift(family),
          ]);
        case PlassVariant.glass:
          surface = PlassSurface(
            fill: tokens.glassPress,
            border: Border.all(color: family.lineHover, width: hairline),
            insets: surface.insets,
            ink: surface.ink,
            blur: true,
            shadows: surface.shadows,
          );
        case PlassVariant.ghost:
          surface = PlassSurface(fill: family.softPress, ink: surface.ink);
      }
    } else if (variant == PlassVariant.solid && !disabled) {
      // A chip is flat at rest. The tinted lift is what `selected` buys.
      surface = surface.withShadows(tokens.elevation(elevation));
    } else if (variant == PlassVariant.ghost && !disabled && !state.hovered && !state.pressed) {
      // A ghost chip is not a ghost button: it is a token and it has a wash at
      // rest, which is what makes a row of them read as a row of tokens.
      surface = PlassSurface(fill: family.soft, ink: surface.ink);
    }

    final padX = paddingX[density]![step]!;
    final spacing = gap[step]!;

    Widget body = DefaultTextStyle.merge(
      style: TextStyle(
        color: surface.ink,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        height: 1,
        leadingDistribution: TextLeadingDistribution.even,
      ),
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      child: IconTheme.merge(
        data: IconThemeData(color: surface.ink, size: fontSize * iconScale),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: spacing,
          children: <Widget>[
            ?startIcon,
            if (child != null) Flexible(child: child!),
            ?endIcon,
            if (count != null) _countPlate(context, tokens, family, fontSize: fontSize),
          ],
        ),
      ),
    );

    body = Padding(
      padding: EdgeInsets.symmetric(horizontal: padX),
      child: body,
    );

    if (onDeleted != null) {
      final PlassLabels labels = PlassTheme.labelsOf(context);
      final String? text = plassTextOf(child);

      body = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(child: body),
          // The delete button brings its own padding; the chip's would leave the
          // × floating in the middle of a gap.
          Padding(
            padding: EdgeInsetsDirectional.only(end: padX / 2),
            // Drawn at the size of the label, and pressed from a 24px square
            // through the scope round the whole chip.
            child: PlassTarget(
              child: PlassDismissButton(
                label: deleteLabel ?? (text == null ? labels.remove : labels.removeItem(text)),
                onPressed: disabled ? null : onDeleted,
                size: fontSize * dismissScale,
                color: surface.ink,
                ring: family.ring,
              ),
            ),
          ),
        ],
      );
    }

    Widget chip = SizedBox(
      height: height,
      child: PlassSurfaceBox(
        surface: surface,
        borderRadius: radius,
        pointer: state.pointer,
        glow: onPressed != null && !disabled ? tokens.glow(family, variant) : null,
        glowVisible: state.hovered,
        flash: onPressed != null && !disabled ? tokens.flash(family, variant) : null,
        flashVisible: state.pressed,
        reduceMotion: reduceMotion,
        child: body,
      ),
    );

    chip = plassStateFilter(
      child: chip,
      disabled: disabled,
      hovered: state.hovered,
      pressed: state.pressed,
      reduceMotion: reduceMotion,
      lit: onPressed != null,
    );

    // Always there, with only the painter coming and going. A ring wrapped
    // round the chip when it is needed would move the chip to a new parent as
    // the focus steps on to the ×, and the × built again from scratch would
    // lose the focus it had just been given.
    chip = CustomPaint(
      foregroundPainter: focusVisible
          ? PlassFocusRingPainter(color: family.ring, borderRadius: radius)
          : null,
      child: chip,
    );

    return PlassTargetScope(child: chip);
  }

  /// The count's own small plate.
  ///
  /// On a filled chip it is light let through the fill; on a tinted or a bare
  /// one it is the accent showing under the words.
  Widget _countPlate(
    BuildContext context,
    PlassTokens tokens,
    PlassColorFamily family, {
    required double fontSize,
  }) {
    final filled = variant == PlassVariant.solid;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: filled ? tokens.glowOnFill : family.softPress,
        borderRadius: BorderRadius.circular(fontSize),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            color: filled ? family.onSolid : family.accent,
            fontSize: fontSize * _countScale,
            fontWeight: FontWeight.w600,
            height: 1,
            leadingDistribution: TextLeadingDistribution.even,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
          child: count!,
        ),
      ),
    );
  }
}
