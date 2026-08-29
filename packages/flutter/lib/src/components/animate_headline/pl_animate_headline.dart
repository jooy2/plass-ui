/// One line replacing the one above it, on a timer.
library;

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/animate.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// One line replacing the one above it, on a timer.
///
/// ```dart
/// const PlAnimateHeadline(
///   children: <Widget>[Text('ships on Friday'), Text('reads like prose')],
/// )
/// ```
///
/// Every line sits in the **same cell**, so the box is as tall as the longest of
/// them from the first frame and never resizes as the reel turns — which is the
/// whole difficulty with this effect, and the reason the lines that are not
/// showing keep their space rather than being taken out of the layout.
///
/// It is deliberately not a ticker. A line comes up, it stops, and it is held
/// long enough to read; [interval] is counted from the moment a line *arrives*
/// rather than from the start of the cycle, so raising [duration] does not
/// quietly eat the reading time.
///
/// Use it for a set of phrases where any one of them would have done — three
/// ways of saying what a product is, a rotating set of customer names. What it
/// is not for is content a reader has to see, because there is no guarantee they
/// are looking during the two seconds it is up, and a screen reader is given the
/// line that happens to be showing rather than the set.
class PlAnimateHeadline extends StatelessWidget {
  /// Creates a reel.
  const PlAnimateHeadline({
    required this.children,
    this.interval = const Duration(milliseconds: 2600),
    this.index,
    this.defaultIndex = 0,
    this.onIndexChange,
    this.loop = true,
    this.rise,
    this.duration = const Duration(milliseconds: 460),
    this.delay = Duration.zero,
    this.curve,
    this.repeat,
    this.paused = false,
    this.trigger = PlassAnimateTrigger.mount,
    this.play = false,
    this.once = true,
    this.threshold = defaultVisibleThreshold,
    super.key,
  });

  /// The lines, in the order they should be read.
  final List<Widget> children;

  /// How long each line is held before the next one comes up.
  ///
  /// Counted from the moment a line arrives, so it is reading time rather than
  /// a cycle length.
  final Duration interval;

  /// Which line is showing.
  ///
  /// Pass it to drive the reel yourself — from a step in a form, a tab, or a
  /// timer of your own — and the reel stops running one of its own, because a
  /// controlled headline is somebody else's clock and a second one underneath
  /// it would fight for the same state.
  final int? index;

  /// Where an uncontrolled reel starts.
  final int defaultIndex;

  /// Called with the line that has just come up.
  final ValueChanged<int>? onIndexChange;

  /// Starts again after the last line.
  ///
  /// Off, the reel stops on the last one and stays there.
  final bool loop;

  /// How far a line travels as it comes up or leaves, in logical pixels.
  ///
  /// `null` — the default — is one line's **own** height, which is what makes it
  /// read as a reel rather than as a crossfade.
  final double? rise;

  /// How long one swap takes.
  final Duration duration;

  /// How long before the reel starts turning at all.
  ///
  /// Added once rather than to every line — which is what an [interval] is.
  final Duration delay;

  /// The easing curve. The house curve when nothing says otherwise.
  final Curve? curve;

  /// How many times it runs. `null` never stops.
  final int? repeat;

  /// Holds the reel where it is.
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
        duration: duration,
        repeat: repeat,
        paused: paused,
        trigger: trigger,
        play: play,
        once: once,
        threshold: threshold,
      ),
      builder: (BuildContext context, bool running, int runs, Widget? _) {
        return _Reel(
          running: running,
          interval: interval,
          index: index,
          defaultIndex: defaultIndex,
          onIndexChange: onIndexChange,
          loop: loop,
          rise: rise,
          duration: duration,
          delay: delay,
          curve: curve,
          children: children,
        );
      },
    );
  }
}

/// The reel itself: which line is up, which one is on its way out, and the
/// timer that turns it.
class _Reel extends StatefulWidget {
  const _Reel({
    required this.running,
    required this.interval,
    required this.index,
    required this.defaultIndex,
    required this.onIndexChange,
    required this.loop,
    required this.rise,
    required this.duration,
    required this.delay,
    required this.curve,
    required this.children,
  });

