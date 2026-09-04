/// A line of text arriving one part at a time.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/animate.dart';
import 'package:plass_ui/src/internal/scramble.dart';
import 'package:plass_ui/src/types.dart';

/// What the line is cut into before the entrance is told off across it.
enum PlAnimateSplitBy {
  /// One part per word. The default, and the safe one.
  word,

  /// One part per character. See the class doc for the scripts this must not be
  /// used on.
  character,
}

/// A line of text arriving one part at a time.
///
/// ```dart
/// const PlAnimateSplit(text: 'Ship it on Friday')
/// ```
///
/// A [PlAnimateAppear] tells one entrance off across a set of **children**,
/// which a line of text does not have. This makes them: it cuts the string into
/// words or characters and gives each part the same staggered entrance.
///
/// **`PlAnimateSplitBy.character` is not safe in every script**, and that is the
/// one thing to know before reaching for it. Cutting between letters breaks the
/// shaping between them, so Arabic stops joining, Devanagari conjuncts come
/// apart, and an emoji built out of several code points is cut into its pieces.
/// [PlAnimateSplitBy.word] has none of those problems, is the default, and is
/// what a headline wants anyway.
///
/// **A screen reader is told the line, once.** The parts are excluded from the
/// semantics and the whole line is put on the node instead, which is what stops
/// a split headline being read out one letter at a time — the defect this
/// pattern is known for.
///
/// The entrance is spelled as a side, a distance and a fade, exactly as
/// [PlAnimateAppear] spells it. The React build names a CSS keyframe instead,
/// because over there an effect **is** a named thing; here every effect is built
/// out of widgets, so a split takes the same three parameters the widget that
/// staggers an entrance already takes.
class PlAnimateSplit extends StatelessWidget {
  /// Creates a split entrance.
  const PlAnimateSplit({
    required this.text,
    this.by = PlAnimateSplitBy.word,
    this.style,
    this.textAlign,
    this.from = PlassSide.bottom,
    this.distance = 12,
    this.fade = true,
    this.stagger = const Duration(milliseconds: 40),
    this.reverse = false,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.curve,
    this.paused = false,
    this.trigger = PlassAnimateTrigger.mount,
    this.play = false,
    this.once = true,
    this.threshold = defaultVisibleThreshold,
    super.key,
  });

  /// The line.
  final String text;

  /// What it is cut into.
  final PlAnimateSplitBy by;

  /// The text style the line is drawn in.
  final TextStyle? style;

  /// How the parts are aligned once they wrap.
  final TextAlign? textAlign;

  /// Which edge each part comes in from.
  final PlassSide from;

  /// How far it travels, in logical pixels.
  final double distance;

  /// Whether each part fades in as well as moving.
  final bool fade;

  /// How long after one part the next one starts.
  final Duration stagger;

  /// Starts from the end of the line instead of the beginning.
  final bool reverse;

  /// How long one part's entrance takes.
  final Duration duration;

  /// How long before the first part starts.
  final Duration delay;

  /// The easing curve.
  final Curve? curve;

  /// Holds the parts where they are.
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

  @override
  Widget build(BuildContext context) {
    final List<String> parts = splitParts(text, byCharacter: by == PlAnimateSplitBy.character);

    return Semantics(
      // The line, once, rather than one announcement per part.
      label: text,
      container: true,
      child: ExcludeSemantics(
        child: PlassAnimateGate(
          // The trigger belongs to the *line*: one gate above every part, rather
          // than one per part each deciding for itself when it is on screen.
          settings: PlassAnimateSettings(
            duration: duration,
            trigger: trigger,
            play: play,
            once: once,
            threshold: threshold,
          ),
          builder: (BuildContext context, bool running, int runs, Widget? _) {
            return Wrap(
              alignment: switch (textAlign) {
                TextAlign.center => WrapAlignment.center,
                TextAlign.right || TextAlign.end => WrapAlignment.end,
                _ => WrapAlignment.start,
              },
              children: <Widget>[
                for (int index = 0; index < parts.length; index += 1)
                  PlassAnimateRun(
                    settings: PlassAnimateSettings(
                      duration: duration,
                      delay: delay + stagger * (reverse ? parts.length - 1 - index : index),
                      curve: curve,
                      paused: paused,
                      // The line has already decided; each part is only told.
                      trigger: PlassAnimateTrigger.manual,
                      play: running,
                    ),
                    child: Text(parts[index], style: style),
                    builder: (BuildContext context, double t, Widget? inner) {
                      final Offset offset = switch (from) {
                        PlassSide.top => Offset(0, -distance * (1 - t)),
                        PlassSide.bottom => Offset(0, distance * (1 - t)),
                        PlassSide.left => Offset(-distance * (1 - t), 0),
                        PlassSide.right => Offset(distance * (1 - t), 0),
                      };

                      final Widget moved = Transform.translate(offset: offset, child: inner);

                      return fade ? Opacity(opacity: t.clamp(0, 1), child: moved) : moved;
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
