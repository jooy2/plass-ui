/// Content scrolling steadily past, forever.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/animate.dart';
import 'package:plass_ui/src/types.dart';

/// How long one pass takes before the strip has been measured.
///
/// A sane number rather than zero, which would finish immediately.
const Duration _unmeasured = Duration(seconds: 12);

/// Content scrolling steadily past, forever.
///
/// ```dart
/// PlAnimateMarquee(
///   gap: 24,
///   speed: 45,
///   children: <Widget>[for (final String name in names) PlChip(child: Text(name))],
/// )
/// ```
///
/// The content is laid down twice, and each copy travels exactly its own length
/// plus the gap — so the moment the first copy has left, the second is standing
/// precisely where it began. There is no seam, no jump and no frame where the
/// strip is empty.
///
/// What is measured is only the **speed**. A duration would mean a strip of
/// four logos and a strip of forty crossing the same box in the same time, with
/// the long one becoming unreadable; [speed] is logical pixels per second, so
/// both move at the pace of a reader instead. The strip is re-measured whenever
/// it changes size.
///
/// [pauseOnHover] is on by default and is not decoration: content moving past a
/// pointer cannot be pressed reliably, and a link inside a marquee that never
/// stops is a link nobody can follow.
///
/// Only the first copy is read out. The rest are behind [ExcludeSemantics], or
/// a screen reader would announce everything on the strip as many times as it
/// was laid down.
class PlAnimateMarquee extends StatefulWidget {
  /// Creates a marquee.
  const PlAnimateMarquee({
    required this.children,
    this.orientation = PlassOrientation.horizontal,
    this.reverse = false,
    this.speed = 60,
    this.gap = 32,
    this.copies = 2,
    this.pauseOnHover = true,
    this.duration,
    this.delay = Duration.zero,
    this.curve,
    this.repeat,
    this.alternate = false,
    this.paused = false,
    this.trigger = PlassAnimateTrigger.mount,
    this.play = false,
    this.once = true,
    this.threshold = defaultVisibleThreshold,
    super.key,
  });

  /// The things that scroll past.
  final List<Widget> children;

  /// Which way the strip runs.
  final PlassOrientation orientation;

  /// Runs it the other way — left to right, or bottom to top.
  final bool reverse;

  /// How fast the content travels, in logical pixels per second.
  final double speed;

  /// The gap between items, and between the last item and the first of the next
  /// pass, in logical pixels.
  final double gap;

  /// How many copies of the content are laid end to end.
  ///
  /// Two is enough for anything at least as long as its box; raise it when the
  /// content is short enough to leave a hole behind itself.
  final int copies;

  /// Stops while the pointer is on it, so something scrolling past can actually
  /// be read or pressed.
  final bool pauseOnHover;

  /// How long one pass takes. Left out, [speed] and the measurement decide.
  final Duration? duration;

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
  State<PlAnimateMarquee> createState() => _PlAnimateMarqueeState();
}

class _PlAnimateMarqueeState extends State<PlAnimateMarquee> {
  final GlobalKey _track = GlobalKey();

  /// How far one copy has to go: its own length plus the gap after it.
  double _travel = 0;
  bool _hovered = false;

  bool get _vertical => widget.orientation == PlassOrientation.vertical;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(PlAnimateMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    if (!mounted) {
      return;
    }

    final RenderObject? object = _track.currentContext?.findRenderObject();

    if (object is! RenderBox || !object.hasSize) {
      return;
    }

    final double next = (_vertical ? object.size.height : object.size.width) + widget.gap;

    if ((next - _travel).abs() > 0.5) {
      setState(() => _travel = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool still = prefersReducedMotion(context);
    final Duration duration =
        widget.duration ??
        (_travel > 0
            ? Duration(milliseconds: (_travel / widget.speed * 1000).round())
            : _unmeasured);

    Widget strip = PlassAnimateRun(
      mode: widget.reverse ? PlassAnimateMode.exit : PlassAnimateMode.enter,
      settings: PlassAnimateSettings(
        duration: duration,
        delay: widget.delay,
        // Linear unless a caller insists otherwise: an eased marquee slows at
        // both ends of a loop that has no ends, which reads as a stutter.
        curve: widget.curve ?? Curves.linear,
        repeat: widget.repeat,
        alternate: widget.alternate,
        paused: widget.paused || (widget.pauseOnHover && _hovered),
        trigger: widget.trigger,
        play: widget.play,
        once: widget.once,
        threshold: widget.threshold,
      ),
      child: _copies(),
      builder: (BuildContext context, double t, Widget? inner) {
        // A marquee's reduced-motion answer is the *opposite* of an entrance's:
        // what an entrance has delivered is its finished frame, and what a
        // strip has delivered is the content standing where it started.
        final double shift = (still ? 0 : t) * _travel;

        return Transform.translate(
          offset: _vertical ? Offset(0, -shift) : Offset(-shift, 0),
          child: inner,
        );
      },
    );

    // The strip is longer than its box by design, so it has to be laid out
    // against an unbounded main axis and clipped — a `ClipRect` alone would
    // clip the paint and leave a `RenderFlex` asserting that it overflowed.
    strip = UnconstrainedBox(
      constrainedAxis: _vertical ? Axis.horizontal : Axis.vertical,
      alignment: _vertical ? Alignment.topCenter : Alignment.centerLeft,
      clipBehavior: Clip.hardEdge,
      child: strip,
    );

    if (widget.pauseOnHover) {
      strip = MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: strip,
      );
    }

    return strip;
  }

  /// The copies, laid end to end with a gap between them.
  Widget _copies() {
    final Axis axis = _vertical ? Axis.vertical : Axis.horizontal;

    return Flex(
      direction: axis,
      mainAxisSize: MainAxisSize.min,
      spacing: widget.gap,
      children: <Widget>[
        for (int index = 0; index < (widget.copies < 1 ? 1 : widget.copies); index += 1)
          if (index == 0)
            KeyedSubtree(key: _track, child: _copy(axis))
          else
            ExcludeSemantics(child: _copy(axis)),
      ],
    );
  }

  /// One pass of the content.
  Widget _copy(Axis axis) {
    return Flex(
      direction: axis,
      mainAxisSize: MainAxisSize.min,
      spacing: widget.gap,
      children: widget.children,
    );
  }
}