  final bool running;
  final List<Widget> children;
  final Duration interval;
  final int? index;
  final int defaultIndex;
  final ValueChanged<int>? onIndexChange;
  final bool loop;
  final double? rise;
  final Duration duration;
  final Duration delay;
  final Curve? curve;

  @override
  State<_Reel> createState() => _ReelState();
}

class _ReelState extends State<_Reel> with SingleTickerProviderStateMixin {
  late final AnimationController _swap = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late int _uncontrolled = widget.defaultIndex;

  /// The line on its way out. Cleared once its animation has had its time.
  int? _leaving;

  Timer? _turn;

  /// Whether the reel has turned at all, which is what [PlAnimateHeadline.delay]
  /// is counted against.
  bool _turned = false;

  int get _count => widget.children.length;

  int get _active {
    final int wanted = widget.index ?? _uncontrolled;

    return wanted.clamp(0, _count > 0 ? _count - 1 : 0);
  }

  @override
  void initState() {
    super.initState();
    _swap.value = 1;
    _schedule();
  }

  @override
  void didUpdateWidget(_Reel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _swap.duration = widget.duration;

    final int before = (oldWidget.index ?? _uncontrolled).clamp(
      0,
      oldWidget.children.isEmpty ? 0 : oldWidget.children.length - 1,
    );

    if (before != _active) {
      _showFrom(before);
    }

    _schedule();
  }

  @override
  void dispose() {
    _turn?.cancel();
    _swap.dispose();
    super.dispose();
  }

  /// Runs one swap: [previous] leaves upward while the current line comes up.
  void _showFrom(int previous) {
    setState(() => _leaving = previous);
    _swap
      ..value = 0
      ..forward().whenCompleteOrCancel(() {
        if (mounted) {
          setState(() => _leaving = null);
        }
      });
  }

  /// Arms the timer that turns the reel, or takes it away.
  ///
  /// The reel only turns on its own when it was not handed an index: a
  /// controlled headline is somebody else's timer.
  void _schedule() {
    _turn?.cancel();

    if (widget.index != null || _count < 2 || !widget.running) {
      return;
    }

    if (!widget.loop && _active == _count - 1) {
      return;
    }

    _turn = Timer(widget.interval + (_turned ? Duration.zero : widget.delay), () {
      if (!mounted) {
        return;
      }

      _turned = true;
      _advance();
    });
  }

  void _advance() {
    final int previous = _active;
    final int next = previous + 1 >= _count ? 0 : previous + 1;

    if (next == 0 && !widget.loop) {
      return;
    }

    setState(() => _uncontrolled = next);
    widget.onIndexChange?.call(next);
    _showFrom(previous);
    _schedule();
  }

  @override
  Widget build(BuildContext context) {
    final bool still = prefersReducedMotion(context);
    final Curve curve = widget.curve ?? PlassTokens.ease;

    return ClipRect(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          for (int position = 0; position < _count; position += 1)
            _line(position, curve: curve, still: still),
        ],
      ),
    );
  }

  /// One line, in the same cell as every other.
  ///
  /// The ones that are not showing are drawn at zero opacity rather than taken
  /// out, which is what keeps the box as tall as the longest of them and stops
  /// it resizing as the reel turns.
  Widget _line(int position, {required Curve curve, required bool still}) {
    final bool active = position == _active;
    final bool leaving = position == _leaving && !still;

    return AnimatedBuilder(
      animation: _swap,
      child: widget.children[position],
      builder: (BuildContext context, Widget? inner) {
        if (!active && !leaving) {
          return Opacity(opacity: 0, child: inner);
        }

        final double t = curve.transform(_swap.value.clamp(0, 1));
        // Coming up from below, or leaving upward: one line replacing the one
        // above it, which is the gesture the whole effect is named for.
        final double travel = active ? 1 - t : -t;
        final double opacity = still ? (active ? 1 : 0) : (active ? t : 1 - t);
        final Widget faded = Opacity(opacity: opacity.clamp(0, 1), child: inner);

        return widget.rise == null
            ? FractionalTranslation(translation: Offset(0, travel), child: faded)
            : Transform.translate(offset: Offset(0, travel * widget.rise!), child: faded);
      },
    );
  }
}
