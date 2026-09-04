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
    this.extended = false,
    this.corner = PlassCorner.bottomEnd,
    this.offset = _defaultOffset,
    this.floating = true,
    this.variant = PlassVariant.solid,
    this.size,
    this.color,
    this.elevation = 3,
    this.loading = false,
    this.disabled,
    super.key,
  });

  /// The glyph.
  final Widget icon;

  /// What the button does, in words. The accessible name whether or not the
  /// words are drawn.
  final String label;

  /// What pressing it does. Leaving it `null` disables the button.
  final VoidCallback? onPressed;

  /// Draws the label beside the glyph.
  ///
  /// Worth turning on for the action a first-time reader would not guess from a
  /// glyph, and worth turning off again once they would.
  final bool extended;

  /// Which corner of its [Stack] it sits in.
  final PlassCorner corner;

  /// How far it stands off the two edges it is against, in logical pixels.
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

  /// How far off the screen. `3` — the top of the ladder — and unlike every
  /// other default in the package it is not a compromise: this is the one
  /// control that genuinely floats over the content rather than resting on it.
  final int elevation;

  /// Swaps the glyph for a spinner and stops the press.
  final bool loading;

  /// Greys it out and stops the press, keeping it where it is.
  final bool? disabled;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.lg;

    final Widget button = extended
        ? PlButton(
            onPressed: onPressed,
            variant: variant,
            size: size,
            color: color,
            elevation: elevation,
            loading: loading,
            disabled: disabled,
            startIcon: icon,
            semanticLabel: label,
            child: Text(label),
          )
        : PlIconButton(
            icon: icon,
            label: label,
            onPressed: onPressed,
            variant: variant,
            size: size,
            color: color,
            elevation: elevation,
            loading: loading,
            disabled: disabled,
          );

    if (!floating) {
      return button;
    }

    // Directional rather than physical: a corner is `start`/`end` here as
    // everywhere, so the button crosses the screen under RTL along with
    // everything else.
    return PositionedDirectional(
      top: switch (corner) {
        PlassCorner.topStart || PlassCorner.topEnd => offset,
        PlassCorner.bottomStart || PlassCorner.bottomEnd => null,
      },
      bottom: switch (corner) {
        PlassCorner.bottomStart || PlassCorner.bottomEnd => offset,
        PlassCorner.topStart || PlassCorner.topEnd => null,
      },
      start: switch (corner) {
        PlassCorner.topStart || PlassCorner.bottomStart => offset,
        PlassCorner.topEnd || PlassCorner.bottomEnd => null,
      },
      end: switch (corner) {
        PlassCorner.topEnd || PlassCorner.bottomEnd => offset,
        PlassCorner.topStart || PlassCorner.bottomStart => null,
      },
      child: button,
    );
  }
}
