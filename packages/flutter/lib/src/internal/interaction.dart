/// Hover, press, focus and where the pointer is.
///
/// Every interactive Plass surface answers the same four questions, and answers
/// them the same way: hover comes from a [MouseRegion] rather than from the
/// focus system's highlight mode, the focus ring appears only on what CSS calls
/// `:focus-visible`, the pointer's position is tracked while a finger is down as
/// well as while a mouse is over — which is what makes the interaction light
/// follow a drag on a touch screen — and a tap on an unavailable control is
/// swallowed rather than falling through to whatever is behind it.
///
/// Written once here because those are four chances to be subtly wrong, and a
/// library with fifteen interactive components would otherwise take them fifteen
/// times.
///
/// None of this is exported from `plass_ui.dart` — it is the library talking to
/// itself. Semantics deliberately stay out: what a surface *is* to a screen
/// reader differs for every component, and a wrapper that guessed would be a
/// wrapper each component had to work around.
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// What the pointer and the keyboard are currently doing to a surface.
@immutable
class PlassInteraction {
  /// Creates a state. Only [PlassInteractive] should need to.
  const PlassInteraction({
    this.hovered = false,
    this.pressed = false,
    this.focusVisible = false,
    this.pointer,
  });

  /// Whether a mouse is over the surface. Never true for a finger — which is
  /// the right analogue of `@media (hover: hover)`.
  final bool hovered;

  /// Whether it is being held down.
  final bool pressed;

  /// Whether a *keyboard* reached it. A mouse click never sets this.
  final bool focusVisible;

  /// Where the pointer is, in the surface's own coordinates, or `null` if it
  /// has never been over it.
  final Offset? pointer;

  @override
  bool operator ==(Object other) {
    return other is PlassInteraction &&
        other.hovered == hovered &&
        other.pressed == pressed &&
        other.focusVisible == focusVisible &&
        other.pointer == pointer;
  }

  @override
  int get hashCode => Object.hash(hovered, pressed, focusVisible, pointer);
}

/// Builds a surface from the state the pointer and the keyboard put it in.
typedef PlassInteractionBuilder = Widget Function(BuildContext context, PlassInteraction state);

/// Wraps [builder] in the whole interaction apparatus.
///
/// A surface that should stay reachable by pointer but out of the tab order —
/// one option in a set with a roving focus — is wrapped in an [ExcludeFocus] by
/// its parent rather than told so here: the decision belongs to whatever knows
/// which member currently holds the stop.
///
/// [enabled] governs whether the surface can be *reached* — focus, in other
/// words. [interactive] governs whether it *responds*. They are separate because
/// `loading` and `readOnly` stop a control firing without taking it out of the
/// focus order, and `disabled` does both: dropping out of the focus order costs
/// keyboard users their sense of the page, and it should take a real decision to
/// do it.
class PlassInteractive extends StatefulWidget {
  /// Creates an interactive surface.
  const PlassInteractive({
    required this.builder,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.interactive = true,
    this.cursor = SystemMouseCursors.click,
    this.focusNode,
    this.autofocus = false,
    this.behavior = HitTestBehavior.opaque,
    this.shortcuts = defaultShortcuts,
    this.onFocusChange,
    super.key,
  });

  /// Draws the surface from the current state.
  final PlassInteractionBuilder builder;

  /// Called when the surface is activated, by pointer or by keyboard.
  final VoidCallback? onTap;

  /// Called on a long press — the touch equivalent of a context menu.
  final VoidCallback? onLongPress;

  /// Whether the surface can take focus at all.
  final bool enabled;

  /// Whether it reacts to the pointer and fires its callbacks.
  final bool interactive;

  /// The cursor over it.
  final MouseCursor cursor;

  /// Drive focus from outside. Left out, the surface owns one of its own.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  /// How the gesture detector treats hits. [HitTestBehavior.opaque] is what
  /// stops a tap on an unavailable control reaching whatever is behind it.
  final HitTestBehavior behavior;

  /// The keys that activate it.
  ///
  /// Declared rather than inherited, so a component works the same in a bare
  /// [WidgetsApp], inside somebody else's shortcut scope, or with no app widget
  /// above it at all. The scope is this surface, so nothing an app binds
  /// elsewhere is shadowed.
  final Map<ShortcutActivator, Intent> shortcuts;

