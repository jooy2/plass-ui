/// A surface that floats beside something rather than over everything.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

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
    this.matchAnchorWidth = false,
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
  final VoidCallback? onDismiss;

  /// Gives the popup the anchor's width as its minimum.
  ///
  /// For a list that belongs to a field: a menu narrower than the box it drops
  /// out of reads as a different control.
  final bool matchAnchorWidth;

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
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: PlassTokens.duration,
  );

  /// The side the popup is on, which is the one asked for until there is no room
  /// for it there.
  late PlassSide _side = widget.side;

  /// How wide the anchor is, for a popup that has to match it.
  double? _anchorWidth;

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
      widget.open ? _show() : _fade.reverse();
    }
  }

  @override
  void dispose() {
    _fade.removeStatusListener(_onFade);
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
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    _fade.duration = reduceMotion ? Duration.zero : PlassTokens.duration;

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: _buildPopup,
        child: KeyedSubtree(key: _anchorKey, child: widget.child),
      ),
    );
  }

  Widget _buildPopup(BuildContext context) {
    final (targetAnchor, followerAnchor, standoff) = _anchors;

    Widget popup = FadeTransition(
      opacity: _fade,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: widget.matchAnchorWidth ? _anchorWidth ?? 0 : 0),
        child: KeyedSubtree(key: _popupKey, child: widget.popup),
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

    // Laid out in the top-left corner and moved by the follower, which is what a
    // `CompositedTransformFollower` expects: it is a transform, so whatever it
    // wraps has to have been given room to be its own size first. Loose against
    // the overlay, so a popup can never be laid out wider than the screen.
    popup = Positioned(left: 0, top: 0, child: popup);

    return Stack(
      children: <Widget>[
        if (widget.onDismiss != null)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onDismiss,
              child: const SizedBox.expand(),
            ),
          ),
        popup,
      ],
    );
  }
}
