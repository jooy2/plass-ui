/// A surface that floats beside something rather than over everything.
library;

import 'package:flutter/rendering.dart';
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
  /// it is not a barrier. With neither, Escape is left to whatever is around the
  /// popup.
  final VoidCallback? onEscape;

  /// Whether a press on the anchor counts as a press inside the popup.
  ///
  /// Off, a press on the anchor is outside it, which suits an anchor that is a
  /// trigger and nothing else: the press closes the popup, as a trigger pressed
  /// again does. On, a press on the anchor leaves the popup open and reaches
  /// the anchor, which suits an anchor that goes on being used while its popup
  /// is up — a combobox's field, whose caret moves, whose chips come off and
  /// whose chevron closes the list itself. Base UI leaves a combobox's input
  /// group out of the outside press for the same reason.
  final bool anchorInside;

  /// How the popup's width follows the anchor's.
  ///
  /// For a list that belongs to a field: a menu narrower than the box it drops
  /// out of reads as a different control.
  final PlassAnchorWidth anchorWidth;

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
      widget.open ? _show() : _fade.reverse();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
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
    if (status == AnimationStatus.dismissed && _portal.isShowing) {
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

      _side = widget.side;
      _portal.show();
      _fade.forward();

      // One more frame: the popup has to have been laid out once before there is
      // a size to decide the flip against.
      _afterFrame(_measure);
    });
  }

  void _measure() {
    if (!mounted || !widget.open) {
      return;
    }

    final anchor = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    final popup = _popupKey.currentContext?.findRenderObject() as RenderBox?;
    final room = Overlay.maybeOf(context)?.context.findRenderObject() as RenderBox?;

    if (anchor == null || popup == null || room == null || !anchor.hasSize || !popup.hasSize) {
      return;
    }

    final origin = anchor.localToGlobal(Offset.zero, ancestor: room);
    final box = origin & anchor.size;
    final side = _fit(box, popup.size, room.size);

    if (side != _side || anchor.size.width != _anchorWidth) {
      setState(() {
        _side = side;
        _anchorWidth = anchor.size.width;
      });
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

  /// Where on the anchor the popup hangs from, and where on the popup that point
  /// lands. The pair is what places it; the offset is only the standoff.
  (Alignment, Alignment, Offset) get _anchors {
    final along = switch (widget.align) {
      PlassAlign.start => -1.0,
      PlassAlign.center => 0.0,
      PlassAlign.end => 1.0,
    };

    return switch (_side) {
      PlassSide.top => (Alignment(along, -1), Alignment(along, 1), Offset(0, -widget.offset)),
      PlassSide.bottom => (Alignment(along, 1), Alignment(along, -1), Offset(0, widget.offset)),
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
        actions: <Type, Action<Intent>>{DismissIntent: _escape},
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
    final (targetAnchor, followerAnchor, standoff) = _anchors;

    Widget popup = FadeTransition(
      opacity: _opacity,
      child: ConstrainedBox(
        constraints: switch (widget.anchorWidth) {
          PlassAnchorWidth.free => const BoxConstraints(),
          PlassAnchorWidth.atLeast => BoxConstraints(minWidth: _anchorWidth ?? 0),
          PlassAnchorWidth.exact => BoxConstraints.tightFor(width: _anchorWidth),
        },
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

/// Escape, for as long as the popup is open and something is listening.
///
/// Disabled rather than absent while it is closed, so the key goes on to a
/// modal or a page that binds it too, and the tree under the anchor is not
/// rebuilt every time the popup opens.
class _EscapeAction extends Action<DismissIntent> {
  _EscapeAction(this._state);

  final _PlassAnchoredPortalState _state;

  VoidCallback? get _callback => _state.widget.onEscape ?? _state.widget.onDismiss;

  @override
  bool isEnabled(DismissIntent intent) => _state.widget.open && _callback != null;

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
