/// Content travelling in from one edge.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/animate.dart';
import 'package:plass_ui/src/types.dart';

/// Content travelling in from one edge.
///
/// ```dart
/// const PlAnimateSlide(
///   from: PlassSide.right,
///   child: PlCard(title: Text('New message'), child: Text('Ada replied.')),
/// )
/// ```
///
/// With no [distance] it travels the widget's **own size**, so it starts exactly
/// out of frame and arrives without ever having been half drawn somewhere it
/// does not belong. Put it in a [ClipRect] and the effect is a panel appearing
/// from behind that box's edge.
///
/// A slide moves the widget, so what is *around* it does not move: nothing is
/// laid out again while it runs. For a much shorter travel over a list of
/// things, one after another, use [PlAnimateAppear].
class PlAnimateSlide extends StatelessWidget {
  /// Creates a slide.
  const PlAnimateSlide({
    required this.child,
    this.mode = PlassAnimateMode.enter,
    this.from = PlassSide.bottom,
    this.distance,
    this.fade = true,
    this.duration = const Duration(milliseconds: 360),
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

  /// Whether the content slides in or slides away.
  ///
  /// [PlassAnimateMode.exit] leaves by the same edge it would have come from.
  final PlassAnimateMode mode;

  /// Which edge it travels from.
  ///
  /// Physical, as [PlassSide] is everywhere in the package: a panel coming down
  /// from the top comes from the top in every writing direction.
  final PlassSide from;

  /// How far it travels, in logical pixels.
  ///
  /// `null` — the default — is the widget's **own** width or height, which is
  /// what makes it appear from behind its own edge. There is no CSS length to
  /// write here: a fraction of the widget's own size is what
  /// [FractionalTranslation] already means.
  final double? distance;

  /// Fades in as it slides.
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

  /// What travels.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ({Offset fraction, Offset pixels}) start = slideOffset(from, distance);

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
        final double left = 1 - t;
        final Widget moved = translateBy(
          offset: start.pixels * left,
          fraction: start.fraction * left,
          useFraction: distance == null,
          child: inner ?? const SizedBox.shrink(),
        );

        return fade ? Opacity(opacity: t.clamp(0, 1), child: moved) : moved;
      },
    );
  }
}
