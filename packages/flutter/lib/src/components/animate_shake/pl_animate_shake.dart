/// A refusal.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/animate.dart';
import 'package:plass_ui/src/types.dart';

/// How many times it crosses home in one run. Three either side.
const int _shudders = 3;

/// A refusal.
///
/// ```dart
/// PlAnimateShake(replay: attempts, child: const Text('Wrong password'))
/// ```
///
/// The one effect in the set that is a **response** rather than an entrance: it
/// is what a form does when the password was wrong again, what a locked control
/// does when it is pressed. So it starts held still and plays only when it is
/// told to, where every other effect here starts on mount.
///
/// [replay] is the parameter it exists around. A refusal can happen twice, and
/// [play], being a bool, cannot say "again" — replaying with it means toggling
/// off and on, which is two builds for one event and a piece of state whose only
/// job is to be flipped back. A value that has changed is the closest a widget
/// tree has to an event, and the count of failed attempts a form already keeps
/// is exactly that value.
///
/// Three shudders either side of home and back to nothing, so a shaken widget is
/// exactly where it was. This is the one effect a caller will run over content
/// that is still being typed into, and a field left a few pixels off its label
/// would be worse than the error it was reporting.
///
/// **A reader whose platform has animations turned off sees none of it**, which
/// is the whole reason the words matter more than the shake: whatever a refusal
/// is saying has to be said in text as well. The shake is emphasis, never the
/// message.
class PlAnimateShake extends StatelessWidget {
  /// Creates a shake. It plays when [replay] changes or [play] turns on.
  const PlAnimateShake({
    required this.child,
    this.replay,
    this.distance = 6,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.curve,
    this.repeat = 1,
    this.paused = false,
    this.trigger = PlassAnimateTrigger.manual,
    this.play = false,
    this.once = true,
    this.threshold = defaultVisibleThreshold,
    super.key,
  });

  /// Plays the shake again whenever this value changes, and never on the first
  /// build.
  final Object? replay;

  /// How far it travels either side of where it started, in logical pixels.
  final double distance;

  /// How long one run takes.
  final Duration duration;

  /// How long before it starts.
  final Duration delay;

  /// The easing curve.
  final Curve? curve;

  /// How many times it runs.
  final int? repeat;

  /// Holds it where it is.
  final bool paused;

  /// What starts it. [PlassAnimateTrigger.manual] here, unlike every other
  /// effect in the set: a refusal answers something rather than announcing
  /// itself.
  final PlassAnimateTrigger trigger;

  /// Runs it, when [trigger] is [PlassAnimateTrigger.manual].
  final bool play;

  /// With [PlassAnimateTrigger.visible], whether it runs only the first time.
  final bool once;

  /// With [PlassAnimateTrigger.visible], how much of the widget has to be on
  /// screen before it counts as visible, from `0` to `1`.
  final double threshold;

  /// What is refused.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PlassAnimateRun(
      settings: PlassAnimateSettings(
        duration: duration,
        delay: delay,
        curve: curve ?? Curves.linear,
        repeat: repeat,
        paused: paused,
        trigger: trigger,
        play: play,
        once: once,
        threshold: threshold,
        nonce: replay,
      ),
      child: child,
      builder: (BuildContext context, double t, Widget? inner) {
        // A sine that completes a whole number of cycles and is damped to
        // nothing by the end, so the widget lands exactly where it started
        // rather than wherever the curve happened to be when the run stopped.
        final away = math.sin(t * _shudders * 2 * math.pi) * distance * (1 - t);

        return Transform.translate(offset: Offset(away, 0), child: inner);
      },
    );
  }
}
