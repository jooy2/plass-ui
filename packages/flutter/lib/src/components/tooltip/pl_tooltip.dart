/// A short label that appears when the pointer rests on something.
library;

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/anchored.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How wide a plate is allowed to get before its text wraps.
const double _maxWidth = 256;

/// A row's vertical padding, against the horizontal track [paddingX] sets.
const Map<PlassSize, double> _paddingY = <PlassSize, double>{
  PlassSize.xs: 2,
  PlassSize.sm: 2,
  PlassSize.md: 4,
  PlassSize.lg: 6,
  PlassSize.xl: 8,
};

/// The wedge, at roughly a third of the plate's corner radius per step.
const Map<PlassSize, double> _arrowSize = <PlassSize, double>{
  PlassSize.xs: 6,
  PlassSize.sm: 7,
  PlassSize.md: 8,
  PlassSize.lg: 9,
  PlassSize.xl: 10,
};

/// How long a tooltip stays "recent" to the ones beside it.
const Duration _groupTimeout = Duration(milliseconds: 300);

/// How long a tooltip opened by a long press stays up after the finger lifts.
///
/// A pointer leaving is a reader who has stopped looking; a finger lifting is a
/// reader who has just started. Closing on the release would show the plate for
/// exactly as long as the press that was asking to read it.
const Duration _touchDwell = Duration(milliseconds: 1500);

/// Shares one delay across a group of tooltips.
///
/// Once any tooltip inside has opened, its neighbours open at once, and the wait
/// comes back after a pause. Worth wrapping a toolbar in: without it, moving
/// along a row of icon buttons means waiting out the full delay at every stop,
/// which is what makes tooltips feel like they are fighting the pointer.
class PlTooltipProvider extends StatefulWidget {
  /// Creates a group.
  const PlTooltipProvider({required this.child, this.timeout = _groupTimeout, super.key});

  /// What is inside the group.
  final Widget child;

  /// How long after one tooltip closes its neighbours still open at once.
  final Duration timeout;

  @override
  State<PlTooltipProvider> createState() => _PlTooltipProviderState();
}

class _PlTooltipProviderState extends State<PlTooltipProvider> {
  final _TooltipGroup _group = _TooltipGroup();

  @override
  Widget build(BuildContext context) {
    return _TooltipScope(group: _group, timeout: widget.timeout, child: widget.child);
  }
}

/// What the tooltips in a group share: when one of them was last up.
class _TooltipGroup {
  DateTime? lastClosed;
  int open = 0;
}

class _TooltipScope extends InheritedWidget {
  const _TooltipScope({required this.group, required this.timeout, required super.child});

  final _TooltipGroup group;
  final Duration timeout;

  static _TooltipScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_TooltipScope>();
  }

  @override
  bool updateShouldNotify(_TooltipScope oldWidget) {
    return group != oldWidget.group || timeout != oldWidget.timeout;
  }
}

/// A short label that appears when the pointer rests on something.
///
/// ```dart
/// PlTooltip(
///   content: const Text('Copy'),
///   child: PlButton(onPressed: copy, child: const PlIcon(icon: CopyGlyph())),
/// )
/// ```
///
/// The whole component is a wrapper: it adds no box to the layout and the child
/// stays whatever it was — a button, a chip, a truncated cell.
///
/// [content] is a short phrase. A tooltip is not a container: it cannot be
/// reached by a finger on a touch screen, it goes the moment attention moves,
/// and anything inside it that could be pressed cannot be. Content that needs
/// either of those belongs in a sheet that stays put.
///
/// The plate is the same floating sheet a `PlSelect`'s popup is: the glass at
/// its most opaque, a white hairline round it, a shadow under it. Not a filled
/// key, which is what most libraries draw a tooltip as — a tooltip is a note
/// *about* something rather than a thing to press, and the library already has
/// one answer for a surface that floats over arbitrary content.
///
/// Needs an [Overlay] above it, which `WidgetsApp` with a navigator and
/// `MaterialApp` both provide.
class PlTooltip extends StatefulWidget {
  /// Creates a tooltip.
  const PlTooltip({
    required this.content,
    required this.child,
    this.side = PlassSide.top,
    this.align = PlassAlign.center,
    this.offset = 6,
    this.delay = const Duration(milliseconds: 600),
    this.closeDelay = Duration.zero,
    this.arrow = true,
    this.open,
    this.onOpenChanged,
    this.disabled = false,
    this.semanticLabel,
    this.size,
    this.density,
    super.key,
  });

  /// What the tooltip says.
  final Widget content;

  /// What it hangs off.
  final Widget child;

  /// Which edge of the trigger it appears on. It flips to the opposite side when
  /// there is no room.
  final PlassSide side;

  /// Where it sits along that edge.
  final PlassAlign align;

  /// How far it stands off the trigger, in logical pixels.
  final double offset;

