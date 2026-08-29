/// Content arriving from the middle of where it will end up.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/animate.dart';
import 'package:plass_ui/src/types.dart';

/// Content arriving from the middle of where it will end up.
///
/// ```dart
/// const PlAnimateZoom(child: PlBox(color: PlassColor.success, child: Text('92')))
/// ```
///
/// The same arithmetic as [PlAnimateGrow] at more than twice the distance, and
/// always about the centre — which is the whole difference. A grow unfolds from
/// somewhere; a zoom comes at you. Use it for the one thing on a screen that is
/// meant to interrupt: a confirmation, a result, a number that has just landed.
///
/// There is no `origin`, on purpose. A zoom anchored to a corner is a grow, and
/// the package does not offer two spellings of one idea.
class PlAnimateZoom extends StatelessWidget {
  /// Creates a zoom.
  const PlAnimateZoom({
    required this.child,
    this.mode = PlassAnimateMode.enter,
    this.from = 0.4,
    this.fade = true,
    this.duration = const Duration(milliseconds: 320),
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

  /// Whether the content comes forward or falls away.
  final PlassAnimateMode mode;

  /// The scale it starts from, as a multiple of its final size.
  ///
  /// Above `1` it arrives oversized and settles back, which reads as coming
  /// *towards* the reader rather than up out of the screen.
  final double from;

  /// Fades in as it zooms.
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

  /// What arrives.
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
        final Widget scaled = Transform.scale(scale: from + (1 - from) * t, child: inner);

        return fade ? Opacity(opacity: t.clamp(0, 1), child: scaled) : scaled;
      },
    );
  }
}
