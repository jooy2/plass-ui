/// A line of text resolving out of noise.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/animate.dart';
import 'package:plass_ui/src/internal/scramble.dart';
import 'package:plass_ui/src/types.dart';

/// How often the unsettled characters are redrawn.
///
/// Not every frame, on purpose. At sixty a second a line of changing glyphs
/// strobes, which is unpleasant to look at and is the kind of flicker a reader
/// with a sensitivity to it should never be handed.
const Duration _defaultTick = Duration(milliseconds: 45);

/// A line of text resolving out of noise.
///
/// ```dart
/// const PlAnimateScramble(text: 'Ship it on Friday')
/// ```
///
/// The second of the two effects that animate **content** rather than a box, and
/// it takes a `String` rather than a widget for the same reason a
/// [PlAnimateCounter] takes a number: there is no character to scramble inside a
/// styled span.
///
/// **The noise is made of the line's own characters.** Every scrambler that
/// ships a default alphabet ships an English one, and English noise over a
/// Korean, Greek or Arabic headline is not a word arriving — it is a different
/// script flickering where a word is about to be.
///
/// It settles **left to right**, which is what makes it read as a word arriving
/// rather than as a slot machine, and whitespace is never scrambled.
///
/// **A screen reader is told the line, once**, and never the noise.
class PlAnimateScramble extends StatelessWidget {
  /// Creates a scramble.
  const PlAnimateScramble({
    required this.text,
    this.characters,
    this.style,
    this.duration = const Duration(milliseconds: 1200),
    this.delay = Duration.zero,
    this.tick = _defaultTick,
    this.paused = false,
    this.trigger = PlassAnimateTrigger.visible,
    this.play = false,
    this.once = true,
    this.threshold = defaultVisibleThreshold,
    super.key,
  });

  /// The line that resolves.
  final String text;

  /// The glyphs the unsettled characters are drawn from. The line's own
  /// characters when it is not given.
  final String? characters;

  /// The text style the line is drawn in.
  final TextStyle? style;

  /// How long the line takes to settle.
  final Duration duration;

  /// How long it waits before starting.
  final Duration delay;

  /// How often the unsettled characters are redrawn.
  final Duration tick;

  /// Holds it where it is.
  final bool paused;

  /// What starts it. [PlassAnimateTrigger.visible] for [PlAnimateCounter]'s
  /// reason: a line that resolved off screen delivered text that was simply
  /// already there.
  final PlassAnimateTrigger trigger;

  /// Runs it, when [trigger] is [PlassAnimateTrigger.manual].
  final bool play;

  /// With [PlassAnimateTrigger.visible], whether it runs only the first time.
  final bool once;

  /// With [PlassAnimateTrigger.visible], how much of the widget has to be on
  /// screen before it counts as visible, from `0` to `1`.
  final double threshold;

  @override
  Widget build(BuildContext context) {
    final String pool = characters ?? poolOf(text);

    return Semantics(
      // The line, once. What is drawn is excluded below.
      label: text,
      container: true,
      child: ExcludeSemantics(
        child: PlassAnimateRun(
          settings: PlassAnimateSettings(
            duration: duration,
            delay: delay,
            curve: Curves.linear,
            paused: paused,
            trigger: trigger,
            play: play,
            once: once,
            threshold: threshold,
            // A new line is a new run, however far the old one had settled.
            nonce: text,
          ),
          builder: (BuildContext context, double t, Widget? child) {
            // The draw is stepped rather than taken every frame, so the line
            // changes at `tick` and not at the refresh rate.
            final int slot = duration.inMilliseconds == 0
                ? 0
                : (t * duration.inMilliseconds / tick.inMilliseconds.clamp(1, 1 << 30)).floor();

            return Text(scrambleAt(text, pool, t, slot), style: style);
          },
        ),
      ),
    );
  }
}
