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

import 'package:flutter/gestures.dart' show GestureBinding;
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

/// The time a wait or a run is measured on. Read inside a frame.
///
/// The frame clock, [SchedulerBinding.currentSystemFrameTimeStamp], rather
/// than a [Stopwatch]: a widget test moves time forward on a clock of its own,
/// which the frame clock follows and a stopwatch does not. The frame clock
/// reads zero until the engine has stamped a frame, though, and an app's first
/// build is drawn on a warm-up frame that has no stamp. A wait begun there and
/// measured on a later frame counted all the time the engine's clock had run
/// before the app did, so a `delay` held by a pause partway through was
/// already over when it was let go.
///
/// Until the first stamp, the time is counted from the first read on the
/// binding's sampling clock, which a widget test moves forward as well. Once a
/// stamp arrives, the frame clock is moved onto that count, so a time read
/// before it and one read after it are measured against each other.
Duration animationNow() {
  final Duration stamp = SchedulerBinding.instance.currentSystemFrameTimeStamp;

  Stopwatch? unstamped = _unstamped;

  if (stamp == Duration.zero) {
    if (unstamped == null) {
      unstamped = GestureBinding.instance.samplingClock.stopwatch()..start();
      _unstamped = unstamped;
    }

    return unstamped.elapsed;
  }

  if (unstamped != null) {
    _unstamped = null;
    _stampShift = unstamped.elapsed - stamp;
  }

  return stamp + _stampShift;
}

/// What [animationNow] has counted since its first read before the frame
/// clock had a stamp, or `null` when no such read is waiting for one.
Stopwatch? _unstamped;

/// How far [animationNow] moves the frame clock to line it up with what was
/// counted before it had a stamp.
Duration _stampShift = Duration.zero;

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
/// platform gives movement back, a run that landed stays where it is, except
/// one that was endless when it landed, which goes on from wherever its passes
/// would have got to by then under whatever `repeat` it has now, or with
/// [restartsWithMotion] starts again from its first frame and waits out its
/// delay, unless it has been given a `repeat` since. One that `paused` holds
/// keeps what reduced motion showed until the pause is let go, and goes on
/// from there: the frame it landed on, or its content when the pause held it
/// before it would have started, which then stands on its first frame and
/// waits out what is left of its delay.
///
/// A new `repeat` is counted against the time the run has been going, as a
/// keyframe counts a new `animation-iteration-count`. A run that has finished
/// and is given more passes goes on from wherever that time puts it, and a run
/// that is past the end of a lower count stands where that count ends. That
/// time goes on through reduced motion for a run that had finished before the
/// setting arrived, which is put where it says once the setting goes, so more
/// passes given while the setting was on play from there. A pass in flight
/// that the new count still holds goes on as it was. A run that ends and
/// landed under reduced motion stands on the last frame of the new count
/// instead, or at the end of one pass when it is given `repeat: null`, whether
/// the setting is still on or not, until it runs again.
class PlassAnimateRun extends StatefulWidget {
  /// Creates a run.
  const PlassAnimateRun({
    required this.settings,
    required this.builder,
    this.mode = PlassAnimateMode.enter,
    this.stillBuilder,
    this.onRun,
    this.rewindsWhenWaiting = false,
    this.onWait,
    this.restartsWithMotion = false,
    this.held = false,
    this.child,
    super.key,
  });

  /// When to run, how long, how often.
  final PlassAnimateSettings settings;

  /// Whether the run goes forwards or backwards.
  final PlassAnimateMode mode;

  /// Called with the eased progress of the current pass, `0` to `1`.
  final ValueWidgetBuilder<double> builder;

  /// Draws what reduced motion shows, for an effect that shows something
  /// other than a frame of its run there, as a light shows an even glow rather
  /// than its arc. Handed the `t` [builder] would be.
  ///
  /// Called under reduced motion, and while `paused` keeps what it showed on
  /// the screen once the platform gives movement back. [builder] draws it when
  /// this is not given.
  final ValueWidgetBuilder<double>? stillBuilder;

