/// A light travelling around the outside of something.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/animate.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// A light travelling around the outside of something.
///
/// ```dart
/// const PlAnimateLighting(
///   size: PlassSize.lg,
///   child: PlCard(size: PlassSize.lg, title: Text('Recommended')),
/// )
/// ```
///
/// The light is **behind** the content rather than on it, so what a reader sees
/// is a glow escaping from under the edges — which is why it works on a
/// [PlCard] or a [PlButton] without touching anything about how they are drawn.
/// Nothing inside is altered, nothing is overlaid, and the content stays exactly
/// as legible as it was.
///
/// The arc itself is a gradient that **turns between the two ends of the
/// family**, which is the same rule every filled surface in the package
/// follows: a flat coloured arc would be paint, and nothing here is paint.
///
/// Use it to mark the one thing on a screen that is currently live — the row
/// that is processing, the field being checked, the plan being recommended. It
/// draws attention with light rather than by moving anything, which is the only
/// way this package has of saying "here" without also saying "and it moved".
///
/// [size] has to agree with the radius of what is inside it. The glow follows
/// this widget's own corners, so an `lg` card in an `xs` lighting will show
/// light poking out of four corners the card has already rounded away.
class PlAnimateLighting extends StatelessWidget {
  /// Creates a travelling light.
  const PlAnimateLighting({
    required this.child,
    this.color,
    this.glow,
    this.size,
    this.spread = 3,
    this.arc = 50,
    this.blur = 5,
    this.reverse = false,
    this.duration = const Duration(milliseconds: 3000),
    this.delay = Duration.zero,
    this.curve,
    this.repeat,
    this.alternate = false,
    this.paused = false,
    this.trigger = PlassAnimateTrigger.mount,
    this.play = false,
    this.once = true,
    this.threshold = defaultVisibleThreshold,
    super.key,
  });

  /// Which family the light is drawn in.
  ///
  /// The arc turns between that family's two ends as it travels, exactly as a
  /// [PlassVariant.solid] fill does.
  final PlassColor? color;

  /// A colour, when a semantic family is not what is wanted.
  ///
  /// Overrides [color], and the arc stops turning — one colour has nowhere to
  /// turn to.
  final Color? glow;

  /// The radius the light follows, on the shared ladder.
  final PlassSize? size;

  /// How far past the content the light reaches, in logical pixels.
  final double spread;

  /// How much of the outline is lit at once, in degrees.
  ///
  /// Small is a travelling spark; large is a sweep.
  final double arc;

  /// How soft the light is, in logical pixels.
  ///
  /// At `0` it is a hard-edged wedge, which reads as a graphic rather than as
  /// light.
  final double blur;

  /// Runs the light the other way round.
  final bool reverse;

  /// How long one run takes.
  final Duration duration;

  /// How long before it starts. Counted once, before the first run.
  final Duration delay;

  /// The easing curve. The house curve when nothing says otherwise.
  final Curve? curve;

  /// How many times it runs. `null` never stops.
  final int? repeat;

  /// Runs every other pass backwards, so a repeat returns instead of jumping.
  final bool alternate;

  /// Holds the animation where it is.
  final bool paused;

  /// What starts it.
  final PlassAnimateTrigger trigger;

  /// Runs it, when [trigger] is [PlassAnimateTrigger.manual]. Each `false` →
  /// `true` starts it over.
  final bool play;

  /// With [PlassAnimateTrigger.visible], whether it runs only the first time.
  final bool once;

  /// With [PlassAnimateTrigger.visible], how much of the widget has to be on
  /// screen before it counts as visible, from `0` to `1`.
  final double threshold;

  /// What is lit.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final color = this.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;

    final PlassTokens tokens = PlassTheme.of(context);
    final PlassColorFamily family = tokens.family(color);
    final Color start = glow ?? family.solid;
    final Color end = glow ?? family.solidTo;
    final bool still = prefersReducedMotion(context);
    final BorderRadius radius = BorderRadius.circular(PlassTokens.radius[size]! + spread);

    return Stack(
      // The glow reaches past the content on every side, and a stack clips its
      // own bounds unless told not to.
      clipBehavior: Clip.none,
      children: <Widget>[
        PositionedDirectional(
          start: -spread,
          top: -spread,
          end: -spread,
          bottom: -spread,
          child: PlassAnimateRun(
            mode: reverse ? PlassAnimateMode.exit : PlassAnimateMode.enter,
            settings: PlassAnimateSettings(
              duration: duration,
              delay: delay,
              // Linear unless a caller insists otherwise: an eased sweep slows
              // at both ends of a loop that has no ends.
              curve: curve ?? Curves.linear,
              repeat: repeat,
              alternate: alternate,
              paused: paused,
              trigger: trigger,
              play: play,
              once: once,
              threshold: threshold,
            ),
            builder: (BuildContext context, double t, Widget? _) {
              return _light(t: t, start: start, end: end, radius: radius, still: still);
            },
          ),
        ),
        child,
      ],
    );
  }

  /// One frame of the arc, blurred.
  ///
  /// What moves is the sweep's own rotation rather than the layer's, and that is
  /// the whole trick: rotating the layer would swing its corners out past the
  /// content on every quarter turn.
  Widget _light({
    required double t,
    required Color start,
    required Color end,
    required BorderRadius radius,
    required bool still,
  }) {
    // The arc stops travelling and becomes an even glow. The same trade the
    // skeleton makes: the decoration survives, the motion does not.
    final Decoration decoration = still
        ? BoxDecoration(borderRadius: radius, color: end)
        : BoxDecoration(
            borderRadius: radius,
            gradient: SweepGradient(
              transform: GradientRotation(t * 2 * math.pi),
              colors: <Color>[
                start.withValues(alpha: 0),
                start,
                end,
                end.withValues(alpha: 0),
                start.withValues(alpha: 0),
              ],
              stops: <double>[0, arc * 0.5 / 360, arc / 360, arc * 2 / 360, 1],
            ),
          );

    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: DecoratedBox(decoration: decoration),
    );
  }
}
