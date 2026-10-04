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
/// **An endless effect rests off screen through the same watch.** It is off
/// screen once none of it is inside those viewports and the screen, and that
/// is all it knows: an effect hidden some other way, by a widget laid over it
/// or moved off the screen without a scroll, goes on running, and one with no
/// scrollable above it never rests.
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
    this.target,
    bool? endless,
  }) : _endless = endless;

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

  /// What the effect arrives at: a counter's figure, a scramble's line. A new
  /// one runs the effect again from its start while the trigger has it going,
  /// and never on the first build.
  ///
  /// Unlike [nonce], it never starts a run the trigger is holding back. A
  /// counter waiting to be scrolled to, or for [play], whose figure changes is
  /// still waiting: what changed is what it will count to, and counting there
  /// and then is what the trigger was there to stop.
  final Object? target;

  final bool? _endless;

  /// Whether this run never stops on its own.
  bool get infinite => repeat == null;

  /// Whether the effect runs for ever once it has started, and so **rests
  /// while it is off screen**, going on from the frame it stopped on when it is
  /// back. Whether [repeat] never stops, unless it was said otherwise.
  ///
  /// Flutter goes on drawing an animation nobody can see, a frame at a time,
  /// and a timer goes on firing, so an endless one left running further up a
  /// page costs the reader something on every frame of the rest of the visit.
  /// A finite one is left alone: it finishes, and an entrance that played off
  /// screen has still delivered its content.
  ///
  /// Said otherwise where [repeat] does not answer: a reel that turns on its
  /// own timer whatever its [repeat], the parts of a set whose own gate already
  /// watches the set, and a run whose widget holds the pause itself, which is
  /// already still while it is paused.
  bool get endless => _endless ?? infinite;
}

/// Whether the platform has asked for less movement.
///
/// The one signal both packages read, under two names: `prefers-reduced-motion`
/// there, [MediaQueryData.disableAnimations] here.
bool prefersReducedMotion(BuildContext context) {
  return MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}

/// What [PlassAnimateGate] hands its child: whether the effect is running, how
/// many times it has been let go, and whether it is resting off screen.
typedef PlassAnimateGateBuilder =
    Widget Function(BuildContext context, bool running, int runs, bool resting, Widget? child);

/// Answers one question — *is this running?* — and nothing else.
///
/// The four `trigger` values, `play`, `paused`, the hover handling and the rest
/// an endless effect takes off screen live here and only here.
/// [PlassAnimateRun] builds on it for the effects that are one curve from a
/// start state to the natural one; the three that write their own motion in
/// Dart — a typewriter, a headline reel, a measured marquee — use it directly,
/// because what they need from the trigger is a boolean and not a number.
class PlassAnimateGate extends StatefulWidget {
  /// Creates a gate.
  const PlassAnimateGate({required this.settings, required this.builder, this.child, super.key});

  /// When to run, and whether it is held.
  final PlassAnimateSettings settings;

  /// Called with whether the animation is running right now, with how many
  /// times it has been let go — which is what a restart looks like from the
  /// outside, since "running" is already true when one arrives — and with
  /// whether it is resting off screen.
  ///
  /// An effect that rests is not running, and its trigger has still let it go.
  /// A widget that keeps its own frames holds them then as a pause does,
  /// rather than waiting for its next run as it does when its trigger takes it
  /// back.
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

  /// The position of every scrollable above it, while something has to know
  /// whether it is on screen: `visible` waiting, or an endless effect running.
  final List<ScrollPosition> _watching = <ScrollPosition>[];

  /// Whether the scrollables above it have been looked for, or will be once
  /// the frame is over, for the watch that is on. Set when none were found as
  /// well, so a widget with nothing above it to scroll is not looked up again
  /// on every change.
  bool _watched = false;

  /// Whether a measurement of where it is on screen is waiting for the end of
  /// the frame.
  bool _checkPending = false;

  /// Whether it was an effect that rests off screen when the watch was last
  /// brought up to date, so one that has just become one is measured at once.
  bool _restWatch = false;

  /// How many times it has been let go. Anything rebuilding on a restart —
  /// a typewriter, a reel — reads this rather than trying to diff `started`.
  int get runs => _runs;
  int _runs = 0;

  /// Whether it has been let go at all.
  bool get started => _started;

  /// Whether an endless effect is resting because it is off screen.
  bool get resting => _resting;
  bool _resting = false;

