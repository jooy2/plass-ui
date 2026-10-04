/// A number counting up to what it is.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/animate.dart';
import 'package:plass_ui/src/types.dart';

/// A number counting up to what it is.
///
/// ```dart
/// PlAnimateCounter(
///   value: 48120,
///   formatValue: (double value) => NumberFormat.decimalPattern().format(value.round()),
/// )
/// ```
///
/// The one effect in the group that animates **content** rather than a box: what
/// moves is the figure itself, one frame at a time, from [from] to [value].
///
/// **It starts when it is seen, not when it is built**, which is the one place a
/// `PlAnimate*` here departs from the rest. An entrance played off screen has
/// still delivered its content; a count that ran off screen delivered a number
/// that was already sitting there when the reader arrived.
///
/// **What a screen reader hears is the final number, once.** The ticking figure
/// is excluded from the semantics and the answer is put on the node instead,
/// because a number changing sixty times a second in the semantics tree is
/// either silence or sixty announcements, and neither is the figure.
///
/// [formatValue] is a callback rather than an options object, for
/// `PlProgressLinear.formatValue`'s reason: there is no `Intl` in the framework,
/// and a package that pulled `package:intl` in to provide one would be making a
/// dependency decision on its consumer's behalf.
class PlAnimateCounter extends StatefulWidget {
  /// Creates a counter.
  const PlAnimateCounter({
    required this.value,
    this.from = 0,
    this.formatValue,
    this.style,
    this.duration = const Duration(milliseconds: 1200),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.paused = false,
    this.trigger = PlassAnimateTrigger.visible,
    this.play = false,
    this.once = true,
    this.threshold = defaultVisibleThreshold,
    super.key,
  });

  /// The number it arrives at, and the one a screen reader is told.
  final double value;

  /// The number the first count starts from, and a replay of it: a new
  /// [play], a [PlassAnimateTrigger.visible] trigger seen again, a hover. A new
  /// [value] counts on from the figure on screen instead.
  final double from;

  /// How the number is written.
  ///
  /// Without it the figure is rounded and written out plainly, which is the only
  /// formatting that holds for a number nobody described.
  final String Function(double value)? formatValue;

  /// The text style the figure is drawn in. The surrounding one when it is not
  /// given.
  final TextStyle? style;

  /// How long the count takes.
  final Duration duration;

  /// How long it waits before starting.
  final Duration delay;

  /// The shape of the count. It eases out by default, which is what a number
  /// arriving should do: quick enough to read as counting, slow enough at the
  /// end to land on the figure rather than snap to it.
  final Curve curve;

  /// Holds the count where it is.
  final bool paused;

  /// What starts the count. [PlassAnimateTrigger.visible] here, unlike every
  /// other effect in the set — see the class doc.
  final PlassAnimateTrigger trigger;

  /// Runs it, when [trigger] is [PlassAnimateTrigger.manual].
  final bool play;

  /// With [PlassAnimateTrigger.visible], whether it counts only the first time.
  final bool once;

  /// With [PlassAnimateTrigger.visible], how much of the widget has to be on
  /// screen before it counts as visible, from `0` to `1`.
  final double threshold;

  @override
  State<PlAnimateCounter> createState() => _PlAnimateCounterState();
}

class _PlAnimateCounterState extends State<PlAnimateCounter> {
  /// Where the count runs from.
  ///
  /// The first count starts at [PlAnimateCounter.from], and so does a replay of
  /// it. A new [PlAnimateCounter.value] is a figure that moved, and it counts on
  /// from the figure on screen at that moment, the one the last count landed on
  /// or the frame a count still running had got to, so a dashboard figure that
  /// changes counts from the old figure to the new one rather than from `from`
  /// every time. A new `from` starts there.
  late double _origin = widget.from;

  /// The figure last drawn, which a new value counts on from.
  late double _shown = widget.from;

  /// The figure a new value counts on from, held until its run begins.
  ///
  /// The run starts after the frame the value arrives in, and until it does the
  /// builder is handed the progress the last run left: a count that had landed
  /// would draw the new value at once and then drop back to where it starts.
  double? _waiting;

  @override
  void didUpdateWidget(PlAnimateCounter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.from != oldWidget.from) {
      _origin = widget.from;

      if (_waiting != null || widget.value != oldWidget.value) {
        _waiting = widget.from;
      }
    } else if (widget.value != oldWidget.value) {
      _waiting = _shown;
    }
  }

  /// A run is beginning: the count a new value asked for, or a replay.
  void _onRun() {
    _origin = _waiting ?? widget.from;
    _waiting = null;
  }

  String _format(double at) {
    final String Function(double value)? formatValue = widget.formatValue;

    return formatValue == null ? at.round().toString() : formatValue(at);
  }

  @override
  Widget build(BuildContext context) {
    final bool still = prefersReducedMotion(context);

    return Semantics(
      // The answer, once. What is drawn is excluded below.
      label: _format(widget.value),
      container: true,
      child: ExcludeSemantics(
        child: PlassAnimateRun(
          settings: PlassAnimateSettings(
            duration: widget.duration,
            delay: widget.delay,
            curve: widget.curve,
            paused: widget.paused,
            trigger: widget.trigger,
            play: widget.play,
            once: widget.once,
            threshold: widget.threshold,
            // A new target is a new count, wherever the old one had got to.
            nonce: widget.value,
          ),
          onRun: _onRun,
          builder: (BuildContext context, double t, Widget? child) {
            final double? waiting = still ? null : _waiting;

            _shown = waiting ?? _origin + (widget.value - _origin) * t;

            return Text(_format(_shown), style: widget.style);
          },
        ),
      ),
    );
  }
}
