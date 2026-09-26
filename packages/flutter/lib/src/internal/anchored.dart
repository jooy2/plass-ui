/// A surface that floats beside something rather than over everything.
library;

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/ease.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

/// How a popup's width follows its anchor's.
enum PlassAnchorWidth {
  /// The popup's own width, whatever the anchor's is.
  free,

  /// At least the anchor's, and wider when the popup's content is: a menu that
  /// can say a longer word than the field it drops out of.
  atLeast,

  /// Exactly the anchor's: a list of suggestions for what is being typed, which
  /// is as wide as the place it is typed into.
  exact,
}

/// A popup lifted out of the tree and hung off an anchor.
///
/// What a `PlTooltip` and a `PlSelect`'s list have in common: the lift into the
/// nearest [Overlay], the anchoring, the flip when there is no room on the side
/// that was asked for, the fade, and a press outside.
///
/// The tracking is a [LayerLink] rather than arithmetic repeated every frame,
/// which is what keeps a popup stuck to its anchor while the page under it
/// scrolls: the follower is positioned by the compositor off the leader's own
/// layer, so nothing has to notice that the anchor moved.
///
/// Collision handling is a **flip and not a slide**. When the side that was
/// asked for has no room the popup goes to the opposite one; it never shifts
/// along the edge it is on. Sliding needs the popup's position recomputed
/// against the viewport every frame, which is the thing the layer link exists to
/// avoid, and a popup that creeps sideways as its anchor nears the edge is a
/// popup whose arrow no longer points at anything.
///
/// The side is decided as the popup opens and again whenever the screen
/// changes size, and never on a scroll, which the layer link already follows.
///
/// Needs an [Overlay] above it, which `WidgetsApp` with a navigator and
/// `MaterialApp` both provide.
class PlassAnchoredPortal extends StatefulWidget {
  /// Creates an anchored popup.
  const PlassAnchoredPortal({
    required this.open,
    required this.child,
    required this.popup,
    this.side = PlassSide.top,
    this.align = PlassAlign.center,
    this.offset = 6,
    this.onDismiss,
    this.onEscape,
    this.anchorInside = false,
    this.anchorWidth = PlassAnchorWidth.free,
    this.fitWidth = false,
    this.onSideResolved,
    super.key,
  });

  /// Whether the popup is up.
  final bool open;

  /// The anchor, drawn where it was written.
  final Widget child;

  /// What floats beside it.
  final Widget popup;

  /// Which edge of the anchor the popup is asked for.
  final PlassSide side;

  /// Where it sits along that edge.
  final PlassAlign align;

  /// How far it stands off the anchor, in logical pixels.
  final double offset;

  /// Called when a press lands outside the popup. `null` leaves outside presses
  /// alone, which is what a tooltip wants: it is closed by the pointer leaving,
  /// not by anything being pressed.
  ///
  /// The press still reaches whatever it landed on, so the screen behind the
  /// popup goes on being pressed and scrolled. The exception is the anchor: a
  /// press on it closes the popup and goes no further, or a trigger that opens
  /// its popup would open it again on the same press. [anchorInside] turns that
  /// exception round.
  final VoidCallback? onDismiss;

  /// Called when Escape is pressed while the popup is open and the focus is on
  /// the anchor or inside the popup. Falls back to [onDismiss].
  ///
  /// Separate because a tooltip closes on Escape without taking outside presses:
  /// it is not a barrier. With neither, Escape does nothing while the popup is
  /// open and goes no further, so a modal under a popup that refuses to be
  /// dismissed stays up too. While the popup is closed, Escape goes on to
  /// whatever is around it, a modal or a page that binds it too.
  final VoidCallback? onEscape;

  /// Whether a press on the anchor counts as a press inside the popup.
  ///
  /// Off, a press on the anchor is outside it, which suits an anchor that is a
  /// trigger and nothing else: the press closes the popup, as a trigger pressed
  /// again does. On, a press on the anchor leaves the popup open and reaches
  /// the anchor, which suits an anchor that goes on being used while its popup
  /// is up — a combobox's field, whose caret moves, whose chips come off and
  /// whose chevron closes the list itself. Base UI leaves a combobox's input
  /// group out of the outside press for the same reason. A picker's trigger is
  /// the other one: it closes its popup itself, and the × in it clears the
  /// value while the popup is up.
  final bool anchorInside;

