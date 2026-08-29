/// Content turning about a point.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/animate.dart';
import 'package:plass_ui/src/types.dart';

/// Content turning about a point.
///
/// ```dart
/// const PlAnimateRotate(
///   from: 0,
///   to: 360,
///   duration: Duration(milliseconds: 2400),
///   curve: Curves.linear,
///   repeat: null,
///   fade: false,
///   child: PlIcon(icon: RefreshGlyph()),
/// )
/// ```
///
/// Two angles rather than one, which is what lets this be both effects a
/// rotation is ever used for. [from] alone is an arrival — something swinging
/// into place and stopping. [from] and [to] together with a `null` repeat and a
/// linear curve is a spin that never lands, which is what a badge, a loading
/// mark or a decorative glyph wants.
///
/// Rotation is the one movement the design language allows on a glyph without
/// argument — a chevron is turned rather than redrawn all over the package.
/// What it is not for is text: a rotated word is resampled along its whole
/// length, which is precisely what the rule against transforming a control
/// exists to prevent.
///
/// Both angles are **degrees**, not radians. The framework counts in radians
/// and the design language counts in degrees — every gradient in the package is
/// at 135° — so the conversion happens here, once, rather than at every call
/// site.
class PlAnimateRotate extends StatelessWidget {
  /// Creates a rotation.
  const PlAnimateRotate({
    required this.child,
    this.mode = PlassAnimateMode.enter,
    this.from = -180,
    this.to = 0,
    this.origin = Alignment.center,
    this.fade = true,
    this.duration = const Duration(milliseconds: 440),
    this.delay = Duration.zero,
    this.curve,
    this.repeat = 1,
    this.alternate = false,
    this.paused = false,
    this.trigger = PlassAnimateTrigger.mount,
    this.play = false,
    this.once = true,
    this.threshold = defaultVisibleThreshold,
    super.key,
  });

  /// Whether the content turns into place or out of it.
  final PlassAnimateMode mode;

  /// The angle it starts at, in degrees. Negative is anticlockwise.
  final double from;

  /// The angle it ends at, in degrees.
  ///
  /// Together with [from] this is what makes one widget cover both a quarter
  /// turn into place and an endless spin.
  final double to;

  /// Which point it turns about.
  final Alignment origin;

  /// Fades in as it turns.
  ///
  /// Turn it off for a continuous spin, where a repeating fade would read as
  /// flickering.
  final bool fade;

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

  /// What turns.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PlassAnimateRun(
      mode: mode,
      settings: PlassAnimateSettings(
        duration: duration,
        delay: delay,
        curve: curve,
        repeat: repeat,
        alternate: alternate,
        paused: paused,
        trigger: trigger,
        play: play,
        once: once,
        threshold: threshold,
      ),
      child: child,
      builder: (BuildContext context, double t, Widget? inner) {
        final Widget turned = Transform.rotate(
          angle: (from + (to - from) * t) * math.pi / 180,
          alignment: origin,
          child: inner,
        );

        return fade ? Opacity(opacity: t.clamp(0, 1), child: turned) : turned;
      },
    );
  }
}