  /// How long the pointer has to rest before it opens.
  final Duration delay;

  /// How long it waits before closing once the pointer leaves.
  final Duration closeDelay;

  /// Draws the little wedge pointing at the trigger.
  final bool arrow;

  /// Drives the tooltip from outside.
  ///
  /// `null` — the default — leaves it to the pointer, the keyboard and a long
  /// press, which is the **one place in the package where a component owns its
  /// own state**. Everything else here is controlled because a caller has an
  /// opinion about the value; nobody has an opinion about whether a pointer is
  /// resting on a button. [onOpenChanged] still reports either way.
  final bool? open;

  /// Called whenever the tooltip opens or closes, however it was asked.
  final ValueChanged<bool>? onOpenChanged;

  /// Stops the tooltip opening at all, without disabling the trigger. For the
  /// tooltip that only exists while a label is truncated.
  final bool disabled;

  /// What a screen reader says the trigger's tooltip is.
  ///
  /// A widget cannot be read out, so this is what a tooltip carrying anything
  /// but a plain [Text] needs. With a `Text` in [content] it defaults to that
  /// text, and the common case needs nothing.
  final String? semanticLabel;

  /// Type scale, radius and padding of the plate.
  ///
  /// There is no `color`. A tooltip is a note *about* something, never the thing
  /// itself, so the plate is always the neutral sheet — a red tooltip on a
  /// delete button would be saying something the tooltip does not know. In the
  /// React build the family reached the slots the content read; here content
  /// arrives with its own colours.
  final PlassSize? size;

  /// How tightly the plate packs its text.
  final PlassDensity? density;

  @override
  State<PlTooltip> createState() => _PlTooltipState();
}

class _PlTooltipState extends State<PlTooltip> {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.sm;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

  bool _open = false;
  PlassSide _side = PlassSide.top;
  Timer? _timer;

  /// Held rather than looked up on demand, because a tooltip has to hand its
  /// place in the group back on the way out and an inherited widget cannot be
  /// read from `dispose`.
  _TooltipScope? _group;

  @override
  void initState() {
    super.initState();
    _side = widget.side;
    _open = widget.open ?? false;
  }

  @override
  void didUpdateWidget(PlTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.open != null && widget.open != _open) {
      _open = widget.open!;
    }

    if (widget.disabled && _open) {
      _open = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _release();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _group = _TooltipScope.maybeOf(context);
  }

  _TooltipScope? get _scope => _group;

  /// Whether the group has been warm recently enough to skip the wait.
  bool get _warm {
    final scope = _scope;

    if (scope == null) {
      return false;
    }

    if (scope.group.open > 0) {
      return true;
    }

    final closed = scope.group.lastClosed;

    return closed != null && DateTime.now().difference(closed) < scope.timeout;
  }

  void _hold() {
    final scope = _scope;

    if (scope != null) {
      scope.group.open += 1;
    }
  }

  void _release() {
    final scope = _scope;

    if (scope != null && scope.group.open > 0) {
      scope.group.open -= 1;
      scope.group.lastClosed = DateTime.now();
    }
  }

  void _set(bool next) {
    _timer?.cancel();
    _timer = null;

    if (_open == next) {
      return;
    }

    next ? _hold() : _release();

    // A tooltip drives itself unless the caller asked to drive it, which is what
    // `open` being nullable means. Either way the change is reported.
    if (widget.open == null) {
      setState(() => _open = next);
    }

    widget.onOpenChanged?.call(next);
  }