  /// How the popup's width follows the anchor's.
  ///
  /// For a list that belongs to a field: a menu narrower than the box it drops
  /// out of reads as a different control.
  final PlassAnchorWidth anchorWidth;

  /// Whether the popup is held to the room it has on its side of the anchor.
  ///
  /// The room is measured after the flip, as the popup opens and again
  /// whenever the screen changes size: from where the popup hangs to the edge
  /// of the screen it runs towards. A popup here flips and never slides, so
  /// one wider than that room would run off the screen. For a popup as wide as
  /// whatever the caller puts in it; the rest keep the width they are given.
  final bool fitWidth;

  /// Told which side the popup actually ended up on, once it is known.
  ///
  /// The popup usually has to draw something that points back at the anchor, and
  /// only this knows which way that is after a flip.
  final ValueChanged<PlassSide>? onSideResolved;

  @override
  State<PlassAnchoredPortal> createState() => _PlassAnchoredPortalState();
}

class _PlassAnchoredPortalState extends State<PlassAnchoredPortal>
    with SingleTickerProviderStateMixin {
  final LayerLink _link = LayerLink();
  final OverlayPortalController _portal = OverlayPortalController();
  final GlobalKey _anchorKey = GlobalKey();
  final GlobalKey _popupKey = GlobalKey();

  /// The group the popup's sheet reads the backdrop in, which is its alone, for
  /// the reason `PlassPortal` gives: the popup is painted over the page, and a
  /// key it shared with the field it hangs off would hand it the backdrop as it
  /// was when that field was drawn.
  final BackdropKey _layer = BackdropKey();

  // No duration here, for the reason `PlassPortal` gives: `_syncMotion` sets
  // it from the theme before the first frame and whenever the theme changes.
  late final AnimationController _fade = AnimationController(vsync: this);

  /// The fade as it is drawn, on the theme's curve, which `_syncMotion` hands
  /// it with the duration.
  late final CurvedAnimation _opacity = CurvedAnimation(parent: _fade, curve: Curves.linear);

  /// The side the popup is on, which is the one asked for until there is no room
  /// for it there.
  late PlassSide _side = widget.side;

  /// How wide the anchor is, for a popup that has to match it.
  double? _anchorWidth;

  /// How wide the popup may be on the side it opened to, for a popup held to
  /// its room, and `null` until that has been measured.
  double? _room;

  /// How wide a popup held to its room is at its own width, measured as it
  /// opens, before the room is known.
  ///
  /// A flip beside the anchor is decided against this rather than against the
  /// width the popup is drawn at, because a popup held to the room on one side
  /// always seems to fit there.
  double? _ownWidth;

  /// The size of the screen when it was last looked at, and `null` until the
  /// popup first opens.
  Size? _screen;

  /// Answers Escape before anything around the popup does, so a popover opened
  /// in a modal closes itself and leaves the modal up.
  late final _EscapeAction _escape = _EscapeAction(this);

  @override
  void initState() {
    super.initState();
    _fade.addStatusListener(_onFade);

    if (widget.open) {
      _show();
    }
  }

  @override
  void didUpdateWidget(PlassAnchoredPortal oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.side != oldWidget.side) {
      _side = widget.side;
    }

    if (widget.open != oldWidget.open) {
      // Read here as well as below, for the reason `PlassPortal` gives: a theme
      // that changed in the same frame as `open` reaches an update first.
      _syncMotion();
      _watchScreen();
      widget.open ? _show() : _fade.reverse();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
    _watchScreen();
  }

  /// Measures an open popup again once the frame has laid it out, when the
  /// screen has changed size and moved the anchor and the room round it.
  ///
  /// The size is watched from the first time the popup opens and not before:
  /// a page can hold hundreds of popups that never open, a tooltip on every
  /// button, and all of them would be rebuilt on every frame of a window being
  /// resized.
  void _watchScreen() {
    if (!widget.open && _screen == null) {
      return;
    }

    final screen = MediaQuery.maybeSizeOf(context);

    if (screen != _screen) {
      final resized = _screen != null;
      _screen = screen;

      if (resized && widget.open) {
        _afterFrame(_measure);
      }
    }
  }

  /// Hands the fade the theme's duration and curve, or no duration at all for
  /// a reader who asked for less movement.
  void _syncMotion() {
    final tokens = PlassTheme.of(context);

    _fade.duration = (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
        ? Duration.zero
        : tokens.motionDuration;
    easeBothWays(_opacity, tokens.motionEase);
  }

  @override
  void dispose() {
    _fade.removeStatusListener(_onFade);
    _opacity.dispose();
    _fade.dispose();
    super.dispose();
  }

  void _onFade(AnimationStatus status) {
    if (status != AnimationStatus.dismissed || !_portal.isShowing) {
      return;
    }

    // After the frame while the tree is building, for the reason `PlassPortal`
    // gives: under reduced motion the fade is over inside the build that
    // closed the popup.
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      _afterFrame(_takeDown);
    } else {
      _takeDown();
    }
  }

  /// Takes the popup down, unless it has been opened again or has left the
  /// tree since it finished going out.
  void _takeDown() {
    if (mounted && !widget.open && _fade.isDismissed && _portal.isShowing) {
      _portal.hide();
    }
  }

  /// Everything a popup does to itself is out of bounds during a build, and a
  /// build is where the change nearly always arrives from.
  void _afterFrame(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((Duration _) => callback());
  }

  void _show() {
    _afterFrame(() {
      if (!mounted || !widget.open) {
        return;
      }

      // Laid out at its own width first, which is the width the flip is
      // decided against, and held to its room only once that is known.
      _side = widget.side;
      _room = null;
      _portal.show();
      _fade.forward();

      // One more frame: the popup has to have been laid out once before there is
      // a size to decide the flip against.
      _afterFrame(() => _measure(opening: true));
    });
  }

  /// Decides the side, and the widths the popup is held to, from where the
  /// anchor and the popup are laid out now.
  ///
  /// Run as the popup opens and when the screen changes size, and once more
  /// after either has changed a width the popup is held to: a narrower popup
  /// wraps its lines and grows taller, and a flip above or below the anchor is
  /// decided against the height it grows to. That measure settles the side
  /// rather than turning it back. A popup is held to the same room above the
  /// anchor as below it, so it is as tall on either side, and a flip beside
  /// the anchor is decided against [_ownWidth], which no room changes.
  void _measure({bool opening = false}) {
    // A popup held to its room is laid out at its own width as it opens, and
    // only the measure that follows that layout may decide anything: one run
    // in between would hold it to a room before its own width was known.
    if (!mounted || !widget.open || (widget.fitWidth && _room == null && !opening)) {
      return;
    }

    final anchor = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    final popup = _popupKey.currentContext?.findRenderObject() as RenderBox?;
    final room = Overlay.maybeOf(context)?.context.findRenderObject() as RenderBox?;

    if (anchor == null || popup == null || room == null || !anchor.hasSize || !popup.hasSize) {
      return;
    }

    if (opening) {
      _ownWidth = popup.size.width;
    }

    final origin = anchor.localToGlobal(Offset.zero, ancestor: room);
    final box = origin & anchor.size;
    final size = widget.fitWidth
        ? Size(_ownWidth ?? popup.size.width, popup.size.height)
        : popup.size;
    final side = _fit(box, size, room.size);
    final space = widget.fitWidth ? _roomOn(side, box, room.size) : null;
    final widthChanged =
        space != _room ||
        (widget.anchorWidth != PlassAnchorWidth.free && anchor.size.width != _anchorWidth);

    if (side != _side || anchor.size.width != _anchorWidth || space != _room) {
      setState(() {
        _side = side;
        _anchorWidth = anchor.size.width;
        _room = space;
      });
    }

    if (widthChanged) {
      _afterFrame(_measure);
    }

    widget.onSideResolved?.call(side);
  }

  /// Whether [position], in global coordinates, is on the anchor.
  bool _onAnchor(Offset position) {
    final anchor = _anchorKey.currentContext?.findRenderObject() as RenderBox?;

    if (anchor == null || !anchor.attached || !anchor.hasSize) {
      return false;
    }

    return (Offset.zero & anchor.size).contains(anchor.globalToLocal(position));
  }

  /// The side that has room, which is the one asked for unless it does not.
  PlassSide _fit(Rect anchor, Size popup, Size room) {
    final needsY = popup.height + widget.offset;
    final needsX = popup.width + widget.offset;

    return switch (widget.side) {
      PlassSide.top =>
        anchor.top >= needsY || anchor.bottom + needsY > room.height
            ? PlassSide.top
            : PlassSide.bottom,
      PlassSide.bottom =>
        anchor.bottom + needsY <= room.height || anchor.top < needsY
            ? PlassSide.bottom
            : PlassSide.top,
      PlassSide.left =>
        anchor.left >= needsX || anchor.right + needsX > room.width
            ? PlassSide.left
            : PlassSide.right,
      PlassSide.right =>
        anchor.right + needsX <= room.width || anchor.left < needsX
            ? PlassSide.right
            : PlassSide.left,
    };
  }

  /// How wide a popup on [side] of [anchor] can be before it runs off a screen
  /// of [room]: from where it hangs to the edge it runs towards, as
  /// [_anchors] places it.
  double _roomOn(PlassSide side, Rect anchor, Size room) {
    final rtl = Directionality.of(context) == TextDirection.rtl;

    final space = switch (side) {
      PlassSide.left => anchor.left - widget.offset,
      PlassSide.right => room.width - anchor.right - widget.offset,
      PlassSide.top || PlassSide.bottom => switch (widget.align) {
        // Centred on the anchor, it runs both ways, and the nearer edge is the
        // one it reaches first.
        PlassAlign.center => math.min(anchor.center.dx, room.width - anchor.center.dx) * 2,
        // From the start of the line towards its end, which is the left under
        // RTL, and from the end the other way.
        PlassAlign.start => rtl ? anchor.right : room.width - anchor.left,
        PlassAlign.end => rtl ? room.width - anchor.left : anchor.right,
      },
    };

    return math.max(space, 0.0);
  }

  /// Where on the anchor the popup hangs from, and where on the popup that point
  /// lands. The pair is what places it; the offset is only the standoff.
  ///
  /// Along a top or a bottom edge, `start` and `end` are the reader's, so the
  /// right and the left under RTL, and they are resolved against [direction]
  /// here because the follower takes a resolved alignment. Along a side edge
  /// they are the top and the bottom in either direction.
  (Alignment, Alignment, Offset) _anchors(TextDirection direction) {
    final along = switch (widget.align) {
      PlassAlign.start => -1.0,
      PlassAlign.center => 0.0,
      PlassAlign.end => 1.0,
    };

    return switch (_side) {
      PlassSide.top => (
        AlignmentDirectional(along, -1).resolve(direction),
        AlignmentDirectional(along, 1).resolve(direction),
        Offset(0, -widget.offset),
      ),
      PlassSide.bottom => (
        AlignmentDirectional(along, 1).resolve(direction),
        AlignmentDirectional(along, -1).resolve(direction),
        Offset(0, widget.offset),
      ),
      PlassSide.left => (Alignment(-1, along), Alignment(1, along), Offset(-widget.offset, 0)),
      PlassSide.right => (Alignment(1, along), Alignment(-1, along), Offset(widget.offset, 0)),
    };
  }

  @override
  Widget build(BuildContext context) {
    // Around the portal rather than inside the popup: the popup's element sits
    // under the portal's, so one binding reaches a focus on the anchor and a
    // focus inside the popup alike.
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{if (widget.open) DismissIntent: _escape},
        child: CompositedTransformTarget(
          link: _link,
          child: OverlayPortal(
            controller: _portal,
            overlayChildBuilder: _buildPopup,
            child: _PressShield(
              shielding: widget.open && widget.onDismiss != null && !widget.anchorInside,
              child: KeyedSubtree(key: _anchorKey, child: widget.child),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopup(BuildContext context) {
    final (targetAnchor, followerAnchor, standoff) = _anchors(Directionality.of(context));

    final BoxConstraints width = switch (widget.anchorWidth) {
      PlassAnchorWidth.free => const BoxConstraints(),
      PlassAnchorWidth.atLeast => BoxConstraints(minWidth: _anchorWidth ?? 0),
      PlassAnchorWidth.exact => BoxConstraints.tightFor(width: _anchorWidth),
    };
    final double? room = widget.fitWidth ? _room : null;

    Widget popup = FadeTransition(
      opacity: _opacity,
      child: ConstrainedBox(
        constraints: room == null ? width : width.enforce(BoxConstraints(maxWidth: room)),
        // A press anywhere on the popup is the popup's, including one on a gap
        // between its parts, which would otherwise fall through to the page.
        child: Listener(
          behavior: widget.onDismiss != null
              ? HitTestBehavior.opaque
              : HitTestBehavior.deferToChild,
          child: KeyedSubtree(key: _popupKey, child: widget.popup),
        ),
      ),
    );

    popup = CompositedTransformFollower(
      link: _link,
      // The popup goes away with its anchor rather than staying behind on the
      // last place it was seen.
      showWhenUnlinked: false,
      targetAnchor: targetAnchor,
      followerAnchor: followerAnchor,
      offset: standoff,
      child: popup,
    );

    // The popup is an ordinary child of the stack rather than a positioned one,
    // and the difference matters: a child positioned by only two edges is laid
    // out **unbounded**, and an unbounded width is not a width. Unpositioned it
    // is measured loosely against the screen, which is the cap it should have —
    // and where it actually lands is the follower's business, not the stack's.
    return BackdropGroup(
      backdropKey: _layer,
      child: SizedBox.expand(
        child: Stack(
          alignment: AlignmentDirectional.topStart,
          children: <Widget>[
            // Told about a press outside without taking it. A translucent listener
            // over an empty box reports the press and then answers that it hit
            // nothing, so the press goes on to the page under the overlay.
            if (widget.onDismiss != null)
              Positioned.fill(
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (PointerDownEvent event) {
                    if (widget.open && !(widget.anchorInside && _onAnchor(event.position))) {
                      widget.onDismiss!();
                    }
                  },
                ),
              ),
            popup,
          ],
        ),
      ),
    );
  }
}

/// Escape, for as long as the popup is open.
///
/// Mapped only for that long, as `RawMenuAnchor` maps its own, rather than
/// mapped and disabled while the popup is closed: the search for an intent's
/// action stops at the first one that maps it, enabled or not, so a disabled
/// action here would keep the key from a modal or a page that binds it too.
/// Only the map changes and the `Actions` widget stays, so the tree under the
/// anchor is not rebuilt every time the popup opens.
class _EscapeAction extends Action<DismissIntent> {
  _EscapeAction(this._state);

  final _PlassAnchoredPortalState _state;

  VoidCallback? get _callback => _state.widget.onEscape ?? _state.widget.onDismiss;

  @override
  bool isEnabled(DismissIntent intent) => _state.widget.open;

  @override
  Object? invoke(DismissIntent intent) {
    _callback?.call();

    return null;
  }
}

/// Keeps presses off the anchor while its popup is open.
///
/// The press has already been reported as outside the popup by then, and it
/// closes it. A trigger that also took it would open the popup again. This is
/// [AbsorbPointer] without the semantics: an absorbing pointer blocks the
/// actions of everything under it too, and a screen reader has to be able to
/// reach the trigger while its popup is up.
class _PressShield extends SingleChildRenderObjectWidget {
  const _PressShield({required this.shielding, required super.child});

  final bool shielding;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderPressShield(shielding);

  @override
  void updateRenderObject(BuildContext context, _RenderPressShield renderObject) {
    renderObject.shielding = shielding;
  }
}

class _RenderPressShield extends RenderProxyBox {
  _RenderPressShield(this.shielding);

  bool shielding;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    return shielding ? size.contains(position) : super.hitTest(result, position: position);
  }
}
