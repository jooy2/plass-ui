/// The layer everything that takes the page away is built on.
library;

import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/theme/tokens.dart';

/// A layer lifted out of the tree and laid over the whole app.
///
/// What a `PlOverlay` and a `PlModal` have in common, which is nearly all of
/// it: the lift into the nearest [Overlay], the backdrop, the fade, the pointer
/// held outside, the focus held inside, <kbd>Escape</kbd>, and focus going back
/// where it came from on the way out.
///
/// It needs an [Overlay] above it — `WidgetsApp` with a navigator and
/// `MaterialApp` both provide one, and an app that has neither can add one
/// itself. Lifting is the whole point: a sheet drawn where it was written would
/// be clipped by the first ancestor with `overflow: hidden`, and in Flutter that
/// is every `ClipRRect` on the way up, which on a Plass page is every card.
///
/// The fade is opacity and nothing else. A sheet that scales or slides drags
/// whatever is written on it across the screen, which is the one thing the house
/// style is against — and unlike a control, a sheet is usually carrying a
/// sentence.
///
/// It runs at [PlassTokens.durationSlow] rather than the control duration, and
/// that is the line between this and [PlassAnchoredPortal]: 150ms is a key going
/// down, and on a sheet the size of the window it is not a fade but a cut with a
/// hint of blur on it. A page that changes this completely that fast leaves a
/// reader looking for what moved. A popup that hangs off a control stays at the
/// control duration, because it is the size of one.
class PlassPortal extends StatefulWidget {
  /// Creates a layer.
  const PlassPortal({
    required this.open,
    required this.child,
    this.barrierColor,
    this.barrierBlur = 0,
    this.modal = true,
    this.onDismiss,
    this.label,
    super.key,
  });

  /// Whether the layer is up.
  final bool open;

  /// What is laid over the backdrop, already aligned and padded.
  final Widget child;

  /// What the backdrop is washed with. `null` paints nothing, and the layer
  /// still catches the pointer — which is the whole reason to ask for it.
  final Color? barrierColor;

  /// How far the backdrop blurs what is behind it, as a CSS `blur()` radius.
  ///
  /// `0` leaves the filter out entirely rather than asking for a blur of zero:
  /// a `BackdropFilter` over the whole viewport is a saved layer per frame.
  final double barrierBlur;

  /// Whether the page behind is taken away for the pointer as well as the
  /// keyboard.
  ///
  /// `false` leaves the page clickable and scrollable while focus is still held
  /// inside the layer, which is what a layer drawing nothing usually wants.
  final bool modal;

  /// Called when the layer asks to be closed — a press outside it, or
  /// <kbd>Escape</kbd>. `null` is a layer that cannot be dismissed.
  final VoidCallback? onDismiss;

  /// The name a screen reader gives the layer.
  final String? label;

  @override
  State<PlassPortal> createState() => _PlassPortalState();
}

class _PlassPortalState extends State<PlassPortal> with SingleTickerProviderStateMixin {
  final OverlayPortalController _portal = OverlayPortalController();
  final FocusScopeNode _scope = FocusScopeNode(debugLabel: 'PlassPortal');
  // Overwritten in `build`, which is where the reader's motion preference can
  // be read. The value here is what the first frame would use if it ran before
  // one, so it is the one `build` will set rather than a different number.
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: PlassTokens.durationSlow,
  );

  /// Where focus was before the layer went up, so it can be put back.
  FocusNode? _restore;

  @override
  void initState() {
    super.initState();
    _fade.addStatusListener(_onFade);

    if (widget.open) {
      _show();
    }
  }

  @override
  void didUpdateWidget(PlassPortal oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.open != oldWidget.open) {
      widget.open ? _show() : _hide();
    }
  }

  @override
  void dispose() {
    _fade.removeStatusListener(_onFade);
    _fade.dispose();
    _scope.dispose();
    super.dispose();
  }

  void _onFade(AnimationStatus status) {
    // Taken down only once it has finished going out, so the fade is seen
    // rather than skipped by the widget disappearing on the first frame.
    if (status == AnimationStatus.dismissed && _portal.isShowing) {
      _portal.hide();
    }
  }

  /// Runs [callback] once the frame that asked for it is over.
  ///
  /// Everything a layer does to itself is out of bounds during a build, and a
  /// build is nearly always where the change arrives from: a `setState` above
  /// it. So the work is queued rather than refused.
  void _afterFrame(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((Duration _) => callback());
  }

  void _show() {
    _restore = FocusManager.instance.primaryFocus;

    _afterFrame(() {
      if (!mounted || !widget.open) {
        return;
      }

      _portal.show();
      _fade.forward();

      // One more frame: the layer has to be in the tree before its scope can be
      // asked for focus. It is asked rather than autofocused because Flutter
      // applies an autofocus only when nothing in the enclosing scope holds
      // focus, and something almost always does — whatever opened the layer.
      _afterFrame(() {
        if (mounted && widget.open) {
          _scope.requestFocus();
        }
      });
    });
  }

  void _hide() {
    _fade.reverse();

    // Back where it came from, which is the half of a focus trap that is easy
    // to forget: a dialog that leaves focus on the body drops the reader at the
    // top of the page.
    final restore = _restore;
    _restore = null;

    if (restore != null && restore.context != null) {
      restore.requestFocus();
    }
  }

  void _dismiss() {
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    _fade.duration = reduceMotion ? Duration.zero : PlassTokens.durationSlow;

    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _buildLayer,
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildLayer(BuildContext context) {
    Widget backdrop = widget.barrierColor == null
        ? const SizedBox.expand()
        : ColoredBox(color: widget.barrierColor!, child: const SizedBox.expand());

    if (widget.barrierBlur > 0) {
      backdrop = BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: widget.barrierBlur, sigmaY: widget.barrierBlur),
        child: backdrop,
      );
    }

    // The press that closes is on the backdrop rather than on the layer, so a
    // press that lands on the content is not an outside press. Opaque so that
    // nothing behind it is reached even where nothing is painted.
    backdrop = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onDismiss == null ? null : _dismiss,
      child: backdrop,
    );

    Widget layer = Stack(
      fit: StackFit.expand,
      children: <Widget>[
        widget.modal ? backdrop : IgnorePointer(child: backdrop),
        widget.child,
      ],
    );

    layer = FadeTransition(opacity: _fade, child: layer);

    // `Shortcuts` outside the scope and `Actions` between them: a shortcut is
    // answered by an ancestor of whatever holds focus, and the action it looks
    // up has to be one too.
    return Semantics(
      container: true,
      explicitChildNodes: true,
      scopesRoute: true,
      namesRoute: widget.label != null,
      label: widget.label,
      child: Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (DismissIntent intent) {
                _dismiss();

                return null;
              },
            ),
          },
          // Focus goes in and stays in: traversal is bounded by the nearest
          // scope, so a `Tab` inside the layer cannot land on the page under it.
          child: FocusScope(node: _scope, child: layer),
        ),
      ),
    );
  }
}
