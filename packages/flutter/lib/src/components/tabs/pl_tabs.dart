/// A bar of tabs, and the panel under whichever one is chosen.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How thick the indicator bar is on a `glass` or `ghost` set.
const double _indicatorThickness = 2;

/// The room a `solid` bar keeps around the tile riding in it.
const double _troughInset = 4;

/// One tab, and the panel it opens.
///
/// A description rather than a widget: the bar owns the roving focus, the arrow
/// keys and the indicator that slides between the tabs, so it has to know which
/// one is chosen and where each one is.
@immutable
class PlTab<T> {
  /// Creates a tab.
  const PlTab({
    required this.value,
    this.label,
    this.startIcon,
    this.endIcon,
    this.disabled = false,
    this.panel,
  });

  /// Identifies the tab. What [PlTabs.value] holds.
  final T value;

  /// What the tab says.
  final Widget? label;

  /// Content before the label.
  final Widget? startIcon;

  /// Content after it — a count, a status dot.
  final Widget? endIcon;

  /// Unavailable, but still in the bar.
  final bool disabled;

  /// What is shown under the bar when this tab is chosen.
  ///
  /// Only the chosen panel is built, which is the difference from a set of
  /// panels a caller stacks themselves: a tab that is not open costs nothing.
  final Widget? panel;
}

/// A bar of tabs, and the panel under whichever one is chosen.
///
/// ```dart
/// PlTabs<String>(
///   value: tab,
///   onChanged: (String next) => setState(() => tab = next),
///   tabs: <PlTab<String>>[
///     PlTab<String>(value: 'overview', label: const Text('Overview'), panel: overview),
///     PlTab<String>(value: 'activity', label: const Text('Activity'), panel: activity),
///   ],
/// )
/// ```
///
/// [variant] describes the **bar**, not the panels under it:
///
/// - [PlassVariant.solid] — a groove cut into the sheet with a clear pane riding
///   in it. The tile is deliberately *not* the gradient: that is what a
///   segmented button is, and a screen with both should be able to tell them
///   apart.
/// - [PlassVariant.glass] — the classic: a rule along the edge of the bar with
///   the indicator riding on it. The default.
/// - [PlassVariant.ghost] — the same bar with the rule taken away, for tabs
///   inside a card that already has an edge of its own.
class PlTabs<T> extends StatefulWidget {
  /// Creates a set of tabs.
  const PlTabs({
    required this.tabs,
    required this.value,
    this.onChanged,
    this.variant = PlassVariant.glass,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    this.orientation = PlassOrientation.horizontal,
    this.fullWidth = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// The tabs, in order.
  final List<PlTab<T>> tabs;

  /// Which one is chosen, or `null` for none.
  final T? value;

  /// Called with the tab that was chosen.
  final ValueChanged<T>? onChanged;

  /// What the **bar** is made of.
  final PlassVariant variant;

  /// Height and type scale. A tab takes the control ladder, so an `md` tab and
  /// an `md` button are the same 40px and a bar in a toolbar keeps its baseline.
  final PlassSize size;

  /// Semantic colour role. It reaches the indicator and the chosen tab's label.
  final PlassColor color;

  /// Changes horizontal padding and nothing else.
  final PlassDensity density;

  /// Which way the bar runs.
  final PlassOrientation orientation;

  /// The tabs share the bar's width, each taking an equal part of it.
  final bool fullWidth;

  /// The name a screen reader gives the bar.
  final String? semanticLabel;

  /// Drive the bar's one focus stop from outside.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  @override
  State<PlTabs<T>> createState() => _PlTabsState<T>();
}

class _PlTabsState<T> extends State<PlTabs<T>> {
  final List<GlobalKey> _keys = <GlobalKey>[];
  final GlobalKey _bar = GlobalKey();

  Rect? _indicator;

  bool get _vertical => widget.orientation == PlassOrientation.vertical;

  int get _chosen => widget.tabs.indexWhere((PlTab<T> one) => one.value == widget.value);

  int get _focused {
    final chosen = _chosen;

    if (chosen >= 0) {
      return chosen;
    }

    final first = widget.tabs.indexWhere((PlTab<T> one) => !one.disabled);

    return first < 0 ? 0 : first;
  }

  @override
  void initState() {
    super.initState();
    _syncKeys();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) => _measure());
  }

