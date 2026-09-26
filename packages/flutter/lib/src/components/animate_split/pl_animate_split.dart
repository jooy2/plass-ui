/// A line of text arriving one part at a time.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/animate.dart';
import 'package:plass_ui/src/internal/scramble.dart';
import 'package:plass_ui/src/internal/surface.dart';
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
/// words or characters and gives each part the same staggered entrance, or with
/// [PlassAnimateMode.exit] the same run backwards.
///
/// **`PlAnimateSplitBy.character` is not safe in every script**, and that is the
/// one thing to know before reaching for it. Cutting between letters breaks the
/// shaping between them, so Arabic stops joining. A character is a grapheme, what
/// a reader counts as one, so an emoji, a flag or a Devanagari conjunct stays in
/// one part. [PlAnimateSplitBy.word] keeps the shaping, is the default, and is
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
    this.mode = PlassAnimateMode.enter,
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

  /// Whether each part arrives or leaves.
  ///
  /// [PlassAnimateMode.exit] is the same entrance run backwards, and it is
  /// **held at the end**: a part that has left stays gone rather than snapping
  /// back into place when the run finishes. The parts leave in the order they
  /// would have arrived, and [reverse] turns that round as it does an entrance.
  final PlassAnimateMode mode;

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
    final bool byCharacter = by == PlAnimateSplitBy.character;

    // Cut into words first and, by character, each word into the runs of its
    // characters that stay on one line together.
    final List<List<String>> pieces = <List<String>>[
      for (final String word in splitParts(text, byCharacter: false))
        if (byCharacter) ..._piecesOf(word) else <String>[word],
    ];
    final int count = pieces.fold(0, (int total, List<String> piece) => total + piece.length);
    final WrapAlignment alignment = switch (textAlign) {
      TextAlign.center => WrapAlignment.center,
      TextAlign.right || TextAlign.end => WrapAlignment.end,
      _ => WrapAlignment.start,
    };

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
            final List<Widget> children = <Widget>[];

            // The step counts across the whole line rather than within a word,
            // so the first character of a word follows the last character of the
            // word before.
            int step = 0;

            for (final List<String> piece in pieces) {
              final List<Widget> parts = <Widget>[];

              for (final String part in piece) {
                parts.add(_part(part, step: step, count: count, running: running));
                step += 1;
              }

              // Several characters that stay on one line together are a run of
              // their own, so the line wraps around them rather than between
              // them. A `Wrap` rather than a `Row`: a word wider than the whole
              // line still wraps, as the `Text` of a whole word does, instead of
              // overflowing.
              children.add(
                parts.length == 1 ? parts.single : Wrap(alignment: alignment, children: parts),
              );
            }

            return Wrap(alignment: alignment, children: children);
          },
        ),
      ),
    );
  }

  /// One part, arriving [step] places into a line of [count].
  Widget _part(String part, {required int step, required int count, required bool running}) {
    return PlassAnimateRun(
      mode: mode,
      settings: PlassAnimateSettings(
        duration: duration,
        delay: delay + stagger * (reverse ? count - 1 - step : step),
        curve: curve,
        paused: paused,
        // The line has already decided; each part is only told.
        trigger: PlassAnimateTrigger.manual,
        play: running,
      ),
      child: Text(part, style: style),
      builder: (BuildContext context, double t, Widget? inner) {
        final Offset offset = switch (from) {
          PlassSide.top => Offset(0, -distance * (1 - t)),
          PlassSide.bottom => Offset(0, distance * (1 - t)),
          PlassSide.left => Offset(-distance * (1 - t), 0),
          PlassSide.right => Offset(distance * (1 - t), 0),
        };

        final Widget moved = Transform.translate(offset: offset, child: inner);

        return fade
            ? PlassFiltered(
                colorFilter: null,
                opacity: t.clamp(0, 1),
                alwaysIncludeSemantics: false,
                child: moved,
              )
            : moved;
      },
    );
  }
}

/// A character of a script written without spaces between its words, such as
/// Chinese, Japanese or Thai. Running text in one of these may wrap between any
/// two characters, and so may a split line.
final RegExp _unspacedScript = RegExp(
  r'[\p{Script=Han}\p{Script=Hiragana}\p{Script=Katakana}\p{Script=Bopomofo}'
  r'\p{Script=Thai}\p{Script=Lao}\p{Script=Khmer}\p{Script=Myanmar}]',
  unicode: true,
);

/// A word cut by character, as the runs of its characters that stay on one line
/// together.
///
/// A character of a script written without spaces starts a run of its own, so
/// such a line still wraps between its characters. Anything else stays with the
/// character before it, which keeps a Latin or Hangul word whole and a full stop
/// beside the ideograph it closes.
List<List<String>> _piecesOf(String word) {
  final List<List<String>> pieces = <List<String>>[];

  for (final String character in splitParts(word, byCharacter: true)) {
    if (pieces.isEmpty || _unspacedScript.hasMatch(character)) {
      pieces.add(<String>[character]);
    } else {
      pieces.last.add(character);
    }
  }

  return pieces;
}
