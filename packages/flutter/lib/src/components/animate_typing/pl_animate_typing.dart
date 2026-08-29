/// Text appearing one character at a time.
library;

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/animate.dart';
import 'package:plass_ui/src/types.dart';

/// How long one blink of the caret takes.
const Duration _caretPeriod = Duration(seconds: 1);

/// Text appearing one character at a time.
///
/// ```dart
/// const PlAnimateTyping('npm install plass_ui', speed: 14)
/// ```
///
/// The **whole string reserves its space from the first frame** and what is
/// drawn over it is however much has arrived, so the text around it is never
/// laid out again as the characters come in. A screen reader is given the whole
/// string once and is not made to sit through the performance.
///
/// [repeat], [hold] and [erase] are what make it a loop: type, hold, delete,
/// type again. Without [erase] a repeat clears in one frame, which is right for
/// a line that is being replaced rather than rewritten.
///
/// The advance is by **grapheme**, not by code point. `👩‍👩‍👧` is one character
/// to a reader and seven code points to Dart, and a typewriter that advanced by
/// code points would spend four frames assembling it out of parts that mean
/// nothing on their own. `String.characters` knows where the boundaries are.
class PlAnimateTyping extends StatelessWidget {
  /// Creates a typewriter.
  const PlAnimateTyping(
    this.text, {
    this.speed = 24,
    this.hold = const Duration(milliseconds: 1400),
    this.erase = false,
    this.eraseSpeed,
    this.caret = true,
    this.caretChar = '|',
    this.duration,
    this.delay = Duration.zero,
    this.repeat = 1,
    this.paused = false,
    this.trigger = PlassAnimateTrigger.mount,
    this.play = false,
    this.once = true,
    this.threshold = defaultVisibleThreshold,
    super.key,
  });

  /// The text to type.
  ///
  /// A `String` and not a widget: a typewriter reveals a string one grapheme at
  /// a time, and there is no honest way to reveal half of a link.
  final String text;

  /// How fast it is typed, in characters per second.
  ///
  /// The natural unit here, and the reason it is the default rather than
  /// [duration]: a long paragraph and a short one should be typed at the same
  /// pace, not in the same time.
  final double speed;

  /// How long the finished text is held before it repeats.
  final Duration hold;

  /// Deletes the text again before repeating, rather than clearing it in one
  /// frame. Only means anything when [repeat] is more than once.
  final bool erase;

  /// How fast it is deleted, in characters per second.
  ///
  /// Twice [speed] when nothing says otherwise, which is what a person actually
  /// does.
  final double? eraseSpeed;

  /// The block after the text.
  final bool caret;

  /// What the caret is drawn as.
  final String caretChar;

  /// The time for the **whole string**, overriding [speed].
  ///
  /// Here because a caller who has set a duration on every other `PlAnimate*`
  /// will reach for it here too.
  final Duration? duration;

  /// How long before it starts.
  final Duration delay;

  /// How many times it runs. `null` never stops.
  final int? repeat;

  /// Holds the typewriter where it is.
  final bool paused;

  /// What starts it.
  final PlassAnimateTrigger trigger;

  /// Runs it, when [trigger] is [PlassAnimateTrigger.manual].
  final bool play;

  /// With [PlassAnimateTrigger.visible], whether it runs only the first time.
  final bool once;

  /// With [PlassAnimateTrigger.visible], how much has to be on screen.
  final double threshold;

  @override
  Widget build(BuildContext context) {
    return PlassAnimateGate(
      settings: PlassAnimateSettings(
        duration: duration ?? _caretPeriod,
        repeat: repeat,
        paused: paused,
        trigger: trigger,
        play: play,
        once: once,
        threshold: threshold,
      ),
      builder: (BuildContext context, bool running, int runs, Widget? _) {
        return _Typewriter(
          running: running,
          runs: runs,
          text: text,
          speed: speed,
          hold: hold,
          erase: erase,
          eraseSpeed: eraseSpeed,
          caret: caret,
          caretChar: caretChar,
          duration: duration,
          delay: delay,
          repeat: repeat,
        );
      },
    );
  }
}

/// The performance itself: a chain of timers, and the box the whole string has
/// already reserved.
class _Typewriter extends StatefulWidget {
  const _Typewriter({
    required this.running,
    required this.runs,
    required this.text,
    required this.speed,
    required this.hold,
    required this.erase,
    required this.eraseSpeed,
    required this.caret,
    required this.caretChar,
    required this.duration,
    required this.delay,
    required this.repeat,
  });

  final bool running;
  final int runs;
  final String text;
  final double speed;
  final Duration hold;
  final bool erase;
  final double? eraseSpeed;
  final bool caret;
  final String caretChar;
  final Duration? duration;
  final Duration delay;
  final int? repeat;