  @override
  void didUpdateWidget(PlTabs<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncKeys();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) => _measure());
  }

  void _syncKeys() {
    while (_keys.length < widget.tabs.length) {
      _keys.add(GlobalKey());
    }

    if (_keys.length > widget.tabs.length) {
      _keys.removeRange(widget.tabs.length, _keys.length);
    }
  }

  /// Reads the chosen tab's box, in the bar's own coordinates.
  ///
  /// A measurement rather than arithmetic on the count: tabs are as wide as
  /// their labels unless `fullWidth` says otherwise, and an indicator placed by
  /// division would sit under the wrong one the moment two labels differ.
  void _measure() {
    if (!mounted) {
      return;
    }

    final chosen = _chosen;
    final bar = _bar.currentContext?.findRenderObject() as RenderBox?;
    final tab = chosen >= 0 ? _keys[chosen].currentContext?.findRenderObject() as RenderBox? : null;

    final next = tab != null && bar != null && tab.hasSize && bar.hasSize
        ? (tab.localToGlobal(Offset.zero, ancestor: bar) & tab.size)
        : null;

    if (next != _indicator) {
      setState(() => _indicator = next);
    }
  }

  void _move(int step) {
    if (widget.onChanged == null || widget.tabs.isEmpty) {
      return;
    }

    final count = widget.tabs.length;
    var index = _focused;

    for (var tried = 0; tried < count; tried += 1) {
      index = (index + step + count) % count;

      if (!widget.tabs[index].disabled) {
        widget.onChanged!(widget.tabs[index].value);

        return;
      }
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final forward = _vertical ? LogicalKeyboardKey.arrowDown : LogicalKeyboardKey.arrowRight;
    final back = _vertical ? LogicalKeyboardKey.arrowUp : LogicalKeyboardKey.arrowLeft;

    if (event.logicalKey == forward) {
      _move(1);

      return KeyEventResult.handled;
    }

    if (event.logicalKey == back) {
      _move(-1);

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(widget.color);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final solid = widget.variant == PlassVariant.solid;
    final inset = solid ? _troughInset : 0.0;
    final chosen = _chosen;

    final tabs = <Widget>[
      for (var index = 0; index < widget.tabs.length; index += 1)
        _Tab<T>(
          key: _keys[index],
          tab: widget.tabs[index],
          chosen: index == chosen,
          size: widget.size,
          density: widget.density,
          family: family,
          tokens: tokens,
          disabled: widget.tabs[index].disabled || widget.onChanged == null,
          onPressed: widget.onChanged != null && !widget.tabs[index].disabled
              ? () => widget.onChanged!(widget.tabs[index].value)
              : null,
          focusable: index == _focused,
          focusNode: index == _focused ? widget.focusNode : null,
          autofocus: index == _focused && widget.autofocus,
        ),
    ];

    Widget strip = _vertical
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: tabs,
          )
        : Row(
            mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            children: <Widget>[
              for (final tab in tabs)
                if (widget.fullWidth) Expanded(child: tab) else tab,
            ],
          );

    final motion = reduceMotion ? Duration.zero : PlassTokens.duration;
    final mark = _Indicator(
      variant: widget.variant,
      family: family,
      tokens: tokens,
      size: widget.size,
    );

    strip = Stack(
      key: _bar,
      children: <Widget>[
        if (_indicator != null)
          // Three shapes, one measurement: a `solid` set fills the tab with a
          // tile, and the other two lay a rule along the bar's own edge — under
          // a horizontal bar, beside a vertical one.
          if (solid)
            AnimatedPositioned(
              duration: motion,
              curve: PlassTokens.ease,
              left: _indicator!.left,
              top: _indicator!.top,
              width: _indicator!.width,
              height: _indicator!.height,
              child: mark,
            )
          else if (_vertical)
            AnimatedPositionedDirectional(
              duration: motion,
              curve: PlassTokens.ease,
              end: 0,
              top: _indicator!.top,
              width: _indicatorThickness,
              height: _indicator!.height,
              child: mark,
            )
          else
            AnimatedPositioned(
              duration: motion,
              curve: PlassTokens.ease,
              left: _indicator!.left,
              bottom: 0,
              width: _indicator!.width,
              height: _indicatorThickness,
              child: mark,
            ),
        strip,
      ],
    );

    if (solid) {
      strip = PlassSurfaceBox(
        surface: PlassSurface(
          fill: tokens.glass,
          ink: tokens.fg,
          blur: true,
          insets: <PlassInsetShadow>[tokens.well],
        ),
        borderRadius: BorderRadius.circular(PlassTokens.radius[widget.size]!),
        child: Padding(padding: EdgeInsets.all(inset), child: strip),
      );
    } else if (widget.variant == PlassVariant.glass) {
      // One rule on one edge rather than a box: it belongs under a horizontal
      // bar and beside a vertical one. The neutral hairline rather than the
      // sheet's own white one, because a bar drawn on a light card would
      // otherwise have no rule at all.
      strip = DecoratedBox(
        decoration: BoxDecoration(
          border: _vertical
              ? BorderDirectional(
                  end: BorderSide(color: tokens.border, width: hairline),
                )
              : Border(
                  bottom: BorderSide(color: tokens.border, width: hairline),
                ),
        ),
        child: strip,
      );
    }

    final panel = chosen >= 0 ? widget.tabs[chosen].panel : null;

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _onKey,
      child: Flex(
        direction: _vertical ? Axis.horizontal : Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          Semantics(
            container: true,
            explicitChildNodes: true,
            label: widget.semanticLabel,
            child: widget.fullWidth && !_vertical ? strip : IntrinsicWidth(child: strip),
          ),
          if (panel != null) _vertical ? Expanded(child: panel) : panel,
        ],
      ),
    );
  }
}