  /// Whether a `visible` trigger still has to look for it on screen: until it
  /// first finds it with `once`, and for as long as it is there without.
  bool get _waitsToBeSeen =>
      widget.settings.trigger == PlassAnimateTrigger.visible && !(widget.settings.once && _started);

  /// Whether it rests while it is off screen: an endless effect, and only
  /// while it is running. One that is waiting or held is already still and has
  /// nothing to rest from, and a `visible` trigger that is not `once` already
  /// takes the effect back when it leaves the view.
  bool get _restsOffScreen =>
      widget.settings.endless &&
      _started &&
      !widget.settings.paused &&
      !(widget.settings.trigger == PlassAnimateTrigger.visible && !widget.settings.once);

  @override
  void initState() {
    super.initState();
    _started =
        widget.settings.trigger == PlassAnimateTrigger.mount ||
        (widget.settings.trigger == PlassAnimateTrigger.manual && widget.settings.play);
    _updateWatch();
  }

  @override
  void didUpdateWidget(PlassAnimateGate oldWidget) {
    super.didUpdateWidget(oldWidget);

    final PlassAnimateSettings now = widget.settings;
    final PlassAnimateSettings before = oldWidget.settings;

    if (now.trigger != before.trigger) {
      // `_set` watches again whatever the new trigger needs watched.
      _unwatchScroll();
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

    // After `play`, so a `play` turned off in the same build has already held
    // it back when this asks.
    if (now.target != before.target && _started) {
      restart();
    }

    // A pause, `once` or `endless` can change what has to be watched.
    _updateWatch();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // The scrollables above can change while it is watched: the widget is
    // moved under others, or the nearest one takes a new position. Every
    // listener is taken off, and the ones above it now are put on.
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
    _updateWatch();
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
    _updateWatch();
  }

  void _setResting(bool value) {
    if (_resting != value && mounted) {
      setState(() => _resting = value);
    }
  }

  /* -------------------------------------------------------------------------
   * On screen: `visible`, and an endless effect resting
   * ---------------------------------------------------------------------- */

  /// Watches the scrollables above it while anything has to know whether it is
  /// on screen, and stops once nothing does.
  void _updateWatch() {
    final bool rests = _restsOffScreen;
    final bool began = rests && !_restWatch;

    _restWatch = rests;

    if (!rests) {
      _setResting(false);
    }

    if (!rests && !_waitsToBeSeen) {
      _unwatchScroll();

      return;
    }

    if (!_watched) {
      // After the frame, because what is measured is the box it is laid out in.
      _watched = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _watchScroll());
    } else if (began) {
      // Already watched, for a `visible` trigger that has just let it go: it
      // is measured once now, and then on every scroll.
      _scheduleCheck();
    }
  }

  void _watchScroll() {
    // Called after a frame, by which time nothing may need it any more.
    if (!mounted) {
      return;
    }

    _unwatchScroll();

    if (!_waitsToBeSeen && !_restsOffScreen) {
      return;
    }

    _watched = true;

    ScrollableState? scrollable = Scrollable.maybeOf(context);

    if (scrollable == null) {
      // Nothing to watch means no way to know: show it rather than hide it
      // forever, which is what the React build does when the browser has no
      // `IntersectionObserver`. For the same reason an endless effect never
      // rests here.
      if (_waitsToBeSeen) {
        _set(true);
      }

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
      _watching.add(scrollable.position..addListener(_onScroll));
      scrollable = scrollable.context.findAncestorStateOfType<ScrollableState>();
    }

    if (_waitsToBeSeen) {
      _checkVisible();
    }

    // After the check above, which may have just let it go. This runs after a
    // frame, so the layout it reads is already this frame's.
    _checkRest();
  }

  void _unwatchScroll() {
    for (final ScrollPosition position in _watching) {
      position.removeListener(_onScroll);
    }

    _watching.clear();
    _watched = false;
  }

  void _onScroll() {
    if (_waitsToBeSeen || _restsOffScreen) {
      _scheduleCheck();
    }
  }

