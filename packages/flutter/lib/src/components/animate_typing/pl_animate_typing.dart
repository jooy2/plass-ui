/// Text appearing one character at a time.
library;

import 'dart:async';

import 'package:flutter/scheduler.dart';
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
      // Told nothing of `paused`, so what it hands over is whether the trigger
      // has let the typing go. The typewriter reads the pause itself, because a
      // pause holds the line where it is, and a trigger taking the typing back
      // empties it.
      settings: PlassAnimateSettings(
        duration: duration ?? _caretPeriod,
        repeat: repeat,
        trigger: trigger,
        play: play,
        once: once,
        threshold: threshold,
      ),
      builder: (BuildContext context, bool started, int runs, Widget? _) {
        return _Typewriter(
          started: started,
          paused: paused,
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
    required this.started,
    required this.paused,
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

  /// Whether the trigger has let the typing go.
  final bool started;

  /// Whether the caller is holding it where it is.
  final bool paused;
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
  /// The line being typed, which is the one drawn.
  ///
  /// Taken up from [_Typewriter.text] when a run starts rather than when the
  /// text changes, so a pause holds what is on the screen through a new string
  /// as well: replaced at once, a pause given "World" with "Hel" typed emptied
  /// the line.
  late List<String> _graphemes = widget.text.characters.toList();

  int _shown = 0;

  /// Which pass of [_Typewriter.repeat] it is on, counted when the next one
  /// starts rather than when this one is typed out. Counted before the hold,
  /// a typewriter paused during the hold between two passes came back to a
  /// pass that was already over, and stopped on it.
  int _pass = 1;
  bool _deleting = false;

  /// Whether the typed-out line is being held before the next pass.
  ///
  /// Kept beside [_deleting] so a chain torn down during the hold goes on with
  /// the hold when it is let go, rather than starting to delete at once.
  bool _holding = false;

  /// What is left of the wait the chain is in, or `null` when it is in none:
  /// the delay before the first character, the wait before the next one, the
  /// hold, or the wait before the first character of the next pass.
  ///
  /// A chain torn down during any of them goes on with what was left of it
  /// when it is let go: let go during the delay or between two passes, it used
  /// to wait a character's time, and between two characters the whole of one.
  Duration? _waitLeft;

  /// The frame the wait, or what was left of it, started on, which is what the
  /// part already gone by is measured against. The frame clock, for the reason
  /// `PlassAnimateRun` measures its wait on it: a widget test moves time
  /// forward on a clock of its own, and a stopwatch would measure nothing.
  Duration? _waitFrom;

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
      // A new string starts a new performance rather than continuing the last,
      // which takes it up when it starts: at once, or once a pause lets it go.
      _drivenRun = -1;
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

    if (!widget.started) {
      _next?.cancel();
      _next = null;

      // Waiting is empty, not finished: a typewriter that showed its whole
      // string until it scrolled into view and then blanked would be worse than
      // no effect at all. That holds for one its trigger has taken back as well,
      // a `visible` one that is not `once` gone off screen or `play` turned off:
      // it waits for its next run as one that was never let go does, and that
      // run types the line from its first character.
      _drivenRun = -1;

      if (_shown != 0) {
        setState(() => _shown = 0);
      }

      return;
    }

    if (widget.paused) {
      final Duration? left = _waitLeft;

      if (left != null && _next != null) {
        final Duration gone = _waitFrom == null
            ? Duration.zero
            : SchedulerBinding.instance.currentSystemFrameTimeStamp - _waitFrom!;

        _waitLeft = left > gone ? left - gone : Duration.zero;
      }

      _next?.cancel();
      _next = null;

      // A pause holds the line where it is, and goes on holding it through a
      // new run, a hover the pointer makes again while it is paused for one,
      // and through a new string: either starts once the pause lets it go, and
      // types the line from its first character, as it does in the React build.
      return;
    }

    if (_drivenRun == widget.runs) {
      if (_next != null) {
        return;
      }

      // What was left of the wait it was let go in, if it was in one.
      final Duration? left = _waitLeft;

      if (_holding) {
        // Resumed during the hold between two passes.
        _wait(left ?? widget.hold, _endHold);
      } else if (_shown >= _graphemes.length && !_deleting) {
        // Resumed with the line typed out and no hold begun, which is the end
        // of the last pass, or one that `repeat` has since been raised past.
        _finish();
      } else {
        // The next character, in the direction it was going.
        _wait(left ?? (_deleting ? _deleteDelay : _typeDelay), _tick);
      }

      return;
    }

    _drivenRun = widget.runs;
    _graphemes = widget.text.characters.toList();
    _pass = 1;
    _deleting = false;
    _holding = false;
    _waitLeft = null;

    if (_shown != 0) {
      setState(() => _shown = 0);
    }

    _wait(widget.delay, _tick);
  }

  /// Waits [wait], then does [next]. Every wait in the chain goes through here,
  /// so a chain torn down during any of them knows what was left of it.
  void _wait(Duration wait, VoidCallback next) {
    _next?.cancel();
    _waitLeft = wait;
    _next = Timer(wait, () {
      _next = null;
      _waitLeft = null;
      next();
    });

    final SchedulerBinding scheduler = SchedulerBinding.instance;

    if (scheduler.schedulerPhase != SchedulerPhase.idle) {
      // Started inside a frame, whose time is the time it started.
      _waitFrom = scheduler.currentSystemFrameTimeStamp;

      return;
    }

    // Started from a timer, between two frames, when the last frame's time is
    // already behind it: measured from the frame that draws what it waits on.
    _waitFrom = null;
    scheduler.addPostFrameCallback((_) {
      _waitFrom ??= scheduler.currentSystemFrameTimeStamp;
    });
    scheduler.scheduleFrame();
  }

  void _tick() {
    if (!mounted) {
      return;
    }

    final int total = _graphemes.length;

    if (_deleting) {
      setState(() => _shown -= 1);

      if (_shown <= 0) {
        _deleting = false;
        _pass += 1;
        _wait(_typeDelay, _tick);

        return;
      }

      _wait(_deleteDelay, _tick);

      return;
    }

    setState(() => _shown += 1);

    if (_shown < total) {
      _wait(_typeDelay, _tick);

      return;
    }

    _finish();
  }

  /// The line is typed out: holds it, then deletes it or clears it for the next
  /// pass, unless this was the last one. The pass is counted once the next one
  /// starts, so a chain built again during the hold holds and goes on rather
  /// than skipping a pass or playing one twice.
  void _finish() {
    final int passes = widget.repeat ?? -1;

    if (passes >= 0 && _pass >= passes) {
      _next = null;

      return;
    }

    _holding = true;
    _wait(widget.hold, _endHold);
  }

  /// The hold is over: deletes the line, or clears it for the next pass.
  void _endHold() {
    if (!mounted) {
      return;
    }

    _holding = false;

    if (widget.erase) {
      _deleting = true;
      _tick();

      return;
    }

    _pass += 1;
    setState(() => _shown = 0);
    _wait(_typeDelay, _tick);
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
  /// Built in [initState] rather than on first read. Under reduced motion the
  /// build never reads it, which left [dispose] to build it, and a ticker
  /// cannot be made for an element that is already leaving the tree.
  late final AnimationController _blink;

  @override
  void didUpdateWidget(_Caret oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.still != widget.still) {
      _syncBlink();
    }
  }

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(vsync: this, duration: _caretPeriod);
    _syncBlink();
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  /// Blinks only while the caret is drawn blinking. A still caret ticks nothing.
  void _syncBlink() {
    if (widget.still) {
      _blink.stop();
    } else if (!_blink.isAnimating) {
      _blink.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    // The paragraph the caret sits in already scales the widgets inside it by
    // the reader's text size, so a scale here as well would draw the caret at
    // that size twice over.
    final Widget caret = Text(widget.char, textScaler: TextScaler.noScaling);

    if (widget.still) {
      return caret;
    }

    return AnimatedBuilder(
      animation: _blink,
      child: caret,
      builder: (BuildContext context, Widget? child) {
        return Opacity(opacity: _blink.value < 0.5 ? 1 : 0, child: child);
      },
    );
  }
}
