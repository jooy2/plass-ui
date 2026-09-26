/// The machinery every `PlAnimate*` widget runs on.
///
/// The Dart half of the React package's `internal/animate.ts`, and the same
/// split: eleven widgets need this and none of them should have to import
/// another.
///
/// ## What is the same
///
/// The vocabulary. `duration`, `delay`, `repeat`, `alternate`, `paused`,
/// `trigger`, `play`, `once` and `threshold` mean exactly what they mean over
/// there, and a `delay` of 200ms has to produce the same wait on a fade as on a
/// marquee.
///
/// **Waiting is a held first frame, not a hidden widget.** A `visible` fade sits
/// at `t = 0` — faded out, laid out, taking its space — until it is scrolled
/// into view. That is what `animation-fill-mode: both` plus a paused
/// `animation-play-state` buys in CSS, and it is the reason an untriggered
/// effect does not flash its finished state first.
///
/// **A run that has finished stays where it ended.** No snapping back.
///
/// ## What had to be said differently
///
/// **Durations are [Duration]s.** Over there they are milliseconds as numbers,
/// because a CSS string invites `'0.4s'` and two units on one screen. Here the
/// framework already has the type, and a package that took `int` milliseconds
/// would be the odd one out in every file that used it.
///
/// **`easing` is `curve`**, and a [Curve] rather than a CSS string.
///
/// **`repeat` is `int?`, and `null` is what never stops.** There is no
/// `'infinite'` to write, and `-1` would be a sentinel a caller has to look up.
/// This is the same trade `PlProgressLinear` already makes with a null `value`.
///
/// **`trigger: visible` watches every scrollable above the widget** rather than
/// an `IntersectionObserver`, and counts it as visible only inside all of their
/// viewports and the screen, which is what the observer measures against. If
/// there is no scrollable above the widget there is nothing to watch — so it
/// runs, exactly as the React build does when the browser has no observer:
/// showing the content beats hiding it forever.
///
/// None of this is exported from `plass_ui.dart`.
library;

import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

/// The default proportion of a widget that has to be on screen before
/// [PlassAnimateTrigger.visible] counts it as visible.
const double defaultVisibleThreshold = 0.2;

/// Everything a caller can say about *when* and *how long*, in one object.
///
/// Passed down rather than spread across nine parameters on every internal
/// widget, because these nine travel together everywhere and a widget that took
/// them one by one would be nine chances to forget one.
@immutable
class PlassAnimateSettings {
  /// Creates one run's settings.
  const PlassAnimateSettings({
    required this.duration,
    this.delay = Duration.zero,
    this.curve,
    this.repeat = 1,
    this.alternate = false,
    this.paused = false,
    this.trigger = PlassAnimateTrigger.mount,
    this.play = false,
    this.once = true,
    this.threshold = defaultVisibleThreshold,
    this.nonce,
  });

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

  /// Runs it, when [trigger] is [PlassAnimateTrigger.manual].
  final bool play;

  /// With [PlassAnimateTrigger.visible], whether it runs only the first time.
  final bool once;

  /// With [PlassAnimateTrigger.visible], how much has to be on screen.
  final double threshold;

  /// A value that plays the effect again whenever it changes, and never on the
  /// first build.
  ///
  /// [play] is a bool, so replaying with it means toggling off and on — two
  /// builds for one event, and a piece of state whose only job is to be flipped
  /// back. A response to something that can happen twice needs the *event*, and
  /// a value that has changed is the closest a widget tree has to one: a count
  /// of failed attempts already is this.
  final Object? nonce;

  /// Whether this run never stops on its own.
  bool get infinite => repeat == null;
}

/// Whether the platform has asked for less movement.
///
/// The one signal both packages read, under two names: `prefers-reduced-motion`
/// there, [MediaQueryData.disableAnimations] here.
bool prefersReducedMotion(BuildContext context) {
  return MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}

/// What [PlassAnimateGate] hands its child: whether the effect is running, and
/// how many times it has been let go.
typedef PlassAnimateGateBuilder =
    Widget Function(BuildContext context, bool running, int runs, Widget? child);

/// Answers one question — *is this running?* — and nothing else.
///
/// The four `trigger` values, `play`, `paused` and the hover handling live here
/// and only here. [PlassAnimateRun] builds on it for the effects that are one
/// curve from a start state to the natural one; the three that write their own
/// motion in Dart — a typewriter, a headline reel, a measured marquee — use it
/// directly, because what they need from the trigger is a boolean and not a
/// number.
class PlassAnimateGate extends StatefulWidget {
  /// Creates a gate.
  const PlassAnimateGate({required this.settings, required this.builder, this.child, super.key});

