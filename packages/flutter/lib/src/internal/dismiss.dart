/// The × that takes something away.
///
/// A chip's remove, an alert's close, a modal's, a toast's, a file's. One
/// drawing at one weight, kept quiet until it is wanted, in one file — because
/// two copies of a dismissal drift by half a point of opacity, and then a page
/// has two kinds of "close" on it.
///
/// None of this is exported from `plass_ui.dart` — it is the library talking to
/// itself.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/theme/tokens.dart';

/// How visible the × is before the pointer or the keyboard reaches it.
///
/// Not invisible: a dismissal you cannot see until you hover it is a dismissal
/// a touch screen never announces. Quiet is the most it may be.
const double _rest = 0.7;

/// How large it is drawn, against the line of text it sits on.
const double dismissScale = 1.15;

/// The ×.
class PlassDismissButton extends StatelessWidget {
  /// Creates a dismiss button.
  const PlassDismissButton({
    required this.label,
    required this.onPressed,
    required this.size,
    required this.color,
    required this.ring,
    super.key,
  });

  /// The name a screen reader gives it. Never drawn.
  final String label;

  /// Called when it is pressed. `null` leaves the button in place and inert.
  final VoidCallback? onPressed;

  /// The box the × is drawn in.
  final double size;

  /// The ink, which is whatever the surface it sits on is written in.
  final Color color;

  /// The focus ring's colour.
  final Color ring;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return PlassInteractive(
      onTap: onPressed,
      interactive: onPressed != null,
      enabled: onPressed != null,
      cursor: onPressed != null ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      builder: (BuildContext context, PlassInteraction state) {
        final lit = state.hovered || state.focusVisible;

        Widget mark = AnimatedOpacity(
          opacity: lit ? 1 : _rest,
          duration: reduceMotion ? Duration.zero : PlassTokens.duration,
          curve: PlassTokens.ease,
          child: SizedBox.square(
            dimension: size,
            child: PlassGlyph(PlassGlyphShape.close, size: size, color: color),
          ),
        );

        if (state.focusVisible) {
          mark = CustomPaint(
            foregroundPainter: PlassFocusRingPainter(
              color: ring,
              borderRadius: BorderRadius.circular(size),
            ),
            child: mark,
          );
        }

        return Semantics(
          // A node of its own, and not an annotation folded into whatever it
          // sits inside: a dismissal that merges into its alert is a dismissal
          // a screen reader cannot reach separately from the message.
          container: true,
          button: true,
          label: label,
          enabled: onPressed != null,
          onTap: onPressed,
          child: mark,
        );
      },
    );
  }
}
