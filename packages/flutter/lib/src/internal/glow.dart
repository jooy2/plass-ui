/// The interaction light.
///
/// Two stacked layers on an interactive surface, both reading the pointer's
/// position, and both invisible until there is a pointer to read.
///
/// This is the one thing Plass's controls do that a conventional toolkit's do
/// not, and it is here because a surface made of glass should answer where it
/// is being touched. It replaces a static specular highlight that used to sit
/// over every filled control: a highlight that is always on is a claim about a
/// lamp somewhere off-screen, and it read as lacquer. Light that arrives with
/// the pointer is a claim about the pointer, which is true.
///
/// The two layers are separate widgets rather than one, because they do not sit
/// together in the painting order: the bloom is under the label and the flash
/// is over it, exactly as `::before` and `::after` are in the stylesheet.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/theme/tokens.dart';

/// One layer of the interaction light: a radial gradient centred on the
/// pointer, faded in and out by [visible].
///
/// The asymmetry between the two layers' durations is the whole trick. The
/// bloom eases both ways over 240ms and simply trails the pointer. The flash
/// takes **zero** milliseconds to arrive and ~700 to leave, so it lands on the
/// frame of the press and is still visibly draining a beat after the finger
/// lifts. No ripple widget, no timers.
class PlassGlowLayer extends StatelessWidget {
  /// Creates a light layer.
  const PlassGlowLayer({
    required this.pointer,
    required this.visible,
    required this.color,
    required this.radius,
    required this.duration,
    this.curve = PlassTokens.ease,
    this.instant = false,
    this.reduceMotion = false,
    super.key,
  });

  /// Where the pointer is, in this surface's coordinates. `null` means it has
  /// never been over the surface, and the light falls back to the centre —
  /// where it sits at zero opacity anyway, so nothing is drawn.
  final Offset? pointer;

  /// Whether the layer is lit.
  final bool visible;

  /// The light's colour, alpha included.
  final Color color;

  /// How far it reaches, in logical pixels.
  final double radius;

  /// How long it takes to leave.
  final Duration duration;

  /// The curve it leaves on.
  final Curve curve;

  /// Whether it arrives with no transition at all. True for the press flash.
  final bool instant;

  /// Someone who has asked for less movement is asking for state changes to
  /// *arrive*, not to be taken away. The light still appears; it stops easing,
  /// so it is either on the control or it is not.
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final out = reduceMotion ? const Duration(milliseconds: 1) : duration;

    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: visible && instant ? Duration.zero : out,
        curve: curve,
        child: _Radial(color: color, radius: radius, pointer: pointer),
      ),
    );
  }
}

/// One radial gradient, positioned on the pointer.
class _Radial extends StatelessWidget {
  const _Radial({required this.color, required this.radius, required this.pointer});

  final Color color;
  final double radius;
  final Offset? pointer;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final size = constraints.biggest;

        if (size.isEmpty || !size.isFinite) {
          return const SizedBox.shrink();
        }

        final at = pointer ?? size.center(Offset.zero);

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              // `Alignment` runs -1..1 across the box and is allowed outside
              // that — a pointer at the very edge of a wide control is exactly
              // where the light should still reach from.
              center: Alignment((at.dx / size.width) * 2 - 1, (at.dy / size.height) * 2 - 1),
              // A fraction of the shortest side, which is what makes it a
              // circle rather than an ellipse — the same as the stylesheet's
              // `<length> circle at …`.
              radius: radius / size.shortestSide,
              colors: <Color>[color, color.withValues(alpha: 0)],
              stops: const <double>[0, 0.7],
            ),
          ),
        );
      },
    );
  }
}
