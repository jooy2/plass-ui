/// A round button with a glyph in it and nothing else.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/button/pl_button.dart';
import 'package:plass_ui/src/internal/button_group.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/types.dart';

/// A round button with a glyph in it and nothing else.
///
/// ```dart
/// PlIconButton(
///   icon: const Icon(Icons.delete_outline),
///   label: 'Delete',
///   color: PlassColor.danger,
///   onPressed: remove,
/// )
/// ```
///
/// A [PlButton] with an icon and no child already goes square — the same
/// height, the same width, the house fillet cut off it. This is the other
/// shape: a disc.
///
/// That disc is a deliberate exception to the radius rule, which holds every
/// corner well short of the 50% that would make a control a pill, because the
/// flat run along the top and bottom edge is what still reads as a sheet with
/// its corners cut. The rule is about *labelled* controls: the flat run is
/// there for the line of text to sit on, and a glyph has no line of text. A
/// circle with a single mark centred in it is a punched token rather than a
/// moulded key, so it says the thing the rule exists to protect by a different
/// route.
///
/// Everything else is [PlButton]'s, unchanged and on purpose: the three
/// materials, the elevation ladder, the pointer light, [loading], [readOnly]
/// and [disabled]. Two widgets that draw the same surface out of two copies of
/// the same table are two widgets that will eventually disagree.
class PlIconButton extends StatelessWidget {
  /// Creates an icon button. [label] is required — see the field.
  const PlIconButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.onLongPress,
    this.variant,
    this.size,
    this.color,
    this.elevation,
    this.loading = false,
    this.readOnly = false,
    this.disabled,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(
         elevation == null || (elevation >= plassElevationMin && elevation <= plassElevationMax),
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The glyph, drawn at 1.2× the label's type size — so it tracks the ladder
  /// and never needs a size of its own. An [Icon] picks that up from the
  /// surrounding [IconTheme]; anything else should size itself.
  final Widget icon;

  /// What the button does, in words.
  ///
  /// Required, and the one parameter here that is. A button whose whole label
  /// is a drawing has no accessible name at all, and "an icon button with no
  /// label" is the single most common accessibility defect a component library
  /// ships. Making it required is the only fix that survives review.
  ///
  /// It is never drawn. What a reader sees is the glyph; what a screen reader
  /// hears is this.
  final String label;

  /// Called when the button is activated, by pointer or by keyboard. Leaving it
  /// `null` disables the button, as it does everywhere else in Flutter.
  final VoidCallback? onPressed;

  /// Called on a long press — the touch equivalent of a context menu.
  final VoidCallback? onLongPress;

  /// What the surface is made of. See [PlassVariant].
  ///
  /// Nullable for the reason [PlButton]'s is: `null` means *this button did not
  /// say*, so a [PlButtonGroup] above it answers instead.
  final PlassVariant? variant;

  /// The disc's diameter and the glyph inside it, on [PlButton]'s own ladder —
  /// so a disc and a labelled button on one row keep their baseline.
  final PlassSize? size;

  /// Semantic colour role. Six only.
  final PlassColor? color;

  /// Drop shadow depth, `0`–`3`. `1`, as on a [PlButton]: a moulded token rests
  /// on the sheet rather than lying flush with it.
  final PlassElevation? elevation;

  /// Shows a spinner in place of the glyph and stops the button activating,
  /// while keeping it focusable.
  final bool loading;

  /// Inert but not dimmed. Keeps its colour, goes flat, drains most of its
  /// saturation, and stays in the focus order.
  final bool readOnly;

  /// Unavailable. Loses its light and its shadow, and leaves the focus order.
  final bool? disabled;

  /// Drive focus from outside. Left out, the button owns one of its own.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    // The disc's diameter is the one thing here that cannot be left unresolved:
    // a radius is a number. Everything else goes on to PlButton as it arrived,
    // `null` included, so a run around it still answers for it.
    final step = size ?? PlassButtonGroupScope.maybeOf(context)?.size ?? PlassSize.md;

    return PlButton(
      // The glyph goes in `startIcon` rather than in `child`, which is what puts
      // PlButton on its icon-only path: square footprint, no horizontal
      // padding, and the spinner taking the glyph's place while `loading`.
      startIcon: icon,
      semanticLabel: label,
      // Half the height, rather than a number large enough to be clamped: the
      // radius has to be exactly the radius of the box, or the paint scales it
      // and the disc stops being one at the ends.
      borderRadius: BorderRadius.circular(controlHeight[step]! / 2),
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
  }
}
