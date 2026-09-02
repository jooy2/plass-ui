/// Content uncovered behind a moving edge.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/animate.dart';
import 'package:plass_ui/src/types.dart';

/// Content uncovered behind a moving edge.
///
/// ```dart
/// const PlAnimateReveal(
///   trigger: PlassAnimateTrigger.visible,
///   child: Text('Two services restarted, no errors.'),
/// )
/// ```
///
/// The only entrance in the set where **nothing moves and no colour changes**.
/// A fade changes the ink, a slide changes the position, a grow changes the
/// size; this changes how much of the widget is painted and leaves every pixel
/// it has painted exactly where it will finally be. That makes it the effect
/// for anything whose position is itself the information — a heading over the
/// paragraph it belongs to, a rule between two sections, a chart's plot area, a
/// column of figures that must not be read from the wrong place.
///
/// It costs nothing in layout either. The clip is applied while painting, so
/// the widget is laid out once, at its full size, and what is around it never
/// learns that anything happened.
///
/// [fade] is **off** by default, alone among the effects that offer it. Fading
/// a reveal is asking for two entrances at once, and the reason to reach for
/// this one is usually that the first was the problem.
class PlAnimateReveal extends StatelessWidget {
  /// Creates a reveal.
  const PlAnimateReveal({
    required this.child,
    this.mode = PlassAnimateMode.enter,
    this.from = PlassSide.left,
    this.fade = false,
    this.duration = const Duration(milliseconds: 520),
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

  /// Whether the content is uncovered or covered again.
  ///
  /// [PlassAnimateMode.exit] is the same wipe run backwards, so it closes from
  /// the edge it opened towards.
  final PlassAnimateMode mode;

  /// Which edge the wipe starts at.
  ///
  /// Physical, as [PlassSide] is everywhere in the package: a heading uncovered
  /// from the top is uncovered from the top in every writing direction.
  final PlassSide from;

  /// Fades in behind the wipe.
  ///
  /// Off by default, which is the opposite of every other effect here and is
  /// the whole point of this one: a reveal is not a fade.
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

  /// What is uncovered.
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
        final Widget wiped = ClipRect(
          // A clipper rather than an `Align` with a width factor, and the
          // difference is the one this effect exists for: an `Align` resizes
          // the box and everything beside it moves. A clipper is asked for a
          // rectangle at paint time and the layout never hears about it.
          clipper: _RevealClipper(from: from, progress: t.clamp(0, 1)),
          child: inner ?? const SizedBox.shrink(),
        );

        return fade ? Opacity(opacity: t.clamp(0, 1), child: wiped) : wiped;
      },
    );
  }
}

/// How much of the box is painted, and from which edge it grows.
class _RevealClipper extends CustomClipper<Rect> {
  const _RevealClipper({required this.from, required this.progress});

  /// The edge the wipe starts at.
  final PlassSide from;

  /// `0` paints nothing; `1` paints the whole box.
  final double progress;

  @override
  Rect getClip(Size size) {
    switch (from) {
      case PlassSide.left:
        return Rect.fromLTWH(0, 0, size.width * progress, size.height);
      case PlassSide.right:
        return Rect.fromLTWH(size.width * (1 - progress), 0, size.width * progress, size.height);
      case PlassSide.top:
        return Rect.fromLTWH(0, 0, size.width, size.height * progress);
      case PlassSide.bottom:
        return Rect.fromLTWH(0, size.height * (1 - progress), size.width, size.height * progress);
    }
  }

  @override
  bool shouldReclip(_RevealClipper oldClipper) =>
      oldClipper.from != from || oldClipper.progress != progress;
}
