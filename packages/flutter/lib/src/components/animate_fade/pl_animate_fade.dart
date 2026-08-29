/// Content arriving or leaving on opacity alone.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/animate.dart';
import 'package:plass_ui/src/types.dart';

/// Content arriving or leaving on opacity alone.
///
/// ```dart
/// const PlAnimateFade(child: Text('Two services restarted, no errors.'))
/// ```
///
/// The plainest effect in the set and the one to reach for first: nothing moves,
/// so nothing is relaid out and nothing is resampled. A fade is the only
/// entrance that is safe on a block of text at any size.
///
/// It is also the effect that suits the material. A Plass sheet is defined by
/// what shows through it, and opacity is the axis the material already answers
/// on — the same axis the glass ladder itself is built from.
///
/// [PlassAnimateMode.exit] is the same run backwards, and it is **held at the
/// end**: a faded-out widget stays faded out rather than snapping back into view
/// when the run finishes.
class PlAnimateFade extends StatelessWidget {
  /// Creates a fade.
  const PlAnimateFade({
    required this.child,
    this.mode = PlassAnimateMode.enter,
    this.from = 0,
    this.duration = const Duration(milliseconds: 300),
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

  /// Whether the content arrives or leaves.
  final PlassAnimateMode mode;

  /// The opacity it starts from, between `0` and `1`.
  ///
  /// Raise it for content that should never be completely gone.
  final double from;

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

  /// What fades.
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
        return Opacity(opacity: (from + (1 - from) * t).clamp(0, 1), child: inner);
      },
    );
  }
}