  /// When to run, and whether it is held.
  final PlassAnimateSettings settings;

  /// Called with whether the animation is running right now, and with how many
  /// times it has been let go — which is what a restart looks like from the
  /// outside, since "running" is already true when one arrives.
  final PlassAnimateGateBuilder builder;

  /// Passed through to [builder] untouched.
  final Widget? child;

  @override
  State<PlassAnimateGate> createState() => PlassAnimateGateState();
}

/// The state behind [PlassAnimateGate]. Public only so the widgets that need a
/// restart can ask for one.
class PlassAnimateGateState extends State<PlassAnimateGate> {
  bool _started = false;

  /// The position of every scrollable above it, while `visible` is waiting.
  final List<ScrollPosition> _watching = <ScrollPosition>[];

  /// How many times it has been let go. Anything rebuilding on a restart —
  /// a typewriter, a reel — reads this rather than trying to diff `started`.
  int get runs => _runs;
  int _runs = 0;

  /// Whether it has been let go at all.
  bool get started => _started;

  @override
  void initState() {
    super.initState();
    _started =
        widget.settings.trigger == PlassAnimateTrigger.mount ||
        (widget.settings.trigger == PlassAnimateTrigger.manual && widget.settings.play);

    if (widget.settings.trigger == PlassAnimateTrigger.visible) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _watchScroll());
    }
  }

  @override
  void didUpdateWidget(PlassAnimateGate oldWidget) {
    super.didUpdateWidget(oldWidget);

    final PlassAnimateSettings now = widget.settings;
    final PlassAnimateSettings before = oldWidget.settings;

    if (now.trigger != before.trigger) {
      _unwatchScroll();

      if (now.trigger == PlassAnimateTrigger.visible) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _watchScroll());
      }

      _set(now.trigger == PlassAnimateTrigger.mount);

      return;
    }

    // `play` is a caller pressing go, and each false → true starts it over.
    if (now.trigger == PlassAnimateTrigger.manual && now.play != before.play) {
      _set(now.play);
    }

    // Compared against the last build rather than held in a field, so the first
    // one is never a change: an effect that played itself on mount would be
    // answering an event that has not happened.
    if (now.nonce != before.nonce) {
      // `restart` rather than `_set(true)`: the second refusal has to play even
      // though the first one already started it.
      restart();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // The scrollables above can change while it waits: the widget is moved
    // under others, or the nearest one takes a new position. Every listener is
    // taken off, and the ones above it now are put on.
    if (_watching.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _watchScroll());
    }
  }

  @override
  void dispose() {
    _unwatchScroll();
    super.dispose();
  }

  void _set(bool value) {
    if (!mounted) {
      return;
    }

    setState(() {
      if (value && !_started) {
        _runs += 1;
      }

      _started = value;
    });
  }

  /// Runs it again from the beginning, whatever it was doing.
  void restart() {
    if (!mounted) {
      return;
    }

    setState(() {
      _started = true;
      _runs += 1;
    });
  }

  /* -------------------------------------------------------------------------
   * `visible`
   * ---------------------------------------------------------------------- */

  void _watchScroll() {
    // Called after a frame, by which time the trigger may have changed.
    if (!mounted || widget.settings.trigger != PlassAnimateTrigger.visible) {
      return;
    }

    _unwatchScroll();

    ScrollableState? scrollable = Scrollable.maybeOf(context);

    if (scrollable == null) {
      // Nothing to watch means no way to know: show it rather than hide it
      // forever, which is what the React build does when the browser has no
      // `IntersectionObserver`.
      _set(true);

      return;
    }

    // Every scrollable above it, not only the nearest. A counter in a row that
    // scrolls sideways is in view along the row long before the page brings the
    // row up, and the React build's observer measures against the whole window.
    //
    // The ones further up are found without `Scrollable.maybeOf`, which would
    // make each of them depend on the one above it, and a scrollable builds a
    // new position whenever a dependency changes.
    while (scrollable != null) {
      _watching.add(scrollable.position..addListener(_checkVisible));
      scrollable = scrollable.context.findAncestorStateOfType<ScrollableState>();
    }

    _checkVisible();
  }

  void _unwatchScroll() {
    for (final ScrollPosition position in _watching) {
      position.removeListener(_checkVisible);
    }

    _watching.clear();
  }

  void _checkVisible() {
    if (!mounted) {
      return;
    }

    final RenderObject? object = context.findRenderObject();

    if (object is! RenderBox || !object.hasSize) {
      return;
    }

    RenderAbstractViewport? viewport = RenderAbstractViewport.maybeOf(object);

    if (viewport == null) {
      _set(true);

      return;
    }

    // Measured in the coordinates of the root, so the widget can be cut down by
    // the screen and then by each viewport it sits in, one after another.
    final Rect own = MatrixUtils.transformRect(
      object.getTransformTo(null),
      Offset.zero & object.size,
    );
    final RenderObject? root = object.owner?.rootNode;
    Rect overlap = root is RenderView ? own.intersect(Offset.zero & root.size) : own;

    while (viewport != null) {
      overlap = overlap.intersect(
        MatrixUtils.transformRect(viewport.getTransformTo(null), viewport.paintBounds),
      );
      viewport = RenderAbstractViewport.maybeOf(viewport.parent);
    }

    final double area = own.width * own.height;
    final double shown = area <= 0
        ? 0
        : (overlap.width.clamp(0, double.infinity) * overlap.height.clamp(0, double.infinity)) /
              area;

    if (shown >= widget.settings.threshold) {
      if (!_started) {
        restart();
      }

      if (widget.settings.once) {
        _unwatchScroll();
      }
    } else if (!widget.settings.once && _started) {
      _set(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget built = widget.builder(
      context,
      _started && !widget.settings.paused,
      _runs,
      widget.child,
    );

    if (widget.settings.trigger != PlassAnimateTrigger.hover) {
      return built;
    }

    return MouseRegion(
      onEnter: (_) => _onPointer(true),
      onExit: (_) => _onPointer(false),
      // Focus counts, or an effect on something keyboard-reachable would never
      // run for a reader who is not holding a mouse. It is the focus of what is
      // inside that counts, as a focus event bubbling up does in the React
      // build: this node takes none itself, so a hover effect on a picture is
      // not a stop in the tab order with nothing for a screen reader to say.
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        includeSemantics: false,
        onFocusChange: _onPointer,
        child: built,
      ),
    );
  }

  void _onPointer(bool on) {
    if (on) {
      restart();

      return;
    }

    // An infinite effect stops when the pointer leaves; a finite one finishes.
    if (widget.settings.infinite) {
      _set(false);
    }
  }
}

