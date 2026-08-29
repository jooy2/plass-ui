/// Content pulsing between full opacity and a floor.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/animate.dart';
import 'package:plass_ui/src/types.dart';

/// Content pulsing between full opacity and a floor.
///
/// ```dart
/// const PlAnimateBlink(min: 0.45, child: PlChip(child: Text('Awaiting approval')))
/// ```
///
/// The cycle is symmetric — full, faint, full — so however many times it runs it
/// ends where it started. A blink that finished halfway would leave the widget
/// permanently half drawn, which reads as a rendering fault rather than as an
/// effect that ended.
///
/// It repeats forever unless told otherwise, because a single blink is a
/// flicker and nobody asks for a flicker. Two things are worth saying about
/// using it at all: something that never stops moving in the corner of a screen
/// being read is the one kind of motion this package otherwise refuses, and a
/// reader whose platform has animations turned off will see none of it — so
/// [min] is a dimming, never the only thing carrying the message. If it is
/// urgent, say so in words too.
class PlAnimateBlink extends StatelessWidget {
  /// Creates a pulse.
  const PlAnimateBlink({
    required this.child,
    this.min = 0,
    this.duration = const Duration(milliseconds: 1000),
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

  /// How faint it gets at the bottom of the cycle, between `0` and `1`.
  ///
  /// Raise it for something that has to stay readable while it pulses.
  final double min;

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

  /// What pulses.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PlassAnimateRun(
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
        // Full at both ends and faint in the middle, so a run that ends leaves
        // the widget exactly as it found it.
        return Opacity(opacity: (min + (1 - min) * (t * 2 - 1).abs()).clamp(0, 1), child: inner);
      },
    );
  }
}
