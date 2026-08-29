/// A list of things settling into place one after another.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/animate.dart';
import 'package:plass_ui/src/types.dart';

/// A list of things settling into place one after another.
///
/// ```dart
/// PlAnimateAppear(
///   spacing: 8,
///   children: <Widget>[
///     for (final Service service in services) PlCard(title: Text(service.name)),
///   ],
/// )
/// ```
///
/// Each child takes the same short drift and fade, held back by its position —
/// so the effect belongs to the *set* rather than to any one item, and a
/// reader's eye is walked down the list in the order it should be read.
///
/// The stagger is per **child**, which means what you pass matters: eight
/// children are eight steps, and one child holding eight things is one step.
/// That is also how to opt part of a list out — group it.
///
/// It lays its children out, which the React build does not have to: there is
/// no stylesheet here to put a `display: flex` on the container, so
/// [orientation] and [spacing] are what a `className` would have done. Anything
/// more elaborate than a row or a column belongs *inside* one child, which also
/// makes that whole arrangement one step of the stagger.
class PlAnimateAppear extends StatelessWidget {
  /// Creates a staggered set.
  const PlAnimateAppear({
    required this.children,
    this.orientation = PlassOrientation.vertical,
    this.spacing = 0,
    this.stagger = const Duration(milliseconds: 70),
    this.from = PlassSide.bottom,
    this.distance = 12,
    this.fade = true,
    this.reverse = false,
    this.duration = const Duration(milliseconds: 380),
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

  /// The things that appear, one after another.
  final List<Widget> children;

  /// Which way the set runs.
  final PlassOrientation orientation;

  /// The gap between children, in logical pixels.
  final double spacing;

  /// How long after one child the next one starts.
  ///
  /// This is the whole effect — everything else is what a single child does.
  final Duration stagger;

  /// Which edge each child drifts in from.
  final PlassSide from;

  /// How far each child travels, in logical pixels.
  ///
  /// Short on purpose: this is a settling, not an entrance from off screen, and
  /// a long travel over a list of eight turns the whole block into something
  /// moving.
  final double distance;

  /// Fades each child in as it settles.
  final bool fade;

  /// Runs the list from the last child to the first.
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

  @override
  Widget build(BuildContext context) {
    final ({Offset fraction, Offset pixels}) start = slideOffset(from, distance);

    return PlassAnimateGate(
      // The trigger belongs to the *set*: one gate above every child, rather
      // than one per child each deciding for itself when it is on screen.
      // `paused` is deliberately not here — it goes to the children, where
      // holding one still is holding it where it is rather than rewinding it.
      settings: PlassAnimateSettings(
        duration: duration,
        trigger: trigger,
        play: play,
        once: once,
        threshold: threshold,
        repeat: repeat,
      ),
      builder: (BuildContext context, bool running, int runs, Widget? _) {
        return Flex(
          direction: orientation == PlassOrientation.vertical ? Axis.vertical : Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: spacing,
          children: <Widget>[
            for (int index = 0; index < children.length; index += 1)
              PlassAnimateRun(
                settings: PlassAnimateSettings(
                  duration: duration,
                  delay: delay + stagger * (reverse ? children.length - 1 - index : index),
                  curve: curve,
                  repeat: repeat,
                  alternate: alternate,
                  paused: paused,
                  // The set has already decided; each child only has to be told.
                  trigger: PlassAnimateTrigger.manual,
                  play: running,
                ),
                child: children[index],
                builder: (BuildContext context, double t, Widget? inner) {
                  final Widget moved = Transform.translate(
                    offset: start.pixels * (1 - t),
                    child: inner,
                  );

                  return fade ? Opacity(opacity: t.clamp(0, 1), child: moved) : moved;
                },
              ),
          ],
        );
      },
    );
  }
}
