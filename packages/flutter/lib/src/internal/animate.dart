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
/// **`trigger: visible` watches the nearest scrollable** rather than an
/// `IntersectionObserver`. If there is no scrollable above the widget there is
/// nothing to watch — so it runs, exactly as the React build does when the
/// browser has no observer: showing the content beats hiding it forever.
///
/// None of this is exported from `plass_ui.dart`.
library;

import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/theme/tokens.dart';
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
  ScrollPosition? _watching;

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
    if (!mounted) {
      return;
    }

    final ScrollableState? scrollable = Scrollable.maybeOf(context);

    if (scrollable == null) {
      // Nothing to watch means no way to know: show it rather than hide it
      // forever, which is what the React build does when the browser has no
      // `IntersectionObserver`.
      _set(true);

      return;
    }

    _watching = scrollable.position..addListener(_checkVisible);
    _checkVisible();
  }

  void _unwatchScroll() {
    _watching?.removeListener(_checkVisible);
    _watching = null;
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

    final Rect own = MatrixUtils.transformRect(
      object.getTransformTo(viewport),
      Offset.zero & object.size,
    );
    final Rect overlap = own.intersect(viewport.paintBounds);
    final double area = object.size.width * object.size.height;
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

    return FocusableActionDetector(
      // Focus counts, or an effect on something keyboard-reachable would never
      // run for a reader who is not holding a mouse.
      onShowHoverHighlight: _onPointer,
      onShowFocusHighlight: _onPointer,
      descendantsAreFocusable: true,
      child: built,
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
/// an effect is `Opacity(opacity: lerpDouble(from, 1, t))` and nothing more.
/// `t` is `0` while the run is waiting to be triggered — the held first frame —
/// and it stays wherever the last pass left it once the count runs out.
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

    if (repeat != null && _pass >= repeat) {
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
      _waiting?.cancel();

      if (_controller.isAnimating) {
        _controller.stop();
      }

      // A run that was never triggered sits on its own first frame; one that
      // was merely paused stays exactly where it is.
      if (_startedRuns != runs) {
        _controller.value = 0;
      }

      return;
    }

    if (_startedRuns == runs) {
      if (!_controller.isAnimating && !_controller.isCompleted) {
        _controller.forward();
      }

      return;
    }

    _startedRuns = runs;
    _pass = 1;
    _controller.value = 0;
    _waiting?.cancel();

    if (widget.settings.delay == Duration.zero) {
      _controller.forward();

      return;
    }

    _waiting = Timer(widget.settings.delay, () {
      if (mounted && _startedRuns == runs) {
        _controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Curve curve = widget.settings.curve ?? PlassTokens.ease;
    final bool still = prefersReducedMotion(context);

    return PlassAnimateGate(
      settings: widget.settings,
      child: widget.child,
      builder: (BuildContext context, bool running, int runs, Widget? child) {
        // The reduced-motion answer is the *opposite* of the loading
        // indicators': a spinner that stops is lying about whether anything is
        // happening, while an entrance that never played has already delivered
        // everything it was carrying. So the effect is dropped and the content
        // is simply there.
        if (still) {
          return widget.builder(context, 1, child);
        }

        // After the frame rather than during it, because starting a controller
        // inside a build is a build that schedules a build.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _drive(running, runs);
          }
        });

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
/// Two widgets rather than one because a fraction of the widget's own size is
/// only knowable at paint time, and [FractionalTranslation] is the framework's
/// answer to exactly that. Neither is a [Transform] on a *control*: what moves
/// here is content a caller asked to have moved.
Widget translateBy({
  required Offset offset,
  required Offset fraction,
  required bool useFraction,
  required Widget child,
}) {
  return useFraction
      ? FractionalTranslation(translation: fraction, child: child)
      : Transform.translate(offset: offset, child: child);
}
