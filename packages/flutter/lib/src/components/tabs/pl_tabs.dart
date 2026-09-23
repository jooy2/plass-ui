/// A bar of tabs, and the panel under whichever one is chosen.
library;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/roving.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/internal/wheel.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How thick the indicator bar is on a `glass` or `ghost` set.
const double _indicatorThickness = 2;

/// The room a `solid` bar keeps around the tile riding in it.
const double _troughInset = 4;

/// How much of each end of an overflowing bar is faded out.
const double _fadeLength = 24;

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
    this.size,
    this.color,
    this.density,
    this.orientation = const PlassResponsive<PlassOrientation>(PlassOrientation.horizontal),
    this.align = PlassAlign.center,
    this.fullWidth = false,
    this.wheel = true,
    this.overscroll = PlassOverscroll.contain,
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
  final PlassSize? size;

  /// Semantic colour role. It reaches the indicator and the chosen tab's label.
  final PlassColor? color;

  /// Changes horizontal padding and nothing else.
  final PlassDensity? density;

  /// Which way the bar runs.
  ///
  /// **Responsive**, so a set can run one way on a phone and the other on a
  /// laptop. It is resolved against the window's width in `build` rather than
  /// laid out by a constraint, which is what makes two of these side by side
  /// agree about which rung they are on.
  final PlassResponsive<PlassOrientation> orientation;

  /// Where each tab's label sits inside the tab, once the tab is wider than the
  /// label is.
  ///
  /// Which is the part worth saying: this moves the words, never the tabs. A
  /// horizontal bar sizes every tab to its own label, so there is no room for a
  /// label to move in and nothing changes — it takes effect on a vertical bar,
  /// whose tabs are all as wide as the widest, and on a [fullWidth] one, whose
  /// tabs are all an equal share of the bar. [PlassAlign.start] is what a bar
  /// down the side of a settings page usually wants, so the names line up as a
  /// list rather than drifting around a centre line.
  ///
  /// Logical rather than physical: `start` is the left under `ltr` and the
  /// right under `rtl`, and an icon beside the label travels with it.
  final PlassAlign align;

  /// The tabs share the bar's width, each taking an equal part of it.
  final bool fullWidth;

  /// Whether a wheel that points across a bar with more tabs than room moves it
  /// along.
  ///
  /// A mouse has one wheel and it points down the page, which is the one
  /// direction a horizontal bar does not run in — so a reader who can see that
  /// there are more tabs has no way of reaching them but the arrow keys, which
  /// also change the selection. The bar is the same scroller a `PlScrollZone`
  /// is and answers the wheel the same way.
  ///
  /// Only while the bar overflows, and only across: a bar that runs down the
  /// side already scrolls the way the wheel does.
  final bool wheel;

  /// What the bar does with a wheel it has run out of tabs for.
  ///
  /// [PlassOverscroll.contain], the default, keeps it, so a reader working along
  /// a long bar is not thrown down the page by the notch that arrives after the
  /// last tab. [PlassOverscroll.auto] gives it back to whatever is behind the
  /// bar, holding it only for as long as the flick lasts. A bar whose tabs all
  /// fit holds nothing back either way.
  final PlassOverscroll overscroll;

  /// The name a screen reader gives the bar.
  final String? semanticLabel;

  /// Drive the bar's one focus stop from outside.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  @override
  State<PlTabs<T>> createState() => _PlTabsState<T>();
}

class _PlTabsState<T> extends State<PlTabs<T>> with PlassRovingStop<PlTabs<T>> {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

  final List<GlobalKey> _keys = <GlobalKey>[];
  final GlobalKey _bar = GlobalKey();

  Rect? _indicator;

  @override
  FocusNode? get callerStop => widget.focusNode;

  bool get _vertical => resolveResponsive(context, widget.orientation) == PlassOrientation.vertical;

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
    keepStop(oldWidget.focusNode);
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

    // A row runs the way the text does, so under RTL the next tab is the one to
    // the left. A column runs down in every direction.
    final rtl = !_vertical && Directionality.of(context) == TextDirection.rtl;
    final forward = _vertical
        ? LogicalKeyboardKey.arrowDown
        : (rtl ? LogicalKeyboardKey.arrowLeft : LogicalKeyboardKey.arrowRight);
    final back = _vertical
        ? LogicalKeyboardKey.arrowUp
        : (rtl ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowLeft);

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
    final family = tokens.family(_color);
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
          size: _size,
          density: _density,
          align: widget.align,
          family: family,
          tokens: tokens,
          disabled: widget.tabs[index].disabled || widget.onChanged == null,
          onPressed: widget.onChanged != null && !widget.tabs[index].disabled
              ? () => widget.onChanged!(widget.tabs[index].value)
              : null,
          focusable: index == _focused,
          focusNode: index == _focused ? stop : null,
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

