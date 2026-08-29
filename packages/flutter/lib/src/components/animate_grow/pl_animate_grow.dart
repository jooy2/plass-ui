/// Content unfolding from a point.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/animate.dart';
import 'package:plass_ui/src/types.dart';

/// Content unfolding from a point.
///
/// ```dart
/// const PlAnimateGrow(
///   origin: Alignment.topCenter,
///   child: PlBox(child: Text('Sort, group and column visibility.')),
/// )
/// ```
///
/// The difference from [PlAnimateZoom] is [origin] and how far it travels: a
/// grow starts close to its final size and can be anchored to an edge, so it
/// reads as something opening out of the thing beside it — a panel out of a
/// toolbar, a card out of the row it belongs to. A zoom starts much smaller and
/// always from the middle.
///
/// Short travel is what makes it safe on glass. A sheet growing from `0.8`
/// stays recognisably the same sheet the whole way, and what is behind it never
/// has to resolve a surface a fifth of the size it is about to be.
class PlAnimateGrow extends StatelessWidget {
  /// Creates a grow.
  const PlAnimateGrow({
    required this.child,
    this.mode = PlassAnimateMode.enter,
    this.from = 0.8,
    this.origin = Alignment.center,
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

  /// Whether the content unfolds or folds away.
  final PlassAnimateMode mode;

  /// The scale it starts from, as a multiple of its final size.
  ///
  /// Above `1` it settles down onto the screen instead of up out of it.
  final double from;

  /// Which point stays put while the rest moves.
  ///
  /// [Alignment] rather than a CSS `transform-origin` string, because the
  /// framework already has the type — `Alignment.topCenter` unfolds downwards,
  /// `Alignment.bottomLeft` out of a corner.
  final Alignment origin;

  /// Fades in as it grows.
  ///
  /// Turn it off for something already on screen that is only changing size.
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

  /// What unfolds.
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
        final Widget scaled = Transform.scale(
          scale: from + (1 - from) * t,
          alignment: origin,
          child: inner,
        );

        return fade ? Opacity(opacity: t.clamp(0, 1), child: scaled) : scaled;
      },
    );
  }
}