  /// Measures where it is on screen once the frame has been laid out: whether
  /// a `visible` trigger sees it, and whether an endless effect is off screen.
  ///
  /// Not at once: a scroll position tells its listeners it has moved before
  /// the frame lays the content out where it has moved to, and a list places
  /// its items only then. Measured at once, an effect the last step of a
  /// scroll brought on screen was found where the step before had left it,
  /// and waited for its trigger, or rested on the screen, until the next
  /// scroll. However many scrolls the frame takes, it is measured once.
  void _scheduleCheck() {
    if (_checkPending) {
      return;
    }

    _checkPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPending = false;

      if (!mounted) {
        return;
      }

      if (_waitsToBeSeen) {
        _checkVisible();
      }

      // After the check above, which may have just let it go.
      _checkRest();
    });
  }

  void _checkVisible() {
    if (!mounted) {
      return;
    }

    final RenderObject? object = context.findRenderObject();

    if (object is! RenderBox || !object.hasSize) {
      return;
    }

    final RenderAbstractViewport? viewport = RenderAbstractViewport.maybeOf(object);

    if (viewport == null) {
      _set(true);

      return;
    }

    final double shown = _shareOnScreen(object, viewport).shown;

    // `> 0` as well, as the React build asks of its own measurement: zero is
    // the least that counts as seen, rather than a reason to start something
    // that is nowhere near the screen. Once it has been seen with `once`, the
    // restart stops the watch, unless an endless effect rests through it.
    if (shown > 0 && shown >= widget.settings.threshold) {
      if (!_started) {
        restart();
      }
    } else if (!widget.settings.once && _started) {
      _set(false);
    }
  }

  void _checkRest() {
    if (!mounted || !_restsOffScreen) {
      return;
    }

    final RenderObject? object = context.findRenderObject();

    if (object is! RenderBox || !object.hasSize) {
      return;
    }

    final RenderAbstractViewport? viewport = RenderAbstractViewport.maybeOf(object);

    if (viewport == null) {
      _setResting(false);

      return;
    }

    final ({double area, double shown}) share = _shareOnScreen(object, viewport);

    // Off screen is none of it showing, as the React build's observer says it.
    // A box of no size says nothing about where what it holds is drawn, so it
    // never rests on that.
    _setResting(share.area > 0 && share.shown <= 0);
  }

  /// The area of [object], and the share of it the screen and every viewport
  /// above it, from [viewport] up, leave showing, from `0` to `1`.
  ({double area, double shown}) _shareOnScreen(RenderBox object, RenderAbstractViewport viewport) {
    // Measured in the coordinates of the root, so the widget can be cut down by
    // the screen and then by each viewport it sits in, one after another.
    final Rect own = MatrixUtils.transformRect(
      object.getTransformTo(null),
      Offset.zero & object.size,
    );
    final RenderObject? root = object.owner?.rootNode;
    Rect overlap = root is RenderView ? own.intersect(Offset.zero & root.size) : own;
    RenderAbstractViewport? next = viewport;

    while (next != null) {
      overlap = overlap.intersect(
        MatrixUtils.transformRect(next.getTransformTo(null), next.paintBounds),
      );
      next = RenderAbstractViewport.maybeOf(next.parent);
    }

    final double area = own.width * own.height;
    final double shown = area <= 0
        ? 0
        : (overlap.width.clamp(0, double.infinity) * overlap.height.clamp(0, double.infinity)) /
              area;

    return (area: area, shown: shown);
  }

  @override
  Widget build(BuildContext context) {
    final Widget built = widget.builder(
      context,
      _started && !widget.settings.paused && !_resting,
      _runs,
      _resting,
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
/// pass would have left it, so an exit has gone and a turn has turned. When the
/// platform gives movement back, a run that landed stays where it is, except an
/// endless one, which goes on from wherever its passes would have got to by
/// then.
class PlassAnimateRun extends StatefulWidget {
  /// Creates a run.
  const PlassAnimateRun({
    required this.settings,
    required this.builder,
    this.mode = PlassAnimateMode.enter,
    this.onRun,
    this.rewindsWhenWaiting = false,
    this.onWait,
    this.child,
    super.key,
  });

  /// When to run, how long, how often.
  final PlassAnimateSettings settings;

  /// Whether the run goes forwards or backwards.
  final PlassAnimateMode mode;

  /// Called with the eased progress of the current pass, `0` to `1`.
  final ValueWidgetBuilder<double> builder;

  /// Called as each run begins, before [builder] is handed its first frame:
  /// the first run, and every one a restart, a new `play`, a new `nonce` or a
  /// new `target` starts after it.
  ///
  /// Until then [builder] is still handed the progress the last run left, so an
  /// effect whose start depends on why it is starting again, as a counter's
  /// does on whether its target moved, can tell the frames apart with this.
  final VoidCallback? onRun;

  /// Whether the run goes back to its first frame when its trigger takes it
  /// back, rather than holding the frame it was on as a pause does: a
  /// `visible` trigger that is not `once` seeing it leave the screen, or `play`
  /// turned off.
  ///
  /// For an effect that draws its frames itself, as the React build's counter
  /// and scramble do: waiting there is their first frame, whether or not they
  /// have run before, so one that comes back on screen starts from it rather
  /// than drawing where it was and jumping back on the next frame. A keyframe
  /// there holds the frame it was on, which is what a run without this does.
  final bool rewindsWhenWaiting;

  /// Called when [rewindsWhenWaiting] takes the run back to its first frame,
  /// before [builder] is handed it, so an effect whose first frame depends on
  /// how the last run started, as a counter's does, can put it back.
  final VoidCallback? onWait;

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

  /// How far into its passes the run had got when it landed: nowhere yet when
  /// it landed at the end of its delay, and as far as it had moved when the
  /// setting arrived while it was moving.
  ///
  /// With [_landedFrom], the clock an endless run goes on from when the
  /// platform gives movement back, which is the clock a keyframe keeps. The
  /// browser goes on counting a finished animation's time from when it began,
  /// so an endless one given its passes back stands wherever that count has
  /// got to. A pause takes the count back to where the run finished, which is
  /// where it landed, and it counts on from there once it is let go.
  Duration _landedAt = Duration.zero;

  /// The frame from which a landed run has been let go, and so counting on
  /// from [_landedAt]. `null` while it is held, which counts nothing.
  Duration? _landedFrom;

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
    // duration has just become correct. `_go()` from where it is starts the
    // pass again the way it was going, so one on its way back goes on back,
    // and scales the new duration by what is left, so nothing jumps.
    if (_controller.isAnimating) {
      _go();
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

  /// Starts, holds or rewinds, from whatever the gate is currently saying:
  /// whether the trigger has let the run go, how many times it has, and
  /// whether an endless run is resting off screen, which holds it as a pause
  /// does.
  void _drive(bool started, int runs, {required bool resting}) {
    if (!started || widget.settings.paused || resting) {
      _holdDelay();
      _landedFrom = null;

      if (_controller.isAnimating) {
        _controller.stop();
      }

      // A run that was never triggered sits on its own first frame; one that
      // was merely paused, or is resting, stays exactly where it is.
      if (_startedRuns != runs) {
        _controller.value = 0;
        _delayLeft = Duration.zero;
      } else if (!started && widget.rewindsWhenWaiting) {
        // Taken back by its trigger, it waits for the next run as one that
        // was never triggered does, and that run starts it again.
        _startedRuns = -1;
        _controller.value = 0;
        _delayLeft = Duration.zero;
        widget.onWait?.call();
      }

      return;
    }

    if (_startedRuns == runs) {
      if (_still && _landed) {
        _landedFrom ??= SchedulerBinding.instance.currentSystemFrameTimeStamp;

        return;
      }

      // A run that has finished stays where it ended, wherever that is: at
      // `0` after an alternating run with an even number of passes, which is
      // also where one that has not begun stands, so where the controller
      // stopped does not tell the two apart on its own. An endless run never
      // finishes, so one standing at the end of a pass goes on.
      if (!_controller.isAnimating && !_finished) {
        // A pause during the wait held the wait too, so what is let go is
        // whatever was left of it. Nothing was left of it once the pass had
        // begun, and this then starts the pass again from where it stopped.
        _startAfter(_delayLeft);
      }

      return;
    }

    _startedRuns = runs;
    _pass = 1;
    widget.onRun?.call();
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

    final Duration from = SchedulerBinding.instance.currentSystemFrameTimeStamp;

    _waitingFrom = from;
    _waiting = Timer(_delayLeft, () {
      _waiting = null;
      _delayLeft = Duration.zero;

      if (mounted && _startedRuns == runs) {
        // The frame the wait ends on, which the frame clock has not reached
        // yet: a timer fires between frames.
        _go(at: from + wait);
      }
    });
  }

  /// The moment the run starts or goes on: the first pass, the pass a pause or
  /// a rest stopped, or under reduced motion the last frame at once, which the
  /// run lands on [at], this frame unless said otherwise.
  ///
  /// Every other pass of an alternating run goes back, so a pass stopped on its
  /// way back goes on back, as a paused keyframe goes on the way it was going,
  /// and turns at the end of it as it would have.
  void _go({Duration? at}) {
    if (_still) {
      _landedAt = _runTime;
      _landedFrom = at ?? SchedulerBinding.instance.currentSystemFrameTimeStamp;
      _setLanded(true);
    } else if (widget.settings.alternate && _pass.isEven) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  /// How far into its passes the run stands, as time: every pass behind it,
  /// and as much of the one it is on as it has run through, out or back.
  Duration get _runTime {
    final double through = widget.settings.alternate && _pass.isEven
        ? 1 - _controller.value
        : _controller.value;

    return widget.settings.duration * (_pass - 1 + through);
  }

  /// Puts the run [time] into its passes, as [_runTime] measures them: on the
  /// pass that time falls in, and as far through it.
  void _place(Duration time) {
    final int length = widget.settings.duration.inMicroseconds;
    final int into = time > Duration.zero ? time.inMicroseconds : 0;

    if (length <= 0) {
      _pass = 1;
      _controller.value = 0;

      return;
    }

    final double through = into.remainder(length) / length;

    _pass = into ~/ length + 1;
    _controller.value = widget.settings.alternate && _pass.isEven ? 1 - through : through;
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

  /// Whether the run has played every pass it was given: it is on the last one,
  /// and stopped where that one ends.
  ///
  /// A run that has not begun is on its first pass, so it is never finished,
  /// even at `0`. An endless run never is.
  bool get _finished {
    final int? repeat = widget.settings.repeat;

    return repeat != null &&
        _pass >= repeat &&
        !_controller.isAnimating &&
        _controller.value == _end;
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

        // As far as it has moved, counting on from this frame if it is let
        // go, which `_drive` says once the frame is over.
        if (_landed) {
          _landedAt = _runTime;
          _landedFrom = null;
        }
      } else if (_landed) {
        // And given back after a run had landed. Nothing is listening to the
        // controller yet — the builder that does is only in the tree while the
        // platform allows movement.
        final int? repeat = widget.settings.repeat;

        if (repeat == null) {
          // An endless run has no last frame to stay on. It goes on from
          // where its passes would have got to by now, as a keyframe that is
          // given its passes back does, rather than standing at the end of
          // the one it landed on and never moving again.
          final Duration? from = _landedFrom;
          final Duration since = from == null
              ? Duration.zero
              : SchedulerBinding.instance.currentSystemFrameTimeStamp - from;

          _place(_landedAt + since);
        } else {
          // A run that ends is put where it left the screen, so nothing jumps
          // back to where it began. On its last pass as well, since a landed
          // run has played them all, so one that landed at `0` is `_finished`
          // rather than a run at its first frame still to go.
          if (repeat > _pass) {
            _pass = repeat;
          }

          _controller.value = _end;
        }
      }

      _still = still;
    }

    return PlassAnimateGate(
      // Told nothing of `paused`, so what it hands over is whether the trigger
      // has let the run go. `_drive` reads the pause itself, because a pause
      // holds the frame the run is on, and a trigger taking the run back may
      // not.
      settings: _withoutPause(widget.settings),
      child: widget.child,
      builder: (BuildContext context, bool running, int runs, bool resting, Widget? child) {
        // Resting off screen, it is not running and its trigger has still let
        // it go.
        final bool started = running || resting;

        // After the frame rather than during it, because starting a controller
        // inside a build is a build that schedules a build.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _drive(started, runs, resting: resting);
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

/// [settings] with `paused` off, and the same object when it already is.
///
/// Not `endless` either while it is paused: the run is already still, and has
/// nothing to rest from off screen.
PlassAnimateSettings _withoutPause(PlassAnimateSettings settings) {
  if (!settings.paused) {
    return settings;
  }

  return PlassAnimateSettings(
    duration: settings.duration,
    delay: settings.delay,
    curve: settings.curve,
    repeat: settings.repeat,
    alternate: settings.alternate,
    trigger: settings.trigger,
    play: settings.play,
    once: settings.once,
    threshold: settings.threshold,
    nonce: settings.nonce,
    target: settings.target,
    endless: false,
  );
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