/// One animation, from a start state to the widget's natural one.
///
/// The builder is handed `t`, already curved and already flipped for [mode], so
/// a fade is an opacity of `lerpDouble(from, 1, t)` and nothing more. `t` is `0`
/// while the run is waiting to be triggered — the held first frame — and it
/// stays wherever the last pass left it once the count runs out.
///
/// The builder goes on being called at that last frame for as long as the
/// effect is on screen, so an effect draws its opacity through `PlassFiltered`
/// rather than an [Opacity]: an [Opacity] at 1 is still a layer of its own,
/// kept for nothing once an entrance has arrived. What is drawn at 0 stays in
/// the semantics, as CSS `opacity: 0` leaves an element in the accessibility
/// tree: an entrance waiting for its delay or its trigger, and an exit that has
/// gone, are still read, where an [Opacity] left them out.
///
/// Under reduced motion nothing moves in between. `t` is `1` until the moment
/// the run would have started, its delay included, and then wherever the last
/// pass would have left it, so an exit has gone and a turn has turned.
class PlassAnimateRun extends StatefulWidget {
  /// Creates a run.
  const PlassAnimateRun({
    required this.settings,
    required this.builder,
    this.mode = PlassAnimateMode.enter,
    this.child,
    super.key,
  });

  /// When to run, how long, how often.
  final PlassAnimateSettings settings;

  /// Whether the run goes forwards or backwards.
  final PlassAnimateMode mode;

  /// Called with the eased progress of the current pass, `0` to `1`.
  final ValueWidgetBuilder<double> builder;

  /// Passed through to [builder] untouched, so a subtree that does not depend
  /// on `t` is built once rather than on every frame.
  final Widget? child;

  @override
  State<PlassAnimateRun> createState() => _PlassAnimateRunState();
}

class _PlassAnimateRunState extends State<PlassAnimateRun> with SingleTickerProviderStateMixin {
  // Built in `initState` rather than lazily, so that a run the reduced-motion
  // path never touches is still a controller `dispose` can dispose. A `late`
  // field would be created *by* the dispose, which looks up an ancestor on a
  // tree that has already come apart.
  late final AnimationController _controller;

