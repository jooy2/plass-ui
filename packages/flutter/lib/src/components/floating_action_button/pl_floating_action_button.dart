/// The one action a screen is about, floating over it.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/button/pl_button.dart';
import 'package:plass_ui/src/components/icon_button/pl_icon_button.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

/// How far it stands off the two edges it is against, unless it is told.
const double _defaultOffset = 24;

/// The one action a screen is about, floating over it.
///
/// ```dart
/// PlFloatingActionButton(
///   icon: const PlusGlyph(),
///   label: 'New project',
///   onPressed: create,
/// )
/// ```
///
/// It is a [PlButton] in a corner, and everything that makes it one is the
/// button's: the three materials, the elevation ladder, the pointer light,
/// `loading`, `readOnly` and `disabled`. What this adds is the **pinning**, the
/// shape, and one rule.
///
/// **[label] is required and is always the accessible name.** A floating button
/// is a disc with a mark in it nine times out of ten, and [extended] decides
/// only whether the words are also drawn — never whether they exist.
///
/// The icon-only form is a **disc**, which is [PlIconButton]'s deliberate
/// exception to the radius rule: the flat run along a control's edge is there
/// for a line of text to sit on, and a glyph has no line of text. The extended
/// form is **not** a pill for exactly that reason — it has words along its edge,
/// so it takes the house fillet like every other labelled control.
///
/// **One per screen.** Two floating buttons in one corner is two primary
/// actions, which is none.
///
/// While [floating] it positions itself, so it belongs in a [Stack] — which is
/// what a screen's body usually already is once anything floats over it.
class PlFloatingActionButton extends StatelessWidget {
  /// Creates a floating action button. [label] is required — see the field.
  const PlFloatingActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.onLongPress,
    this.extended = false,
    this.corner = PlassCorner.bottomEnd,
    this.offset = _defaultOffset,
    this.floating = true,
    this.variant = PlassVariant.solid,
    this.size,
    this.color,
    this.density,
    this.elevation = 3,
    this.loading = false,
    this.readOnly = false,
    this.disabled,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// The glyph.
  final Widget icon;

  /// What the button does, in words. The accessible name whether or not the
  /// words are drawn.
  final String label;

  /// What pressing it does. Leaving it `null` disables the button.
  final VoidCallback? onPressed;

  /// Called on a long press — the touch equivalent of a context menu.
  final VoidCallback? onLongPress;

  /// Draws the label beside the glyph.
  ///
  /// Worth turning on for the action a first-time reader would not guess from a
  /// glyph, and worth turning off again once they would.
  final bool extended;

  /// Which corner of its [Stack] it sits in.
  final PlassCorner corner;

  /// How far it stands off the two edges it is against, in logical pixels.
  ///
  /// The screen's safe area on those two edges is added on top, from
  /// [MediaQuery.paddingOf], so the button clears the home indicator, the
  /// navigation bar or a camera cutout of an edge-to-edge screen rather than
  /// sitting under it. Inside a `SafeArea` that padding is already zero, so the
  /// space is never added twice.
  final double offset;

  /// Whether it positions itself at all.
  ///
  /// On by default, because that is what this widget is. Turn it off to put the
  /// same button somewhere of your own — the end of a card, a toolbar — and keep
  /// the shape and the shadow.
  final bool floating;

  /// What the key is made of.
  final PlassVariant variant;

  /// One step up the ladder from a [PlButton]'s default.
  final PlassSize? size;

  /// The family it takes.
  final PlassColor? color;

  /// Changes horizontal padding and nothing else, and only while [extended].
  ///
  /// The disc has no horizontal padding to change — its glyph sits in a square
  /// — so [PlIconButton] takes no density, and on the icon-only form this does
  /// nothing.
  final PlassDensity? density;

  /// How far off the screen. `3` — the top of the ladder — and unlike every
  /// other default in the package it is not a compromise: this is the one
  /// control that genuinely floats over the content rather than resting on it.
  final int elevation;

  /// Swaps the glyph for a spinner and stops the press.
  final bool loading;

  /// Inert but not dimmed — the action exists, it just is not available here.
  /// Unlike [disabled] it stays in the focus order.
  final bool readOnly;

  /// Greys it out and stops the press, keeping it where it is.
  final bool? disabled;

  /// Drive focus from outside. Left out, the button owns one of its own.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.lg;

    final Widget button = extended
        ? PlButton(
            onPressed: onPressed,
            onLongPress: onLongPress,
            variant: variant,
            size: size,
            color: color,
            density: density,
            elevation: elevation,
            loading: loading,
            readOnly: readOnly,
            disabled: disabled,
            focusNode: focusNode,
            autofocus: autofocus,
            startIcon: icon,
            // The words on the key are its name already. A `semanticLabel` as
            // well would be merged with them and read twice.
            child: Text(label),
          )
        : PlIconButton(
            icon: icon,
            label: label,
            onPressed: onPressed,
            onLongPress: onLongPress,
            variant: variant,
            size: size,
            color: color,
            elevation: elevation,
            loading: loading,
            readOnly: readOnly,
            disabled: disabled,
            focusNode: focusNode,
            autofocus: autofocus,
          );

    if (!floating) {
      return button;
    }

    // The safe area goes on top of the offset, so the button clears the home
    // indicator or the navigation bar of an edge-to-edge screen. The padding is
    // physical and the corner is not, so which of its sides is the start is the
    // direction's question.
    final EdgeInsets safe = MediaQuery.paddingOf(context);
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final double safeStart = rtl ? safe.right : safe.left;
    final double safeEnd = rtl ? safe.left : safe.right;

    // Directional rather than physical: a corner is `start`/`end` here as
    // everywhere, so the button crosses the screen under RTL along with
    // everything else.
    return PositionedDirectional(
      top: switch (corner) {
        PlassCorner.topStart || PlassCorner.topEnd => offset + safe.top,
        PlassCorner.bottomStart || PlassCorner.bottomEnd => null,
      },
      bottom: switch (corner) {
        PlassCorner.bottomStart || PlassCorner.bottomEnd => offset + safe.bottom,
        PlassCorner.topStart || PlassCorner.topEnd => null,
      },
      start: switch (corner) {
        PlassCorner.topStart || PlassCorner.bottomStart => offset + safeStart,
        PlassCorner.topEnd || PlassCorner.bottomEnd => null,
      },
      end: switch (corner) {
        PlassCorner.topEnd || PlassCorner.bottomEnd => offset + safeEnd,
        PlassCorner.topStart || PlassCorner.bottomStart => null,
      },
      child: button,
    );
  }
}