  /// Called when the surface gains or loses focus, however it was reached.
  final ValueChanged<bool>? onFocusChange;

  /// <kbd>Enter</kbd>, the numpad <kbd>Enter</kbd> and <kbd>Space</kbd> — what
  /// activates a button on every platform.
  static const Map<ShortcutActivator, Intent> defaultShortcuts = <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
  };

  /// The same set with <kbd>Space</kbd> left out.
  ///
  /// For a control inside something that scrolls, where the space bar belongs to
  /// the scroller — and for anything a screen reader drives with <kbd>Enter</kbd>
  /// alone.
  static const Map<ShortcutActivator, Intent> enterOnly = <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
  };

  @override
  State<PlassInteractive> createState() => PlassInteractiveState();
}

/// The state behind a [PlassInteractive]. Public so that a component holding a
/// [GlobalKey] to one can ask it to take focus.
class PlassInteractiveState extends State<PlassInteractive> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focusVisible = false;
  Offset? _pointer;

  void _setPointer(Offset position) {
    // Written on every pointer frame, so it is deliberately not `setState` for
    // its own sake — but a radial gradient has to be rebuilt to move, and the
    // `RepaintBoundary` the light sits behind keeps that repaint off the label.
    //
    // It runs while a finger is down too, which is what makes the light follow a
    // drag on a touch screen: there is no hover there, and the press layer is
    // the one doing the work.
    if (_pointer != position) {
      setState(() => _pointer = position);
    }
  }

  void _activate() {
    if (widget.interactive) {
      widget.onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hover and press only *look* like anything while the surface can be used.
    final state = PlassInteraction(
      hovered: widget.interactive && _hovered,
      pressed: widget.interactive && _pressed,
      focusVisible: _focusVisible,
      pointer: _pointer,
    );

    return FocusableActionDetector(
      enabled: widget.enabled,
      descendantsAreFocusable: true,
      // The component wraps its own `Semantics` around whatever this builds, so
      // a focus node of its own would be a second node above that one — and a
      // chip would reach a screen reader as an unnamed focusable thing
      // containing a button. Every caller says what it is; this only has to
      // make it reachable.
      includeFocusSemantics: false,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      mouseCursor: widget.cursor,
      onFocusChange: widget.onFocusChange,
      // The focus ring only appears on what CSS calls `:focus-visible` — a
      // keyboard reaching the control, never a mouse clicking it. This is
      // Flutter's name for the same distinction.
      //
      // Hover is deliberately *not* taken from this widget's own
      // `onShowHoverHighlight`, which is gated on the focus system's highlight
      // mode: whether the pointer is over the surface is the whole question, and
      // the `MouseRegion` below answers exactly it.
      onShowFocusHighlight: (bool value) {
        if (_focusVisible != value) {
          setState(() => _focusVisible = value);
        }
      },
      shortcuts: widget.shortcuts,
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent intent) {
            _activate();
            return null;
          },
        ),
        ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
          onInvoke: (ButtonActivateIntent intent) {
            _activate();
            return null;
          },
        ),
      },
      child: MouseRegion(
        onEnter: (PointerEnterEvent event) {
          _setPointer(event.localPosition);
          setState(() => _hovered = true);
        },
        onExit: (PointerExitEvent event) => setState(() => _hovered = false),
        onHover: (PointerHoverEvent event) => _setPointer(event.localPosition),
        child: Listener(
          onPointerDown: (PointerDownEvent event) => _setPointer(event.localPosition),
          onPointerMove: (PointerMoveEvent event) => _setPointer(event.localPosition),
          child: GestureDetector(
            behavior: widget.behavior,
            // Described by whatever `Semantics` the component put around this,
            // which knows about `readOnly` and `loading` and this does not.
            excludeFromSemantics: true,
            // Always present, even when nothing will happen: the recogniser is
            // what stops a tap on an unavailable control reaching whatever is
            // behind it. A row that navigates should not navigate because
            // someone tried the disabled button inside it.
            onTap: _activate,
            onLongPress: widget.interactive ? widget.onLongPress : null,
            onTapDown: (TapDownDetails details) => setState(() => _pressed = true),
            onTapUp: (TapUpDetails details) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: Builder(builder: (BuildContext context) => widget.builder(context, state)),
          ),
        ),
      ),
    );
  }
}
