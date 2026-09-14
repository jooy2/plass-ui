/// Scrolling a view from the keyboard.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How far one arrow key press moves the view, about a line of body text.
const double _line = 40;

/// Makes a scroll view a tab stop while it has somewhere to scroll, and moves it
/// with the keys a browser moves a scrollable box with.
///
/// A box of text with nothing focusable in it, terms of service or a shelf with
/// no buttons, is otherwise out of reach of anyone without a pointer. The arrow
/// keys move it a line, Page Up and Page Down a screen, and Home and End to its
/// ends. The left and right arrows follow the writing direction.
///
/// The stop exists only while the content overflows, so a box that fits adds
/// nothing to the tab order. The ring is drawn around the box while the focus
/// arrived from the keyboard.
class PlassKeyboardScroll extends StatefulWidget {
  /// Wraps [child], the scroll views that [vertical] and [horizontal] drive.
  const PlassKeyboardScroll({
    required this.borderRadius,
    required this.child,
    this.vertical,
    this.horizontal,
    super.key,
  });

  /// The controller of the view that scrolls down, if there is one.
  final ScrollController? vertical;

  /// The controller of the view that scrolls along the row, if there is one.
  final ScrollController? horizontal;

  /// The corners the focus ring follows.
  final BorderRadius borderRadius;

  /// The scroll views.
  final Widget child;

  @override
  State<PlassKeyboardScroll> createState() => _PlassKeyboardScrollState();
}

class _PlassKeyboardScrollState extends State<PlassKeyboardScroll> {
  final FocusNode _node = FocusNode(debugLabel: 'PlassKeyboardScroll');

  bool _scrollable = false;
  bool _focusVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) => _check());
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  static bool _overflows(ScrollController? controller) {
    return controller != null &&
        controller.hasClients &&
        controller.position.hasContentDimensions &&
        controller.position.maxScrollExtent > controller.position.minScrollExtent;
  }

  /// Whether either view has anywhere to go, read after layout.
  void _check() {
    if (!mounted) {
      return;
    }

    final scrollable = _overflows(widget.vertical) || _overflows(widget.horizontal);

    if (scrollable != _scrollable) {
      setState(() => _scrollable = scrollable);
    }
  }

  bool get _reduceMotion => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// Moves [controller] to [offset], held inside its extent.
  KeyEventResult _to(ScrollController? controller, double Function(ScrollPosition) offset) {
    if (!_overflows(controller)) {
      return KeyEventResult.ignored;
    }

    final position = controller!.position;
    final target = offset(position).clamp(position.minScrollExtent, position.maxScrollExtent);

    if (_reduceMotion) {
      controller.jumpTo(target);
    } else {
      controller.animateTo(target, duration: PlassTokens.duration, curve: PlassTokens.ease);
    }

    return KeyEventResult.handled;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    // Page Up, Page Down, Home and End move the view that scrolls down, or the
    // only one there is.
    final primary = widget.vertical ?? widget.horizontal;
    // Under RTL a row scrolls from the right, so the left arrow is further on.
    final along = Directionality.of(context) == TextDirection.rtl ? -_line : _line;

    if (key == LogicalKeyboardKey.arrowDown) {
      return _to(widget.vertical, (ScrollPosition position) => position.pixels + _line);
    }

    if (key == LogicalKeyboardKey.arrowUp) {
      return _to(widget.vertical, (ScrollPosition position) => position.pixels - _line);
    }

    if (key == LogicalKeyboardKey.arrowRight) {
      return _to(widget.horizontal, (ScrollPosition position) => position.pixels + along);
    }

    if (key == LogicalKeyboardKey.arrowLeft) {
      return _to(widget.horizontal, (ScrollPosition position) => position.pixels - along);
    }

    if (key == LogicalKeyboardKey.pageDown) {
      return _to(
        primary,
        (ScrollPosition position) => position.pixels + position.viewportDimension,
      );
    }

    if (key == LogicalKeyboardKey.pageUp) {
      return _to(
        primary,
        (ScrollPosition position) => position.pixels - position.viewportDimension,
      );
    }

    if (key == LogicalKeyboardKey.home) {
      return _to(primary, (ScrollPosition position) => position.minScrollExtent);
    }

    if (key == LogicalKeyboardKey.end) {
      return _to(primary, (ScrollPosition position) => position.maxScrollExtent);
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(PlassTheme.colorOf(context) ?? PlassColor.primary);

    return CustomPaint(
      foregroundPainter: _focusVisible
          ? PlassFocusRingPainter(color: family.ring, borderRadius: widget.borderRadius)
          : null,
      child: Focus(
        focusNode: _node,
        canRequestFocus: _scrollable,
        skipTraversal: !_scrollable,
        onKeyEvent: _onKey,
        onFocusChange: (bool has) {
          setState(() {
            _focusVisible =
                has && FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
          });
        },
        // Content that grows or shrinks changes whether there is anything to
        // scroll, and the answer can only be read once it is laid out.
        child: NotificationListener<ScrollMetricsNotification>(
          onNotification: (ScrollMetricsNotification notification) {
            WidgetsBinding.instance.addPostFrameCallback((Duration _) => _check());

            return false;
          },
          child: widget.child,
        ),
      ),
    );
  }
}