  @override
  State<_Typewriter> createState() => _TypewriterState();
}

class _TypewriterState extends State<_Typewriter> {
  late List<String> _graphemes = widget.text.characters.toList();

  int _shown = 0;
  int _pass = 1;
  bool _deleting = false;
  Timer? _next;
  int _drivenRun = -1;

  Duration get _typeDelay {
    final Duration? whole = widget.duration;

    if (whole != null && _graphemes.isNotEmpty) {
      return Duration(microseconds: whole.inMicroseconds ~/ _graphemes.length);
    }

    return Duration(microseconds: (1000000 / (widget.speed <= 0 ? 1 : widget.speed)).round());
  }

  Duration get _deleteDelay {
    final double rate = widget.eraseSpeed ?? widget.speed * 2;

    return Duration(microseconds: (1000000 / (rate <= 0 ? 1 : rate)).round());
  }

  @override
  void didUpdateWidget(_Typewriter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.text != widget.text) {
      // A new string starts a new performance rather than continuing the last.
      _graphemes = widget.text.characters.toList();
      _drivenRun = -1;
      _shown = 0;
    }

    _drive();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _drive());
  }

  @override
  void dispose() {
    _next?.cancel();
    super.dispose();
  }

  /// Starts, resumes or holds the chain, from what the gate is saying.
  void _drive() {
    if (!mounted) {
      return;
    }

    if (!widget.running) {
      _next?.cancel();
      _next = null;

      // Waiting is empty, not finished: a typewriter that showed its whole
      // string until it scrolled into view and then blanked would be worse than
      // no effect at all.
      if (_drivenRun != widget.runs && _shown != 0) {
        setState(() => _shown = 0);
      }

      return;
    }

    if (_drivenRun == widget.runs) {
      // Resuming picks up where the chain was torn down.
      if (_next == null && !(_shown >= _graphemes.length && (widget.repeat ?? 2) <= 1)) {
        _step(_typeDelay);
      }

      return;
    }

    _drivenRun = widget.runs;
    _pass = 1;
    _deleting = false;

    if (_shown != 0) {
      setState(() => _shown = 0);
    }

    _step(widget.delay);
  }

  void _step(Duration wait) {
    _next?.cancel();
    _next = Timer(wait, _tick);
  }

  void _tick() {
    if (!mounted) {
      return;
    }

    final int total = _graphemes.length;
    final int passes = widget.repeat ?? -1;

    if (_deleting) {
      setState(() => _shown -= 1);

      if (_shown <= 0) {
        _deleting = false;
        _pass += 1;
        _step(_typeDelay);

        return;
      }

      _step(_deleteDelay);

      return;
    }

    setState(() => _shown += 1);

    if (_shown < total) {
      _step(_typeDelay);

      return;
    }

    if (passes >= 0 && _pass >= passes) {
      _next = null;

      return;
    }

    if (widget.erase) {
      _deleting = true;
      _step(widget.hold);

      return;
    }

    _pass += 1;
    _next = Timer(widget.hold, () {
      if (!mounted) {
        return;
      }

      setState(() => _shown = 0);
      _step(_typeDelay);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool still = prefersReducedMotion(context);
    // Not "nothing happens" — the text is simply there, which is the only
    // outcome that still delivers what the widget was carrying.
    final String shown = still ? widget.text : _graphemes.take(_shown).join();

    return Semantics(
      label: widget.text,
      container: true,
      child: ExcludeSemantics(
        child: Stack(
          alignment: AlignmentDirectional.topStart,
          children: <Widget>[
            // The whole string holds the box from the first frame, so the text
            // around it is never laid out again as the characters arrive.
            Visibility(
              visible: false,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: Text('${widget.text}${widget.caret ? widget.caretChar : ''}'),
            ),
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(text: shown),
                  if (widget.caret)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: _Caret(char: widget.caretChar, still: still),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The block after the text.
///
/// A hard on/off rather than a fade, because a caret that eases is a caret that
/// looks like it is being rendered slowly.
class _Caret extends StatefulWidget {
  const _Caret({required this.char, required this.still});

  final String char;
  final bool still;

  @override
  State<_Caret> createState() => _CaretState();
}

class _CaretState extends State<_Caret> with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(vsync: this, duration: _caretPeriod)
    ..repeat();

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.still) {
      return Text(widget.char);
    }

    return AnimatedBuilder(
      animation: _blink,
      child: Text(widget.char),
      builder: (BuildContext context, Widget? child) {
        return Opacity(opacity: _blink.value < 0.5 ? 1 : 0, child: child);
      },
    );
  }
}
