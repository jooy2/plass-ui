/// Content drifting gently, and not going anywhere.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/animate.dart';
import 'package:plass_ui/src/types.dart';

/// Content drifting gently, and not going anywhere.
///
/// ```dart
/// const PlAnimateFloat(child: EmptyStateMark())
/// ```
///
/// The odd one out among the `PlAnimate*` widgets, and this says so: the other
/// effects are **entrances**, played once when content arrives. This one never
/// finishes. It is for the thing that is meant to read as weightless — an
/// illustration on a landing screen, a mark over an empty state — and for
/// nothing a reader has to read while it moves.
///
/// The cycle is symmetric — home, out, home — so however many times it runs it
/// ends where it started. A float stopped mid-cycle would leave the widget
/// permanently a few pixels out of place, which reads as a layout bug rather
/// than as an effect that ended.
///
/// [curve] defaults to [Curves.easeInOut] rather than to the house curve, and
/// that is the one place in the package where it is right: the house curve is an
/// entrance's, fast out of the gate and slow into place, and a drift with it
/// would lurch at each end of the cycle instead of turning around.
///
/// A reader whose platform has animations turned off sees none of it, as with
/// every effect here. Nothing may depend on the movement.
class PlAnimateFloat extends StatelessWidget {
  /// Creates a drift.
  const PlAnimateFloat({
    required this.child,
    this.distance = 8,
    this.orientation = PlassOrientation.vertical,
    this.duration = const Duration(milliseconds: 3000),
    this.delay = Duration.zero,
    this.curve = Curves.easeInOut,
    this.repeat,
    this.paused = false,
    this.trigger = PlassAnimateTrigger.mount,
    this.play = false,
    this.once = true,
    this.threshold = defaultVisibleThreshold,
    super.key,
  });

  /// How far it drifts from where it started, in logical pixels.
  ///
  /// Small on purpose. A float is meant to be noticed at the edge of attention
  /// and not looked at, and past about a dozen pixels it stops being a drift and
  /// starts being something moving on the screen.
  final double distance;

  /// Which way it drifts.
  final PlassOrientation orientation;

  /// How long one round trip takes.
  final Duration duration;

  /// How long before it starts. Counted once, before the first run.
  final Duration delay;

  /// The easing curve.
  final Curve curve;

  /// How many times it runs. `null` never stops.
  final int? repeat;

  /// Holds the drift where it is.
  final bool paused;

  /// What starts it.
  final PlassAnimateTrigger trigger;

  /// Runs it, when [trigger] is [PlassAnimateTrigger.manual].
  final bool play;

  /// With [PlassAnimateTrigger.visible], whether it runs only the first time.
  final bool once;

  /// With [PlassAnimateTrigger.visible], how much of the widget has to be on
  /// screen before it counts as visible, from `0` to `1`.
  final double threshold;

  /// What drifts.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PlassAnimateRun(
      settings: PlassAnimateSettings(
        duration: duration,
        delay: delay,
        curve: curve,
        repeat: repeat,
        paused: paused,
        trigger: trigger,
        play: play,
        once: once,
        threshold: threshold,
      ),
      child: child,
      builder: (BuildContext context, double t, Widget? inner) {
        // Home at both ends and out in the middle, so a run that ends leaves the
        // widget exactly where it found it.
        final away = distance * (1 - (t * 2 - 1).abs());

        return Transform.translate(
          // Up rather than down, which is what "float" means everywhere it is
          // used.
          offset: orientation == PlassOrientation.vertical ? Offset(0, -away) : Offset(away, 0),
          child: inner,
        );
      },
    );
  }
}