  /// Which pass is running, counting from one.
  int _pass = 1;
  int _startedRuns = -1;

  /// The wait before the first pass, held so it can be called off.
  ///
  /// A `Future.delayed` would do the same job and leave a timer running after
  /// the widget was gone — which a widget test reports as a pending timer, and
  /// which in an app would start an animation on a disposed controller.
  Timer? _waiting;

  /// What is left of the wait for the run that is on.
  ///
  /// A pause during the wait takes off the part of it that has already gone by,
  /// so letting go waits out the rest — rather than the whole delay a second
  /// time, or none of it.
  Duration _delayLeft = Duration.zero;

  /// The frame [_waiting] was started on, which is what the part already gone
  /// by is measured against.
  ///
  /// The frame clock rather than a [Stopwatch], which reads the wall clock: a
  /// widget test moves time forward on a clock of its own, and a stopwatch
  /// would measure nothing while it did.
  Duration _waitingFrom = Duration.zero;

  /// Whether the platform has asked for less movement, as of the last build.
  ///
  /// Kept rather than looked up, because what reads it runs after the frame.
  bool _still = false;

  /// With [_still], whether the run has reached the moment it would have
  /// started and so stands on its last frame. Until then nothing has changed.
  bool _landed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.settings.duration)
      ..addStatusListener(_onStatus);
  }

  @override
  void didUpdateWidget(PlassAnimateRun oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.settings.duration == widget.settings.duration) {
      return;
    }

    _controller.duration = widget.settings.duration;

    // A controller reads its `duration` when a simulation *starts*, so a pass
    // already in flight would finish at the old rate. That matters exactly
    // once, and it is the case a marquee lives in: the strip is measured after
    // the first frame, so the run that has already begun is the run whose
    // duration has just become correct. `forward()` from where it is scales the
    // new duration by what is left, so nothing jumps.
    if (_controller.isAnimating) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _waiting?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onStatus(AnimationStatus status) {
    final int? repeat = widget.settings.repeat;

    // Nothing is run pass by pass under reduced motion; the run lands on its
    // last frame in one step.
    if (_still || (repeat != null && _pass >= repeat)) {
      return;
    }

    if (status == AnimationStatus.completed) {
      _pass += 1;

      if (widget.settings.alternate) {
        _controller.reverse();
      } else {
        _controller.forward(from: 0);
      }
    } else if (status == AnimationStatus.dismissed && widget.settings.alternate && _pass > 1) {
      _pass += 1;
      _controller.forward();
    }
  }

  /// Starts, holds or rewinds, from whatever the gate is currently saying.
  void _drive(bool running, int runs) {
    if (!running) {
      _holdDelay();

      if (_controller.isAnimating) {
        _controller.stop();
      }

      // A run that was never triggered sits on its own first frame; one that
      // was merely paused stays exactly where it is.
      if (_startedRuns != runs) {
        _controller.value = 0;
        _delayLeft = Duration.zero;
      }

      return;
    }

    if (_startedRuns == runs) {
      if (_still && _landed) {
        return;
      }

      if (!_controller.isAnimating && !_controller.isCompleted) {
        // A pause during the wait held the wait too, so what is let go is
        // whatever was left of it. Nothing was left of it once the pass had
        // begun, and this then starts the pass again from where it stopped.
        _startAfter(_delayLeft);
      }

      return;
    }

    _startedRuns = runs;
    _pass = 1;
    _controller.value = 0;
    _setLanded(false);
    _startAfter(widget.settings.delay);
  }

  /// Starts the pass after [wait], or on this frame when there is none left.
  void _startAfter(Duration wait) {
    final int runs = _startedRuns;

    _waiting?.cancel();
    _waiting = null;
    _delayLeft = wait > Duration.zero ? wait : Duration.zero;

    if (_delayLeft == Duration.zero) {
      _go();

      return;
    }

    _waitingFrom = SchedulerBinding.instance.currentSystemFrameTimeStamp;
    _waiting = Timer(_delayLeft, () {
      _waiting = null;
      _delayLeft = Duration.zero;

      if (mounted && _startedRuns == runs) {
        _go();
      }
    });
  }

  /// The moment the run starts: the first pass, or under reduced motion the
  /// last frame at once.
  void _go() {
    if (_still) {
      _setLanded(true);
    } else {
      _controller.forward();
    }
  }

  void _setLanded(bool value) {
    if (_landed != value && mounted) {
      setState(() => _landed = value);
    }
  }

  /// Where the controller stops at the end of the run: a forward pass ends at
  /// `1`, and an alternating run with an even number of passes ends on one that
  /// ran back to `0`. An endless run is one pass, which has a last frame where
  /// the run itself has none.
  double get _end {
    final int passes = widget.settings.repeat ?? 1;

    return widget.settings.alternate && passes > 1 && passes.isEven ? 0 : 1;
  }

  /// Holds a wait that is still running, keeping what is left of it.
  void _holdDelay() {
    if (_waiting == null) {
      return;
    }

    _waiting!.cancel();
    _waiting = null;

    final Duration gone = SchedulerBinding.instance.currentSystemFrameTimeStamp - _waitingFrom;

    _delayLeft = _delayLeft > gone ? _delayLeft - gone : Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    final Curve curve = widget.settings.curve ?? PlassTheme.of(context).motionEase;
    final bool still = prefersReducedMotion(context);

    if (still != _still) {
      if (still) {
        // Asked for while a run was going, or after one had finished: from
        // here it stands on its last frame, unless it is still waiting out its
        // delay, which lands it when the wait is over.
        _controller.stop();
        _landed = _startedRuns >= 0 && _waiting == null;
      } else if (_landed) {
        // And given back after a run had landed: the controller is put where
        // the run left the screen, so nothing jumps back to where it began.
        // Nothing is listening to it yet — the builder that does is only in the
        // tree while the platform allows movement.
        _controller.value = _end;
      }

      _still = still;
    }

    return PlassAnimateGate(
      settings: widget.settings,
      child: widget.child,
      builder: (BuildContext context, bool running, int runs, Widget? child) {
        // After the frame rather than during it, because starting a controller
        // inside a build is a build that schedules a build.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _drive(running, runs);
          }
        });

        // The reduced-motion answer is the *opposite* of the loading
        // indicators': a spinner that stops is lying about whether anything is
        // happening, while an effect that does not move has still delivered
        // what it was carrying — for an entrance the content, and for an exit
        // its absence. So the run is kept and the movement is taken out of it.
        // Nothing changes until the moment it would have started, its delay
        // included, and then it stands on its last frame. Until that moment
        // the content is simply there, which is `1` whichever way the effect
        // runs: the end of an entrance, and the start of an exit.
        if (still) {
          final double end = _landed ? _end : 1;

          return widget.builder(
            context,
            _landed && widget.mode == PlassAnimateMode.exit ? 1 - end : end,
            child,
          );
        }

        return AnimatedBuilder(
          animation: _controller,
          child: child,
          builder: (BuildContext context, Widget? inner) {
            final double eased = curve.transform(_controller.value.clamp(0, 1));

            return widget.builder(
              context,
              widget.mode == PlassAnimateMode.exit ? 1 - eased : eased,
              inner,
            );
          },
        );
      },
    );
  }
}