  /// Called as each run begins, before [builder] is handed its first frame:
  /// the first run, and every one a restart, a new `play`, a new `nonce` or a
  /// new `target` starts after it.
  ///
  /// Called during the build that begins the run, so it may change what
  /// [builder] reads and nothing else. A run held by `paused`, or resting off
  /// screen, as it is started begins once it is let go, and [builder] is
  /// handed its first frame until then, so an effect whose start depends on
  /// why it is starting again, as a counter's does on whether its target
  /// moved, can tell the frames apart with this.
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

  /// Whether an endless run that landed under reduced motion starts again
  /// from its first frame when the platform gives movement back, and waits
  /// out its `delay` before it moves, rather than going on from wherever its
  /// passes would have got to by then. One that `paused` holds keeps what
  /// reduced motion showed until the pause is let go, and starts then.
  ///
  /// For an effect the React build switches off under the setting, as it does
  /// a strip and a light: its keyframe is not there under reduced motion, so
  /// it starts from the beginning, after its delay, once the setting goes. One
  /// given a finite `repeat` while the setting is on stays where that count
  /// ends instead, as the keyframe a count gives it back lands under the
  /// setting.
  final bool restartsWithMotion;

  /// Holds the run where it is, its delay as well, as `paused` does, without
  /// being a pause: what reduced motion showed is not kept on the screen for
  /// it when the platform gives movement back, and an endless run still rests
  /// off screen through it.
  ///
  /// For a hold the React build makes in the stylesheet rather than through
  /// its gate, as a strip under the pointer: `animation-play-state: paused`
  /// stops the keyframe where it is, and the stylesheet goes on drawing
  /// whatever the setting says.
  final bool held;

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

  /// The last run whose first frame the build has drawn, on the build the
  /// trigger let it go in.
  int _drawnRuns = -1;

  /// The last run [PlassAnimateRun.onRun] was called for.
  int _announcedRuns = -1;

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
  /// by is measured against, on [animationNow].
  Duration _waitingFrom = Duration.zero;

  /// Whether the platform has asked for less movement, as of the last build.
  ///
  /// Kept rather than looked up, because what reads it runs after the frame.
  bool _still = false;

  /// With [_still], whether the run has reached the moment it would have
  /// started and so stands on its last frame. Until then nothing has changed.
  bool _landed = false;

  /// Without [_still], whether an endless run that landed still stands on the
  /// frame it landed on, because `paused` held it when the platform gave
  /// movement back. A pause holds what is on the screen, so the run is put
  /// where its clock says only once the pause is let go.
  bool _keepsLanding = false;

  /// Without [_still], whether a run that had not landed still shows what
  /// reduced motion drew before it would have started, its content, because
  /// `paused` held it when the platform gave movement back. A pause holds what
  /// is on the screen, so the run stands on its first frame, and waits out
  /// what is left of its delay, only once the pause is let go.
  bool _keepsStill = false;

  /// Without [_still], whether a run that landed still shows what reduced
  /// motion drew, because `paused` held it when the platform gave movement
  /// back, while it already stands where it goes on from once the pause is
  /// let go: the end of a run that ends, where it stays, or the first frame of
  /// an endless run that [PlassAnimateRun.restartsWithMotion] starts again,
  /// which then waits out its delay.
  bool _keepsLanded = false;

  /// Whether a run that ends landed under reduced motion and has not run
  /// since, which keeps it on the last frame of whatever count it has until
  /// it runs again, whether the setting is still on or has gone, as the React
  /// build holds a keyframe that landed on the timing it landed with. A new
  /// `repeat` stands it on the last frame of the new count and plays none of
  /// the passes it adds, and `repeat: null` at the end of one pass, as reduced
  /// motion shows an endless run.
  ///
  /// A run the setting stops partway lands there, as a keyframe the setting
  /// runs in no time ends. One that had already finished moving did not land
  /// under the setting, and a new `repeat` is counted against its clock.
  bool _staysLanded = false;

  /// With [_still], whether the run had finished moving before the setting
  /// arrived, and so did not land under it. Its clock goes on counting from
  /// when the run began, through the setting, as the clock of a keyframe that
  /// has ended does, and a pause stops it where the run ended, as a paused
  /// keyframe holds the time it ended on. When the setting goes, the run is
  /// put where that clock says under whatever count it has by then, and plays
  /// on from there when that count holds passes it has not played.
  bool _countsOn = false;