/// The indicator: a tile on a `solid` bar, a rule on the other two.
class _Indicator extends StatelessWidget {
  const _Indicator({
    required this.variant,
    required this.family,
    required this.tokens,
    required this.size,
  });

  final PlassVariant variant;
  final PlassColorFamily family;
  final PlassTokens tokens;
  final PlassSize size;

  @override
  Widget build(BuildContext context) {
    if (variant == PlassVariant.solid) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.glassPress,
          borderRadius: BorderRadius.circular(PlassTokens.radius[size]!),
          boxShadow: tokens.elevation(1),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: family.accent,
        borderRadius: BorderRadius.circular(_indicatorThickness),
      ),
    );
  }
}

/// One drawn tab.
class _Tab<T> extends StatelessWidget {
  const _Tab({
    required this.tab,
    required this.chosen,
    required this.size,
    required this.density,
    required this.family,
    required this.tokens,
    required this.disabled,
    required this.onPressed,
    required this.focusable,
    required this.focusNode,
    required this.autofocus,
    super.key,
  });

  final PlTab<T> tab;
  final bool chosen;
  final PlassSize size;
  final PlassDensity density;
  final PlassColorFamily family;
  final PlassTokens tokens;
  final bool disabled;
  final VoidCallback? onPressed;
  final bool focusable;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final fontSize = controlText[size]!;
    final height = controlHeight[size]!;

    return ExcludeFocus(
      excluding: !focusable,
      child: PlassInteractive(
        onTap: onPressed,
        interactive: onPressed != null,
        enabled: !disabled,
        focusNode: focusNode,
        autofocus: autofocus,
        cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        builder: (BuildContext context, PlassInteraction state) {
          final ink = disabled
              ? tokens.mutedFg
              : chosen
              ? family.accent
              : state.hovered
              ? tokens.fg
              : tokens.mutedFg;

          Widget body = SizedBox(
            height: height,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: paddingX[density]![size]!),
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: ink,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
                maxLines: 1,
                softWrap: false,
                child: IconTheme.merge(
                  data: IconThemeData(color: ink, size: fontSize * iconScale),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: gap[size]!,
                    children: <Widget>[?tab.startIcon, ?tab.label, ?tab.endIcon],
                  ),
                ),
              ),
            ),
          );

          body = plassStateFilter(child: body, disabled: disabled, lit: false);

          if (state.focusVisible) {
            body = CustomPaint(
              foregroundPainter: PlassFocusRingPainter(
                color: family.ring,
                borderRadius: BorderRadius.circular(PlassTokens.radius[size]!),
                // A tab sits on a rail that clips, so its ring turns inward.
                offset: -focusRingWidth,
              ),
              child: body,
            );
          }

          return Semantics(
            container: true,
            inMutuallyExclusiveGroup: true,
            selected: chosen,
            enabled: onPressed != null,
            onTap: onPressed,
            child: body,
          );
        },
      ),
    );
  }
}