/// Where a slide starts, given the edge it comes from.
///
/// [PlassSide] is physical everywhere in the package and it stays physical
/// here: something arriving from the top arrives from the top in every writing
/// direction. `null` distance means the widget's own size, which is what
/// [FractionalTranslation] is for and why this returns a fraction as well.
({Offset pixels, Offset fraction}) slideOffset(PlassSide from, double? distance) {
  final double amount = distance ?? 1;

  switch (from) {
    case PlassSide.top:
      return (pixels: Offset(0, -amount), fraction: const Offset(0, -1));
    case PlassSide.bottom:
      return (pixels: Offset(0, amount), fraction: const Offset(0, 1));
    case PlassSide.left:
      return (pixels: Offset(-amount, 0), fraction: const Offset(-1, 0));
    case PlassSide.right:
      return (pixels: Offset(amount, 0), fraction: const Offset(1, 0));
  }
}

/// Moves [child] by [offset] logical pixels, or by [fraction] of its own size
/// when no explicit distance was given.
///
/// Two widgets because a fraction of the widget's own size is only knowable at
/// paint time, and [FractionalTranslation] is the framework's answer to exactly
/// that. Both are always there, one of them moving by nothing, so a distance
/// that comes or goes changes neither the shape of the tree above [child] nor
/// what Flutter keeps of it; a translation paints no layer of its own. Neither
/// is a [Transform] on a *control*: what moves here is content a caller asked
/// to have moved.
Widget translateBy({
  required Offset offset,
  required Offset fraction,
  required bool useFraction,
  required Widget child,
}) {
  return FractionalTranslation(
    translation: useFraction ? fraction : Offset.zero,
    child: Transform.translate(offset: useFraction ? Offset.zero : offset, child: child),
  );
}