  void _schedule(bool next, {Duration? after}) {
    if (widget.disabled) {
      return;
    }

    _timer?.cancel();

    final wait = after ?? (next ? (_warm ? Duration.zero : widget.delay) : widget.closeDelay);

    if (wait == Duration.zero) {
      _set(next);

      return;
    }

    _timer = Timer(wait, () => _set(next));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final size = _size;
    final radius = PlassTokens.radius[size]!;
    final arrow = _arrowSize[size]!;

    final plate = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: PlassSurfaceBox(
        surface: PlassSurface(
          fill: tokens.glassPress,
          border: Border.all(color: tokens.glassLine, width: hairline),
          ink: tokens.fg,
          blur: true,
          insets: <PlassInsetShadow>[tokens.glossGlass],
          shadows: tokens.elevation(plassElevationMax),
        ),
        borderRadius: BorderRadius.circular(radius),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: paddingX[_density]![size]!,
            vertical: _paddingY[size]!,
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: tokens.fg, fontSize: metaText[size]!, height: 1.4),
            child: widget.content,
          ),
        ),
      ),
    );

    final popup = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        plate,
        if (widget.arrow) _arrowSlot(tokens, arrow: arrow, radius: radius),
      ],
    );

    // The pointer is what a tooltip listens to, and `MouseRegion` rather than a
    // gesture because resting is not pressing. A long press is the touch screen's
    // way in, and focus is the keyboard's.
    Widget trigger = MouseRegion(
      onEnter: (_) => _schedule(true),
      onExit: (_) => _schedule(false),
      child: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onLongPress: () => _schedule(true),
        onLongPressEnd: (_) => _schedule(false, after: _touchDwell),
        child: widget.child,
      ),
    );

    trigger = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (bool has) => _schedule(has),
      child: trigger,
    );

    final spoken =
        widget.semanticLabel ?? (widget.content is Text ? (widget.content as Text).data : null);

    return Semantics(
      tooltip: spoken,
      child: PlassAnchoredPortal(
        open: _open && !widget.disabled,
        side: widget.side,
        align: widget.align,
        offset: widget.offset,
        onSideResolved: (PlassSide side) {
          if (mounted && side != _side) {
            setState(() => _side = side);
          }
        },
        // Excluded from semantics: what the plate says is already on the trigger
        // as its tooltip, and a floating node saying it a second time is a
        // screen reader reading the same phrase twice.
        popup: ExcludeSemantics(child: popup),
        child: trigger,
      ),
    );
  }

  /// The wedge, on whichever edge of the plate faces the anchor.
  ///
  /// A sibling of the plate rather than a child of it: the plate clips itself at
  /// its own rounded corner — it has to, for the blur — and a wedge inside it
  /// would be a wedge with its point cut off.
  Widget _arrowSlot(PlassTokens tokens, {required double arrow, required double radius}) {
    final vertical = _side == PlassSide.top || _side == PlassSide.bottom;
    final along = switch (widget.align) {
      PlassAlign.start => -1.0,
      PlassAlign.center => 0.0,
      PlassAlign.end => 1.0,
    };
    final wedge = CustomPaint(
      size: vertical ? Size(arrow, arrow / 2) : Size(arrow / 2, arrow),
      painter: _ArrowPainter(side: _side, fill: tokens.glassPress, line: tokens.glassLine),
    );

    // Inset by the corner radius so an `align: start` wedge points at the
    // trigger rather than at the plate's own rounded corner.
    final slot = Padding(
      padding: vertical
          ? EdgeInsets.symmetric(horizontal: radius)
          : EdgeInsets.symmetric(vertical: radius),
      child: Align(alignment: vertical ? Alignment(along, 0) : Alignment(0, along), child: wedge),
    );

    // A hair of overlap, so the wedge's base and the plate's edge are one line
    // rather than two with a seam between them.
    final overlap = -(arrow / 2 - hairline);

    return switch (_side) {
      PlassSide.top => Positioned(
        left: 0,
        right: 0,
        bottom: overlap,
        height: arrow / 2,
        child: slot,
      ),
      PlassSide.bottom => Positioned(
        left: 0,
        right: 0,
        top: overlap,
        height: arrow / 2,
        child: slot,
      ),
      PlassSide.left => Positioned(
        top: 0,
        bottom: 0,
        right: overlap,
        width: arrow / 2,
        child: slot,
      ),
      PlassSide.right => Positioned(
        top: 0,
        bottom: 0,
        left: overlap,
        width: arrow / 2,
        child: slot,
      ),
    };
  }
}

/// The wedge that points back at the anchor.
///
/// Drawn twice: the hairline first, then the fill over it a pixel further from
/// the point. A single filled triangle would leave the plate's own edge running
/// straight across the base of the arrow, which is a sheet with a notch rather
/// than a sheet with a point.
class _ArrowPainter extends CustomPainter {
  const _ArrowPainter({required this.side, required this.fill, required this.line});

  final PlassSide side;
  final Color fill;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    // The point is on the side facing away from the plate, which is the side the
    // plate was placed on.
    final path = Path();

    switch (side) {
      case PlassSide.top:
        path
          ..moveTo(0, 0)
          ..lineTo(size.width, 0)
          ..lineTo(size.width / 2, size.height);
      case PlassSide.bottom:
        path
          ..moveTo(0, size.height)
          ..lineTo(size.width, size.height)
          ..lineTo(size.width / 2, 0);
      case PlassSide.left:
        path
          ..moveTo(0, 0)
          ..lineTo(0, size.height)
          ..lineTo(size.width, size.height / 2);
      case PlassSide.right:
        path
          ..moveTo(size.width, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height / 2);
    }

    path.close();

    final back = switch (side) {
      PlassSide.top => const Offset(0, -hairline),
      PlassSide.bottom => const Offset(0, hairline),
      PlassSide.left => const Offset(-hairline, 0),
      PlassSide.right => const Offset(hairline, 0),
    };

    canvas
      ..drawPath(path, Paint()..color = line)
      ..drawPath(path.shift(back), Paint()..color = fill);
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) {
    return oldDelegate.side != side || oldDelegate.fill != fill || oldDelegate.line != line;
  }
}
