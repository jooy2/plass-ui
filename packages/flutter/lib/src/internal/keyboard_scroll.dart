/// Scrolling a view from the keyboard.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
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
/// nothing to the tab order. The ring is drawn around the box while the box
/// itself holds a focus that arrived from the keyboard, and never for a stop
/// inside it, which draws its own.
class PlassKeyboardScroll extends StatefulWidget {
  /// Wraps [child], the scroll views that [vertical] and [horizontal] drive.
  const PlassKeyboardScroll({
    required this.borderRadius,
    required this.child,
    this.vertical,
    this.horizontal,
    this.ringOffset = focusRingOffset,
    this.color,
    super.key,
  });

  /// The controller of the view that scrolls down, if there is one.
  final ScrollController? vertical;

  /// The controller of the view that scrolls along the row, if there is one.
  final ScrollController? horizontal;

  /// The corners the focus ring follows.
  final BorderRadius borderRadius;

  /// How far outside the box the focus ring sits.
  ///
  /// Negative draws it inside, for a box that lives inside something that
  /// clips, as a table's grid does inside its sheet: a ring drawn outside it
  /// would be cut off along with the overflow.
  final double ringOffset;

  /// The family the ring is drawn from, when the widget around the box has one
  /// of its own rather than the theme's.
  final PlassColor? color;

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
    _node.addListener(_onFocus);
    WidgetsBinding.instance.addPostFrameCallback((Duration _) => _check());
  }

  @override
  void dispose() {
    _node
      ..removeListener(_onFocus)
      ..dispose();
    super.dispose();
  }

  /// Rings the box while it holds the focus itself, as `:focus-visible` on the
  /// React box does.
  ///
  /// Read off the node rather than off `Focus.onFocusChange`, whose `hasFocus`
  /// counts a focused descendant as well: a sort heading inside a table would
  /// ring the whole box as well as itself, and the ring would stay when the
  /// focus moved from the box to a stop inside it. The node tells its
  /// listeners when it gains or loses the primary focus, either way.
  void _onFocus() {
    final bool visible =
        _node.hasPrimaryFocus &&
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

    if (visible != _focusVisible) {
      setState(() => _focusVisible = visible);
    }
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
      final tokens = PlassTheme.of(context);

      controller.animateTo(target, duration: tokens.motionDuration, curve: tokens.motionEase);
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
    final family = tokens.family(widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary);

    return CustomPaint(
      foregroundPainter: _focusVisible
          ? PlassFocusRingPainter(
              color: family.ring,
              borderRadius: widget.borderRadius,
              offset: widget.ringOffset,
            )
          : null,
      child: Focus(
        focusNode: _node,
        canRequestFocus: _scrollable,
        skipTraversal: !_scrollable,
        onKeyEvent: _onKey,
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