    final motion = reduceMotion ? Duration.zero : tokens.motionDuration;
    final mark = _Indicator(variant: widget.variant, family: family, tokens: tokens, size: _size);

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
              curve: tokens.motionEase,
              left: _indicator!.left,
              top: _indicator!.top,
              width: _indicator!.width,
              height: _indicator!.height,
              child: mark,
            )
          else if (_vertical)
            AnimatedPositionedDirectional(
              duration: motion,
              curve: tokens.motionEase,
              end: 0,
              top: _indicator!.top,
              width: _indicatorThickness,
              height: _indicator!.height,
              child: mark,
            )
          else
            AnimatedPositioned(
              duration: motion,
              curve: tokens.motionEase,
              left: _indicator!.left,
              bottom: 0,
              width: _indicator!.width,
              height: _indicatorThickness,
              child: mark,
            ),
        strip,
      ],
    );

    // A bar with more tabs than room scrolls rather than wrapping: a tab bar on
    // two lines has stopped being a bar, and the indicator has nowhere sensible
    // to sit. Inside the trough and inside the rule, so that neither of them
    // travels with the tabs — the edge belongs to the bar rather than to what
    // is in it.
    if (!_vertical) {
      strip = _EdgeFade(
        wheel: widget.wheel,
        overscroll: widget.overscroll,
        reveal: chosen >= 0 ? _keys[chosen] : null,
        child: strip,
      );
    }

    if (solid) {
      strip = PlassSurfaceBox(
        surface: PlassSurface(
          fill: tokens.glass,
          ink: tokens.fg,
          blur: true,
          insets: <PlassInsetShadow>[tokens.well],
        ),
        borderRadius: BorderRadius.circular(tokens.radii[_size]!),
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
/// A bar that runs off the end of its own box, and the fade that says so.
///
/// The bar scrolls, which is what makes this necessary: a scroll bar under a row
/// of tab labels is fifteen pixels of furniture on Windows and an overlay that
/// is invisible except while the strip is moving on a Mac — and the moment a
/// reader is deciding whether there is anything more to look at is exactly the
/// moment nothing is moving. So the ends are faded instead, and *only* the end
/// that still has something behind it, which is what makes it a signal rather
/// than a decoration.
///
/// A [ShaderMask] rather than two gradients laid over the ends, for the reason
/// the React package uses a CSS mask: an overlay has to be painted in the colour
/// of whatever is behind the bar, and a bar can sit on anything. Taking the
/// pixels away instead is right on every surface.
///
/// The mask is skipped entirely while both ends are settled, so a bar whose tabs
/// all fit pays for no compositing layer at all.
class _EdgeFade extends StatefulWidget {
  const _EdgeFade({
    required this.wheel,
    required this.overscroll,
    required this.reveal,
    required this.child,
  });

  /// Whether a wheel that points across the bar moves it along.
  final bool wheel;

  /// What the bar does with a wheel it has run out of tabs for.
  final PlassOverscroll overscroll;

  /// The chosen tab, brought into view as the bar is first laid out.
  final GlobalKey? reveal;

  final Widget child;

  @override
  State<_EdgeFade> createState() => _EdgeFadeState();
}

class _EdgeFadeState extends State<_EdgeFade> {
  final ScrollController _controller = ScrollController();

  /// Keeps the scroller when the mask comes or goes around it. Rebuilt at the
  /// new depth instead, it would start again from the first tab, which undid
  /// [_reveal] as soon as the move it made put the mask on.
  final GlobalKey _scroller = GlobalKey();

  bool _start = false;
  bool _end = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      _reveal();
      _onScroll();
    });
  }

  /// Brings the chosen tab into the strip as the bar is first laid out.
  ///
  /// A bar that opens on a tab it has scrolled out of sight does not say which
  /// tab is open. Only this strip moves: [Scrollable.ensureVisible] would move
  /// every scrollable around the bar as well, the page included. It jumps
  /// rather than animates, and moves the least it can, as the React bar does:
  /// not at all while the tab already shows clear of the fade, and otherwise
  /// just far enough to bring the tab's nearer edge the fade's length short of
  /// the edge of the strip. Flush with the edge, the tab would sit under the
  /// fade that side takes on as soon as the strip has moved.
  void _reveal() {
    if (!mounted || !_controller.hasClients) {
      return;
    }

    final RenderObject? tab = widget.reveal?.currentContext?.findRenderObject();

    if (tab == null) {
      return;
    }

    final ScrollPosition position = _controller.position;
    final RenderAbstractViewport viewport = RenderAbstractViewport.of(tab);
    // The offsets that put the tab the fade's length in from the leading edge
    // and from the trailing one. Anywhere between the two, all of it is in view
    // and none of it is faded. At either end of the strip the clamp below wins,
    // and there is no fade on that side to keep clear of. A tab too wide for a
    // fade on both sides keeps its start clear, which is where its label begins.
    final double leading = viewport.getOffsetToReveal(tab, 0).offset - _fadeLength;
    final double trailing = viewport.getOffsetToReveal(tab, 1).offset + _fadeLength;
    final double target = position.pixels
        .clamp(trailing < leading ? trailing : leading, leading)
        .clamp(position.minScrollExtent, position.maxScrollExtent);

    if (target != position.pixels) {
      position.jumpTo(target);
    }
  }

  @override
  void didUpdateWidget(_EdgeFade oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A tab added or renamed changes how far the strip runs without anybody
    // scrolling and without the bar being resized.
    WidgetsBinding.instance.addPostFrameCallback((Duration _) => _onScroll());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (mounted && _controller.hasClients) {
      _read(_controller.position);
    }
  }

  void _read(ScrollMetrics metrics) {
    // A pixel of slack: a fractional layout leaves a strip that fits reporting
    // an extent a hair longer than its box, and a bar that fades because of
    // rounding is a bar that lies.
    final bool start = metrics.pixels > 1;
    final bool end = metrics.maxScrollExtent - metrics.pixels > 1;

    if (start != _start || end != _end) {
      setState(() {
        _start = start;
        _end = end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // The metrics change without anybody scrolling when the bar is resized, and
    // that is the case a scroll listener cannot see. The notification is
    // dispatched after the frame it belongs to, so this may set state directly.
    Widget strip = NotificationListener<ScrollMetricsNotification>(
      key: _scroller,
      onNotification: (ScrollMetricsNotification notification) {
        _read(notification.metrics);

        return false;
      },
      child: PlassWheelScroll(
        controller: _controller,
        turn: widget.wheel,
        overscroll: widget.overscroll,
        child: SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          child: widget.child,
        ),
      ),
    );

    if (!_start && !_end) {
      return strip;
    }

    // The gradient runs in the *reader's* direction rather than the screen's,
    // which is what lets the two middle stops stay the two ends of the strip: a
    // directional alignment resolved against the ambient direction turns the
    // whole thing round under RTL, and nothing else here has to know that it
    // did. The React package cannot do this — a CSS gradient names a physical
    // direction — so it turns the measurement round by hand instead.
    final TextDirection direction = Directionality.of(context);

    strip = ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (Rect bounds) {
        final double fade = bounds.width > 0 ? (_fadeLength / bounds.width).clamp(0.0, 0.5) : 0.0;

        return LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: const <Color>[
            Color(0x00000000),
            Color(0xFF000000),
            Color(0xFF000000),
            Color(0x00000000),
          ],
          stops: <double>[0, _start ? fade : 0, _end ? 1 - fade : 1, 1],
        ).createShader(bounds, textDirection: direction);
      },
      child: strip,
    );

    return strip;
  }
}

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
          borderRadius: BorderRadius.circular(tokens.radii[size]!),
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
    required this.align,
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
  final PlassAlign align;
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
                    // The row is handed a tight width by whatever stretched the
                    // tab, so this is what places the label inside it. `start`
                    // and `end` follow the writing direction, which is what
                    // makes the prop logical without anything being converted.
                    mainAxisAlignment: switch (align) {
                      PlassAlign.start => MainAxisAlignment.start,
                      PlassAlign.center => MainAxisAlignment.center,
                      PlassAlign.end => MainAxisAlignment.end,
                    },
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
                borderRadius: BorderRadius.circular(tokens.radii[size]!),
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