  /// How far into its passes the run stood at [_clockFrom], as time: the clock
  /// a keyframe keeps, which the browser goes on counting from when the run
  /// began, through every pass and past the end of the last, for as long as
  /// the run is let go.
  ///
  /// Put where the run stands whenever it starts or goes on, and whenever it
  /// is held, since a pause stops the count where the keyframe stands: at the
  /// end of a run that has finished, however long ago that was, and where it
  /// landed under reduced motion, which is nowhere yet when it landed at the
  /// end of its delay and as far as it had moved when the setting arrived
  /// while it was moving. It counts on from there once it is let go. A run
  /// that had finished before the setting arrived is not put anywhere then,
  /// and its clock goes on as it was.
  ///
  /// Read when the run has no frame of its own to go on from: a run that
  /// landed endless, when the platform gives movement back or the pause that
  /// kept it on its landing is let go, and a run that has finished, when it is
  /// given a new `repeat` or the setting it finished before goes. Each stands
  /// wherever the count has got to.
  Duration _clockAt = Duration.zero;

  /// The frame from which the run has been let go, and so counting on from
  /// [_clockAt]. `null` while it is held, which counts nothing.
  Duration? _clockFrom;

  /// Whether the run is putting the controller somewhere itself, through
  /// [_setValue], which [_onStatus] leaves alone.
  bool _placing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.settings.duration)
      ..addStatusListener(_onStatus);
  }

  @override
  void didUpdateWidget(PlassAnimateRun oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.settings.duration != widget.settings.duration) {
      _controller.duration = widget.settings.duration;

      // A controller reads its `duration` when a simulation *starts*, so a
      // pass already in flight would finish at the old rate. That matters
      // exactly once, and it is the case a marquee lives in: the strip is
      // measured after the first frame, so the run that has already begun is
      // the run whose duration has just become correct. `_go()` from where it
      // is starts the pass again the way it was going, so one on its way back
      // goes on back, and scales the new duration by what is left, so nothing
      // jumps.
      if (_controller.isAnimating) {
        _go();
      }
    }

    if (oldWidget.settings.delay != widget.settings.delay) {
      _redate(oldWidget.settings.delay);
    }

    if (oldWidget.settings.repeat != widget.settings.repeat) {
      _recount(oldWidget.settings.repeat);
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
    // last frame in one step. A bound the run put the controller on itself is
    // not the end of a pass either: only one a pass ran into is.
    if (_placing || _still || (repeat != null && _pass >= repeat)) {
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
  /// does. [PlassAnimateRun.held] holds it the same way.
  void _drive(bool started, int runs, {required bool resting}) {
    // Let go of the pause that kept what reduced motion drew before the run
    // would have started, or after it landed where it now goes on from, or
    // taken back by its trigger, a run draws its own frames again.
    if (!started || !widget.settings.paused) {
      _keepsStill = false;
      _keepsLanded = false;
    }

    if (!started || widget.settings.paused || widget.held || resting) {
      _holdDelay();
      _clockFrom = null;

      if (_controller.isAnimating) {
        _controller.stop();
      }

      // A run that was never triggered sits on its own first frame; one that
      // was merely paused, or is resting, stays exactly where it is. One
      // started again while it is held has not begun either, and waits as one
      // that was never triggered does: not where the run before it landed
      // under reduced motion, and not landed by a setting that arrives before
      // it is let go.
      if (_startedRuns != runs) {
        _startedRuns = -1;
        _setValue(0);
        _delayLeft = Duration.zero;
        _keepsLanding = false;
        _staysLanded = false;
        _countsOn = false;
        _setLanded(false);
      } else if (!started && widget.rewindsWhenWaiting) {
        // Taken back by its trigger, it waits for the next run as one that
        // was never triggered does, and that run starts it again.
        _startedRuns = -1;
        _setValue(0);
        _delayLeft = Duration.zero;
        _keepsLanding = false;
        widget.onWait?.call();
      }

      // The clock stops where the run stands, which for one that has not
      // begun is its start. A run that landed under reduced motion already
      // stands where its clock stopped, and so does one a pause keeps on the
      // frame it landed on. One that had finished before the setting arrived
      // did not land under it, and stops where it ended.
      if ((!_still || _countsOn) && !_keepsLanding) {
        _clockAt = _startedRuns == runs ? _runTime : Duration.zero;
      }

      return;
    }

    if (_startedRuns == runs) {
      if (_still && _landed) {
        _clockFrom ??= animationNow();

        return;
      }

      // A wait that is under way is left to run. A build that changed nothing
      // about it is no reason to wait the whole delay again, and a new delay
      // has already been measured against it.
      if (_waiting != null) {
        return;
      }

      // A run that has finished stays where it ended, wherever that is: at
      // `0` after an alternating run with an even number of passes, which is
      // also where one that has not begun stands, so where the controller
      // stopped does not tell the two apart on its own. An endless run never
      // finishes, so one standing at the end of a pass goes on. Under reduced
      // motion a run that has not landed yet lands, even where a new delay
      // already finished it. A run that landed under reduced motion stays
      // where it stands until it runs again, also when it has been given
      // `repeat: null` since, which leaves it no last frame of its own.
      final bool standing = _finished || _staysLanded;

      if (!_controller.isAnimating && (_still || !standing)) {
        // A pause during the wait held the wait too, so what is let go is
        // whatever was left of it. Nothing was left of it once the pass had
        // begun, and this then starts the pass again from where it stopped.
        _startAfter(_delayLeft);
      } else if (standing) {
        // Its clock counts on from where it stopped, past the end of the run.
        _clockFrom ??= animationNow();
      }

      return;
    }

    _startedRuns = runs;
    _pass = 1;
    _announce(runs);
    _setValue(0);
    _clockAt = Duration.zero;
    _clockFrom = null;
    _keepsLanding = false;
    _staysLanded = false;
    _countsOn = false;
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

    final Duration from = animationNow();

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
    _clockAt = _runTime;
    _clockFrom = at ?? animationNow();

    // Landed, a run that ends stays on its last frame until it runs again,
    // and one that moves is not standing on a landing any more.
    _staysLanded = _still && widget.settings.repeat != null;

    if (_still) {
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
  /// pass that time falls in, and as far through it, or at the end of the run
  /// once that time has gone past it.
  void _place(Duration time) {
    final int length = widget.settings.duration.inMicroseconds;
    final int into = time > Duration.zero ? time.inMicroseconds : 0;
    final int? repeat = widget.settings.repeat;

    if (length <= 0) {
      _pass = 1;
      _setValue(0);

      return;
    }

    if (repeat != null && into >= length * (repeat < 1 ? 1 : repeat)) {
      _pass = repeat < 1 ? 1 : repeat;
      _setValue(_end);

      return;
    }

    final double through = into.remainder(length) / length;

    _pass = into ~/ length + 1;
    _setValue(widget.settings.alternate && _pass.isEven ? 1 - through : through);
  }

  /// Puts the controller on [value] without counting a pass or starting one.
  ///
  /// A controller tells its status listeners when its value is set on one of
  /// its bounds, as it does when a pass runs into one, and [_onStatus] takes
  /// either for the end of a pass. A run that a restart held by a pause puts
  /// on its first frame, or one that [_place] puts where a pass begins, would
  /// count a pass it has not played and set off, while it is paused, or end
  /// its passes early.
  void _setValue(double value) {
    _placing = true;
    _controller.value = value;
    _placing = false;
  }

  void _setLanded(bool value) {
    if (_landed != value && mounted) {
      setState(() => _landed = value);
    }
  }

  /// Calls [PlassAnimateRun.onRun] for [runs], once.
  void _announce(int runs) {
    if (_announcedRuns != runs) {
      _announcedRuns = runs;
      widget.onRun?.call();
    }
  }

  /// Puts a run the trigger has just let go on its first frame, during the
  /// build that lets it go, so that build draws it, as a keyframe rewound
  /// before the paint is drawn: an exit that landed under reduced motion is
  /// there again, and a run stopped anywhere stands where it begins. [_drive]
  /// starts it after the frame, or holds it there while it is held, and a run
  /// with no `delay` lands under reduced motion on the next frame, as one does
  /// on its first build.
  ///
  /// Only what the build reads is set here, and without `setState`, which
  /// would mark this widget, above the gate whose build calls it.
  void _drawFirstFrame(int runs) {
    _drawnRuns = runs;
    _setValue(0);
    _landed = false;
    _staysLanded = false;
    _countsOn = false;
    _keepsLanding = false;
    _keepsStill = false;
    _keepsLanded = false;
  }

  /// Where the controller stops at the end of the run, as [_endOf] says it
  /// for the run's own `repeat`.
  double get _end => _endOf(widget.settings.repeat);

  /// Where the controller stops at the end of a run of [repeat] passes: a
  /// forward pass ends at `1`, and an alternating run with an even number of
  /// passes ends on one that ran back to `0`. An endless run is one pass,
  /// which has a last frame where the run itself has none.
  double _endOf(int? repeat) {
    final int passes = repeat ?? 1;

    return widget.settings.alternate && passes > 1 && passes.isEven ? 0 : 1;
  }

  /// Whether the run has played every pass its own `repeat` gives it, as
  /// [_finishedAfter] says it.
  bool get _finished => _finishedAfter(widget.settings.repeat);

  /// Whether the run has played every one of [repeat] passes: it is on the
  /// last one, and stopped where that one ends.
  ///
  /// A run that has not begun is on its first pass, so it is never finished,
  /// even at `0`. An endless run never is.
  bool _finishedAfter(int? repeat) {
    return repeat != null &&
        _pass >= repeat &&
        !_controller.isAnimating &&
        _controller.value == _endOf(repeat);
  }

  /// Counts the time the run has been going against a new `repeat`, which was
  /// [before], as a keyframe counts a new `animation-iteration-count` against
  /// its clock.
  ///
  /// A run that has finished is put wherever its clock has got to under the
  /// new count, which `_drive` then plays on from while the run is let go, or
  /// where the new count ends once the clock is past it. A run playing or held
  /// past the end of a lower count stands where that count ends at once. A
  /// pass in flight that the new count still holds goes on as it was, and
  /// reads the count when it ends. A run that landed under reduced motion
  /// stands where the new count ends, or at the end of one pass when the new
  /// count is `null`, whatever its clock says.
  void _recount(int? before) {
    // Under reduced motion a run stands on the last frame of whatever count it
    // has, which the build reads. One that has not begun its passes, waiting
    // for its trigger or out its delay, reads the new count when it does, and
    // one a pause keeps on the frame it landed on once the pause is let go.
    if (_still ||
        _keepsLanding ||
        _startedRuns < 0 ||
        _waiting != null ||
        _delayLeft > Duration.zero) {
      return;
    }

    final int? repeat = widget.settings.repeat;

    // A run that landed under reduced motion stands on the last frame of the
    // new count, and plays none of the passes it adds, until it runs again.
    // Given `null`, it stands at the end of one pass, as reduced motion shows
    // an endless run, and turns only once it runs again.
    if (_staysLanded) {
      _pass = repeat == null || repeat < 1 ? 1 : repeat;
      _setValue(_end);

      return;
    }

    final Duration? from = _clockFrom;
    final Duration time;

    if (from == null) {
      time = _clockAt;
    } else if (_finishedAfter(before)) {
      // Let go after it finished, so its clock has gone on counting past the
      // end of the run, which is where a pass it is given now begins.
      time = _clockAt + (animationNow() - from);
    } else {
      time = _runTime;
    }

    if (_controller.isAnimating &&
        (repeat == null || time < widget.settings.duration * (repeat < 1 ? 1 : repeat))) {
      return;
    }

    _place(time);
  }

  /// Measures a wait that is under way, running or held, against a new
  /// `delay`, as a keyframe measures a new `animation-delay`: from when the
  /// wait began, leaving out the time a pause held it.
  ///
  /// What has gone by stays gone, so the new delay is waited from where the
  /// wait has got to, and one the wait has already gone past starts the run as
  /// far into it as it would be by now, or holds it there while it is held.
  void _redate(Duration before) {
    final bool running = _waiting != null;

    // A wait that has not begun reads the new delay when it does, and once the
    // run has begun there is none left to measure.
    if (!running && _delayLeft == Duration.zero) {
      return;
    }

    _holdDelay();

    final Duration left = widget.settings.delay - (before - _delayLeft);

    if (left > Duration.zero) {
      if (running) {
        _startAfter(left);
      } else {
        _delayLeft = left;
      }

      return;
    }

    _delayLeft = Duration.zero;
    _place(-left);

    // Under reduced motion it lands, wherever that puts it.
    if (running && (_still || !_finished)) {
      _go();
    } else if (running) {
      // Already past the end of the run, its clock counts on from as far past
      // the new delay as the wait had got.
      _clockAt = -left;
      _clockFrom = animationNow();
    }
  }

  /// Holds a wait that is still running, keeping what is left of it.
  void _holdDelay() {
    if (_waiting == null) {
      return;
    }

    _waiting!.cancel();
    _waiting = null;

    final Duration gone = animationNow() - _waitingFrom;

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
        // delay, which lands it when the wait is over. A wait that a pause
        // holds is still a wait, as a paused keyframe still stands before its
        // delay is over, so it lands once it is let go and the rest of the
        // wait has gone by.
        _controller.stop();
        _landed = _startedRuns >= 0 && _waiting == null && _delayLeft == Duration.zero;

        // A run that ends lands where the setting stopped it, and stays on its
        // last frame until it runs again. One that had already finished did
        // not land under the setting, and one that had landed still has.
        if (_landed && !_finished && widget.settings.repeat != null) {
          _staysLanded = true;
        }

        // And the clock of one that had already finished goes on counting
        // from when the run began, through the setting, as a keyframe's does
        // once it has ended.
        _countsOn = _landed && _finished && !_staysLanded;

        // As far as it has moved, counting on from this frame if it is let
        // go, which `_drive` says once the frame is over. One a pause kept on
        // the frame it landed on has not moved, and its clock stands where it
        // stopped.
        if (_landed && !_keepsLanding && !_countsOn) {
          _clockAt = _runTime;
          _clockFrom = null;
        }

        _keepsLanding = false;
        _keepsStill = false;
        _keepsLanded = false;
      } else if (_landed) {
        // And given back after a run had landed. The builder listening to the
        // controller is below this one, so putting the controller somewhere
        // here only marks it for this build.
        final int? repeat = widget.settings.repeat;

        if (repeat == null && _staysLanded) {
          // A run that ends, landed and given `repeat: null` since, stands at
          // the end of one pass, where reduced motion showed it, until it runs
          // again, as the React build holds a keyframe that landed on the
          // timing it landed with, one pass for an endless run. A pause holds
          // what reduced motion drew until it is let go, as below.
          _pass = 1;
          _setValue(_end);
          _keepsLanded = widget.settings.paused;
        } else if (repeat == null && widget.restartsWithMotion) {
          // Started again from its first frame, which this build draws, and
          // moving once `_drive` has waited out its delay, as an effect the
          // React build switched off under the setting starts once it goes.
          // A pause keeps what reduced motion drew until it is let go, drawn
          // whatever frame the run stands on, so the frame that lets it go
          // draws the first one as well.
          _place(Duration.zero);
          _clockAt = Duration.zero;
          _clockFrom = null;
          _delayLeft = widget.settings.delay;
          _keepsLanded = widget.settings.paused;
        } else if (repeat == null || (!_staysLanded && !_countsOn && !widget.restartsWithMotion)) {
          // An endless run has no last frame to stay on. It goes on from
          // where its passes would have got to by now, as a keyframe that is
          // given its passes back does, rather than standing at the end of
          // the one it landed on and never moving again. So does one that
          // landed endless and was given a count while the setting was on,
          // which the React build never marked landed and counts against its
          // clock: it stands where the count ends only once that time is past
          // it. A strip or a light that did so is left to the last branch,
          // since the React build switched its keyframe off under the setting
          // and the count gives it one again, which lands.
          final Duration? from = _clockFrom;
          final Duration since = from == null ? Duration.zero : animationNow() - from;

          if (widget.settings.paused) {
            // Unless a pause holds it: a pause holds what is on the screen,
            // which is the last frame of the pass it landed on, or of the
            // count it was given, and the build that lets the pause go puts it
            // where its clock says.
            _clockAt += since;
            _clockFrom = null;
            _keepsLanding = true;
            _setValue(_end);
          } else {
            _place(_clockAt + since);
          }
        } else if (_countsOn) {
          // One that had finished before the setting arrived is put where its
          // clock says under the count it has now, as a keyframe whose clock
          // went on through the setting, so a higher `repeat` given while the
          // setting was on plays on from there. A pause holds what reduced
          // motion drew until it is let go, as below.
          final Duration? from = _clockFrom;

          _place(from == null ? _clockAt : _clockAt + (animationNow() - from));
          _keepsLanded = widget.settings.paused;
        } else {
          // A run that ends is put where it left the screen, so nothing jumps
          // back to where it began. On its last pass as well, since a landed
          // run has played them all, so one that landed at `0` is `_finished`
          // rather than a run at its first frame still to go.
          if (repeat > _pass) {
            _pass = repeat;
          }

          _setValue(_end);

          // A pause holds what is on the screen, which is what reduced motion
          // drew there, until it is let go, as it does for an endless run. It
          // is the same frame unless the effect draws something else under
          // the setting, as a strip draws its scroll box and a light its even
          // glow, which turned into the strip and the arc at once.
          _keepsLanded = widget.settings.paused;
        }

        _countsOn = false;
      } else if (widget.settings.paused) {
        // And given back to a run held by a pause before it would have
        // started, from the mount or during its delay, which shows its content
        // as reduced motion drew it. The pause holds that on the screen until
        // it is let go, whatever the run's `repeat`, as a pause that held a run
        // after it landed does.
        _keepsStill = true;
      }

      _still = still;
    }

    // Let go of the pause that kept it on the frame it landed on, an endless
    // run is put where its clock says by the build that lets it go, so that
    // frame draws it there, as a run started again is drawn on its first
    // frame, and `_drive` sets it going from there once nothing else holds
    // it. Put there after the frame, it was drawn on the frame it landed on
    // once more first.
    if (_keepsLanding && !widget.settings.paused) {
      _keepsLanding = false;
      _place(_clockAt);
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

        // A run the trigger has just let go, or started again, is drawn on its
        // first frame by this build rather than the next, held or not.
        if (started && runs != _drawnRuns) {
          _drawFirstFrame(runs);
        }

        // And one that begins after this frame is announced before that frame
        // is drawn, whether it was let go now or a pause that held it is.
        if (running && !widget.settings.paused && !widget.held && runs != _startedRuns) {
          _announce(runs);
        }

        // After the frame rather than during it, because starting a controller
        // inside a build is a build that schedules a build.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _drive(started, runs, resting: resting);
          }
        });

        final ValueWidgetBuilder<double> stillBuilder = widget.stillBuilder ?? widget.builder;

        // Kept by a pause on what reduced motion drew, until the pause is let
        // go: the frame the run landed on, or before the run would have
        // started, its content. Either is drawn as reduced motion drew it,
        // whatever frame the controller stands on underneath. A run its
        // trigger has not let go is not held by the pause, and waits on its
        // first frame.
        final bool kept =
            started && widget.settings.paused && (_keepsStill || _keepsLanding || _keepsLanded);

        // Through the same builder whether the platform asks for less movement
        // or not, so the tree above what the effect holds keeps its shape when
        // the setting changes. Returned straight from here under the setting,
        // what the effect held was built again from scratch each time it
        // changed, and lost its state: a field its text, a list its scroll.
        return AnimatedBuilder(
          animation: _controller,
          child: child,
          builder: (BuildContext context, Widget? inner) {
            // The reduced-motion answer is the *opposite* of the loading
            // indicators': a spinner that stops is lying about whether
            // anything is happening, while an effect that does not move has
            // still delivered what it was carrying — for an entrance the
            // content, and for an exit its absence. So the run is kept and the
            // movement is taken out of it. Nothing changes until the moment it
            // would have started, its delay included, and then it stands on
            // its last frame. Until that moment the content is simply there,
            // which is `1` whichever way the effect runs: the end of an
            // entrance, and the start of an exit.
            if (still || kept) {
              final double end = _landed ? _end : 1;

              return stillBuilder(
                context,
                _landed && widget.mode == PlassAnimateMode.exit ? 1 - end : end,
                inner,
              );
            }

            final double eased = curve.transform(_controller.value.clamp(0, 1));
            final double t = widget.mode == PlassAnimateMode.exit ? 1 - eased : eased;

            return widget.builder(context, t, inner);
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
