/// A window, drawn the way one of eight systems draws it.
library;

import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/date.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/window.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

export 'package:plass_ui/src/internal/window.dart' show PlWindowControl, PlWindowOs;

/// A window, drawn the way one of eight systems draws it, with anything at all
/// inside it.
///
/// It is not a real window and does not pretend to be one: there is no desktop,
/// no z-order and no dock. What it is is a *frame that behaves* — the title bar
/// drags, the corners resize, the three buttons are real buttons with real
/// names — so a screenshot of an app, a demo of a feature or a piece of a
/// landing page can be shown as the thing it will be rather than as a picture
/// of it.
///
/// Nothing here is transformed. A dragged window moves on its offset and a
/// resized one changes its width and height, which is what keeps the text
/// inside it at whole pixels through both gestures — a scale would resample
/// every glyph in the window for the length of the drag, which is exactly what
/// the house rule against transforming a surface exists to prevent.
///
/// [minimized] rolls the window up to its title bar rather than sending it
/// anywhere, because a page has nowhere to send it to.
///
/// ```dart
/// PlWindowPane(title: const Text('Notes'), child: MyEditor())
/// ```
class PlWindowPane extends StatefulWidget {
  /// Creates a window.
  const PlWindowPane({
    this.os = PlWindowOs.macos,
    this.title,
    this.icon,
    this.actions,
    this.controls = const <PlWindowControl>{
      PlWindowControl.minimize,
      PlWindowControl.maximize,
      PlWindowControl.close,
    },
    this.size,
    this.color,
    this.accent = false,
    this.transparency = 0,
    this.active = true,
    this.elevation = 2,
    this.draggable = false,
    this.resizable = false,
    this.width,
    this.height,
    this.minWidth = 180,
    this.minHeight,
    this.offset = Offset.zero,
    this.onOffsetChanged,
    this.onResize,
    this.open = true,
    this.onOpenChanged,
    this.minimized = false,
    this.onMinimizedChanged,
    this.maximized = false,
    this.onMaximizedChanged,
    this.minimizeLabel,
    this.maximizeLabel,
    this.restoreLabel,
    this.closeLabel,
    this.resizeLabel,
    this.child,
    super.key,
  });

  /// Whose window this is a picture of.
  final PlWindowOs os;

  /// The window's name, in the title bar.
  final Widget? title;

  /// A glyph beside the title — the app's mark.
  final Widget? icon;

  /// Anything else the title bar carries, set beside the controls.
  final Widget? actions;

  /// Which of the three buttons the title bar has.
  ///
  /// The order is the system's rather than the set's: macOS puts close first
  /// and Windows puts it last, and that is not something a caller should have
  /// to remember.
  final Set<PlWindowControl> controls;

  /// The scale of the chrome — the title bar's height, its buttons and its
  /// type. It does not touch the content, which is the caller's and is laid out
  /// at its own scale.
  final PlassSize? size;

  /// The colour family an `accent` title bar takes.
  final PlassColor? color;

  /// Dyes the title bar with the colour family, the way Windows offers to.
  final bool accent;

  /// How much of what is behind the window shows through its chrome, from `0`
  /// to `1`. It never touches the content, which stays exactly as legible.
  final double transparency;

  /// Whether this is the window in front.
  ///
  /// Unlike the React build this is a plain value rather than something the
  /// window works out for itself. There is no document to listen to here, and a
  /// widget that reached across the tree to find the other windows would be
  /// inventing a desktop.
  final bool active;

  /// The shadow around the window. `2` rather than `0`, because a window is by
  /// definition not part of the page it is on.
  final int elevation;

  /// Lets the title bar be dragged.
  final bool draggable;

  /// Lets the eight edges and corners be dragged.
  final bool resizable;

  /// The window's width.
  final double? width;

  /// And its height. Left out, the window is as tall as what is in it.
  final double? height;

  /// How narrow it may be dragged, in logical pixels.
  final double minWidth;

  /// The same downward. Defaults to the title bar's own height, which is what
  /// is left of a window once the body has been dragged out of it.
  final double? minHeight;

  /// How far it has been dragged from where the layout put it.
  ///
  /// A drag on the left or the top edge moves the window as well as resizing
  /// it, so this reports during a resize too.
  final Offset offset;

  /// Called while the title bar is dragged, and while a leading edge is.
  final ValueChanged<Offset>? onOffsetChanged;

  /// Called with the window's size while an edge is dragged.
  final ValueChanged<Size>? onResize;

  /// Whether the window is on screen at all. Closing it renders nothing.
  final bool open;

  /// Called when the close button is pressed.
  final ValueChanged<bool>? onOpenChanged;

  /// Whether the window is rolled up to its title bar.
  final bool minimized;

  /// Called when the minimize button is pressed.
  final ValueChanged<bool>? onMinimizedChanged;

  /// Whether the window fills whatever is holding it. Its corners go square
  /// while it does, as they do on every system.
  final bool maximized;

  /// Called when the maximize button is pressed.
  final ValueChanged<bool>? onMaximizedChanged;

  /// Overrides the minimize button's name.
  final String? minimizeLabel;

  /// And the maximize button's.
  final String? maximizeLabel;

  /// What the maximize button is called once it is maximized.
  final String? restoreLabel;

  /// And the close button's.
  final String? closeLabel;

  /// What the one reachable resize handle is called.
  final String? resizeLabel;

  /// What is in the window.
  final Widget? child;

  @override
  State<PlWindowPane> createState() => _PlWindowPaneState();
}

class _PlWindowPaneState extends State<PlWindowPane> {
  Offset _dragged = Offset.zero;

  /// The size a drag has left the window at, over whatever it was told to be.
  Size? _sized;

  /// What the window measured at the moment the current gesture started.
  ///
  /// A window with no `width` is as wide as what is in it, and there is no
  /// number in that to add a delta to — so the gesture asks the render box how
  /// big the window actually came out and works from there.
  Size? _gripped;

  /// Where `_dragged` stood then, and how far the pointer has come since.
  ///
  /// The travel is accumulated rather than applied a delta at a time, so an
  /// edge dragged past its floor and back picks the window up where it was left
  /// instead of somewhere the pointer has already been.
  Offset _grippedAt = Offset.zero;
  Offset _travel = Offset.zero;

  /// The window itself, so a gesture can measure it.
  final GlobalKey _paneKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (!widget.open) {
      return const SizedBox.shrink();
    }

    final tokens = PlassTheme.of(context);
    final labels = PlassTheme.labelsOf(context);
    final PlassSize step = widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final PlassColor family = widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;

    final PlWindowChrome chrome = windowChrome(widget.os);
    final PlWindowMetrics metrics = windowMetrics(widget.os, step);
    final _WindowColors paint = _colors(chrome, tokens, family);

    final List<PlWindowControl> order = orderControls(widget.os, widget.controls);
    final Offset at = widget.offset + _dragged;

    final Widget bar = _bar(
      chrome: chrome,
      metrics: metrics,
      colors: paint,
      order: order,
      labels: labels,
      tokens: tokens,
    );

    final Widget body = Container(
      margin: EdgeInsets.fromLTRB(metrics.band.side, 0, metrics.band.side, metrics.band.bottom),
      color: paint.body,
      child: widget.child ?? const SizedBox.shrink(),
    );

    final Widget pane = Container(
      key: _paneKey,
      width: _sized?.width ?? widget.width,
      // A rolled-up window is as tall as its title bar, whatever a drag left it
      // at — the height belongs to the body, and the body has gone.
      height: widget.minimized ? widget.height : (_sized?.height ?? widget.height),
      decoration: BoxDecoration(
        color: paint.band,
        border: Border.all(color: paint.line, width: metrics.frame),
        borderRadius: widget.maximized
            ? BorderRadius.zero
            : BorderRadius.vertical(
                top: Radius.circular(metrics.radius),
                bottom: Radius.circular(metrics.radiusBottom),
              ),
        boxShadow: tokens.elevation(
          widget.active ? widget.elevation : math.max(0, widget.elevation - 1),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          bar,
          // Rolled up rather than sent anywhere: a page has nowhere to send a
          // window to, so the bar stays where it is with nothing under it.
          if (!widget.minimized)
            if (widget.height == null) Flexible(child: body) else Expanded(child: body),
        ],
      ),
    );

    // No edge to pull on while the window fills what is holding it, and nothing
    // under the bar to make taller while it is rolled up.
    Widget framed = pane;

    if (widget.resizable && !widget.maximized && !widget.minimized) {
      final Color ring = tokens.family(family).ring;
      final String name = widget.resizeLabel ?? labels.resizeWindow;

      framed = Stack(
        children: <Widget>[
          pane,
          for (final _WindowEdge edge in _WindowEdge.values)
            edge.place(
              _ResizeHandle(
                edge: edge,
                onStart: _gripWindow,
                onUpdate: (Offset delta) => _resize(edge, delta, metrics.bar),
                // One of the eight is reachable without a pointer, and it is the
                // corner that changes both axes at once: eight stops around
                // every window would cost a keyboard reader more than the seven
                // extra directions are worth.
                ring: edge == _WindowEdge.se ? ring : null,
                label: edge == _WindowEdge.se ? name : null,
                onNudge: edge == _WindowEdge.se ? (Offset step) => _nudge(step, metrics.bar) : null,
              ),
            ),
        ],
      );
    }

    // `explicitChildNodes` is what makes the window a *named container* rather
    // than one long label: without it the title, the buttons and every word of
    // the content merge into the node's own name, and a window called `Notes`
    // is announced as `Notes Minimize Maximize Close Body`. It is the Flutter
    // half of what `aria-labelledby` does in the React build.
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: _titleText(),
      child: Transform.translate(offset: at, child: framed),
    );
  }

  /// Everything a resize needs to know, measured at the moment it starts.
  ///
  /// A window that cannot be measured gives up the grip rather than keeping the
  /// last one: the moves that follow accumulate against whatever the grip says,
  /// and a stale one would resize the window from a size it no longer has.
  void _gripWindow() {
    final RenderObject? box = _paneKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) {
      _gripped = null;
      return;
    }

    _gripped = box.size;
    _grippedAt = _dragged;
    _travel = Offset.zero;
  }

  void _resize(_WindowEdge edge, Offset delta, double bar) {
    final Size? from = _gripped;
    if (from == null) {
      return;
    }

    _travel += delta;

    final double floorWidth = math.max(0, widget.minWidth);
    final double floorHeight = math.max(bar, widget.minHeight ?? bar);

    double width = from.width;
    double height = from.height;
    Offset moved = _grippedAt;

    if (edge.east) {
      width = math.max(floorWidth, from.width + _travel.dx);
    }
    if (edge.south) {
      height = math.max(floorHeight, from.height + _travel.dy);
    }

    // Dragging a leading edge moves the window as it resizes it, and the
    // *clamped* width is what decides how far: at the minimum the edge stops and
    // the window has to stop with it, or a window held at its floor would go on
    // sliding out from under the pointer.
    if (edge.west) {
      width = math.max(floorWidth, from.width - _travel.dx);
      moved = Offset(_grippedAt.dx + (from.width - width), moved.dy);
    }
    if (edge.north) {
      height = math.max(floorHeight, from.height - _travel.dy);
      moved = Offset(moved.dx, _grippedAt.dy + (from.height - height));
    }

    _resizeTo(Size(width, height));

    if (edge.west || edge.north) {
      setState(() => _dragged = moved);
      widget.onOffsetChanged?.call(widget.offset + _dragged);
    }
  }

  /// One arrow key on the reachable corner.
  ///
  /// It reads the window rather than a grip, because a key press is a whole
  /// gesture on its own: there is no press to have measured anything at.
  void _nudge(Offset step, double bar) {
    final RenderObject? box = _paneKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) {
      return;
    }

    _resizeTo(
      Size(
        math.max(math.max(0, widget.minWidth), box.size.width + step.dx),
        math.max(math.max(bar, widget.minHeight ?? bar), box.size.height + step.dy),
      ),
    );
  }

  void _resizeTo(Size size) {
    setState(() => _sized = size);
    widget.onResize?.call(size);
  }

  /// The window's own name, for the semantics node.
  ///
  /// Read off a `Text` title where there is one. A caller who put something
  /// else in the bar has said what it looks like and not what it is called, and
  /// guessing would be worse than saying nothing.
  String? _titleText() {
    final Widget? title = widget.title;

    return title is Text ? title.data : null;
  }

  Widget _bar({
    required PlWindowChrome chrome,
    required PlWindowMetrics metrics,
    required _WindowColors colors,
    required List<PlWindowControl> order,
    required PlassLabels labels,
    required PlassTokens tokens,
  }) {
    final Widget buttons = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < order.length; i += 1) ...<Widget>[
          if (i > 0) SizedBox(width: metrics.gap),
          _WindowButton(
            control: order[i],
            chrome: chrome,
            metrics: metrics,
            colors: colors,
            maximized: widget.maximized,
            label: _labelFor(order[i], labels),
            onPressed: () => _press(order[i]),
          ),
        ],
      ],
    );

    final Widget name = DefaultTextStyle.merge(
      style: TextStyle(
        fontSize: metrics.title,
        fontWeight: metrics.weight,
        color: colors.barFg,
        shadows: chrome.shadow,
      ),
      overflow: TextOverflow.ellipsis,
      child: widget.title ?? const SizedBox.shrink(),
    );

    final Widget leading = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.icon != null) ...<Widget>[widget.icon!, const SizedBox(width: 8)],
        if (chrome.titleAlign == PlWindowTitleAlign.start) Flexible(child: name),
      ],
    );

    final Widget row = Row(
      children: <Widget>[
        if (!chrome.controlsAtEnd) buttons,
        if (!chrome.controlsAtEnd) SizedBox(width: metrics.padX),
        Expanded(child: leading),
        if (widget.actions != null) widget.actions!,
        if (chrome.controlsAtEnd) buttons,
      ],
    );

    final Widget bar = Container(
      height: metrics.bar,
      padding: EdgeInsetsDirectional.only(
        start: metrics.padX,
        end: chrome.controlsAtEnd ? metrics.padEnd : metrics.padX,
      ),
      decoration: BoxDecoration(
        color: colors.bar,
        gradient: chrome.image,
        border: chrome.rule ? Border(bottom: BorderSide(color: colors.line)) : null,
      ),
      child: chrome.titleAlign == PlWindowTitleAlign.center
          ? Stack(
              children: <Widget>[
                // Centred over the whole window rather than over what is left
                // of it, which is where macOS and GNOME both put it.
                Center(child: name),
                Positioned.fill(child: row),
              ],
            )
          : row,
    );

    if (!widget.draggable) {
      return bar;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.move,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (DragUpdateDetails details) {
          setState(() => _dragged += details.delta);
          widget.onOffsetChanged?.call(widget.offset + _dragged);
        },
        child: bar,
      ),
    );
  }

  String _labelFor(PlWindowControl control, PlassLabels labels) {
    switch (control) {
      case PlWindowControl.minimize:
        return widget.minimizeLabel ?? labels.minimize;
      case PlWindowControl.maximize:
        return widget.maximized
            ? (widget.restoreLabel ?? labels.restore)
            : (widget.maximizeLabel ?? labels.maximize);
      case PlWindowControl.close:
        return widget.closeLabel ?? labels.close;
    }
  }

  void _press(PlWindowControl control) {
    switch (control) {
      case PlWindowControl.minimize:
        widget.onMinimizedChanged?.call(!widget.minimized);
      case PlWindowControl.maximize:
        widget.onMaximizedChanged?.call(!widget.maximized);
      case PlWindowControl.close:
        widget.onOpenChanged?.call(false);
    }
  }

  /// Everything the window is painted with.
  ///
  /// Computed rather than tabled because three of the props they answer to —
  /// `accent`, `transparency` and whether the window is in front — are
  /// continuous or combinatorial.
  _WindowColors _colors(PlWindowChrome chrome, PlassTokens tokens, PlassColor family) {
    final double veiled = widget.transparency.clamp(0.0, 1.0);
    Color veil(Color color) => color.withValues(alpha: color.a * (1 - veiled));

    final int tint = chrome.tint[widget.active ? 0 : 1];
    final Color plain = tint == 0
        ? tokens.surface
        : Color.lerp(tokens.surface, tokens.fg, tint / 100)!;

    // A window behind the one in front keeps its shape and loses its emphasis —
    // its colour drains, its shadow drops a step and its title greys. Never
    // opacity, which would take the content down with the chrome.
    final bool dyed = widget.accent && widget.active;
    final PlWindowPaint? own = chrome.paint;
    // A painted bar that is not in front washes out rather than greys: that is
    // what XP did to Luna blue and what Aqua did to its stripes.
    final Color? painted = own == null
        ? null
        : (widget.active ? own.fill : Color.lerp(own.fill, const Color(0xFFC6C9CE), 0.55)!);

    final PlassColorFamily palette = tokens.family(family);
    final Color bar = dyed ? palette.solid : (painted ?? plain);
    final Color barFg = dyed
        ? palette.onSolid
        : own != null
        ? (widget.active ? own.ink : own.ink.withValues(alpha: 0.6))
        : (widget.active ? tokens.fg : tokens.mutedFg);

    final bool banded = chrome.band.side > 0;
    // The band is the same material as the caption: XP's blue frame is the blue
    // of its title bar, and Aero's is the first of the two layers of glass.
    final Color band = banded
        ? veil(dyed ? palette.solid : (painted ?? plain))
        : const Color(0x00000000);
    final Color line = banded
        // A banded window is outlined in a darker cut of its own band rather
        // than in the page's border colour, which would be a grey line drawn
        // around a blue window.
        ? Color.lerp(
            dyed ? palette.solid : (painted ?? tokens.border),
            const Color(0xFF000000),
            0.28,
          )!
        : dyed && chrome.accentBorder
        ? palette.solid
        : (widget.active ? tokens.border : tokens.border.withValues(alpha: 0.55));

    // Which way a control has to lighten when the pointer arrives is a property
    // of what it is sitting on, not of the page.
    final bool onDark = dyed || (own?.dark ?? false);

    return _WindowColors(
      bar: veil(bar),
      barFg: barFg,
      body: veil(tokens.surface),
      band: band,
      line: line,
      // Fixed rather than derived from the ink: the close button turns its own
      // ink white on hover, and a fill mixed out of that ink would turn white
      // with it — a close button that disappears at the moment it is aimed at.
      hover: onDark ? const Color(0x2EFFFFFF) : tokens.fg.withValues(alpha: 0.09),
      accent: palette.accent,
    );
  }
}

/// The colours one window is drawn with.
class _WindowColors {
  const _WindowColors({
    required this.bar,
    required this.barFg,
    required this.body,
    required this.band,
    required this.line,
    required this.hover,
    required this.accent,
  });

  final Color bar;
  final Color barFg;
  final Color body;
  final Color band;
  final Color line;
  final Color hover;
  final Color accent;
}

/// One caption button.
class _WindowButton extends StatefulWidget {
  const _WindowButton({
    required this.control,
    required this.chrome,
    required this.metrics,
    required this.colors,
    required this.maximized,
    required this.label,
    required this.onPressed,
  });

  final PlWindowControl control;
  final PlWindowChrome chrome;
  final PlWindowMetrics metrics;
  final _WindowColors colors;
  final bool maximized;
  final String label;
  final VoidCallback onPressed;

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _over = false;

  @override
  Widget build(BuildContext context) {
    final PlWindowChrome chrome = widget.chrome;
    final PlWindowMetrics metrics = widget.metrics;
    final bool closing = widget.control == PlWindowControl.close;
    final double width = closing ? metrics.closeWidth : metrics.control.width;

    final Color? danger = closing
        ? closeHover[chrome.shape == PlWindowControlShape.dot
              ? PlWindowOs.macos
              : PlWindowOs.windows11]
        : null;

    Color fill = const Color(0x00000000);
    Color ink = widget.colors.barFg;
    BorderRadius radius = BorderRadius.zero;
    Border? edge;

    switch (chrome.shape) {
      case PlWindowControlShape.dot:
      case PlWindowControlShape.glossDot:
        fill = trafficColors[widget.control]!;
        // A window behind the front one has grey lights, which is the whole of
        // how macOS says which window is which.
        ink = const Color(0x99000000);
        radius = BorderRadius.circular(width);
      case PlWindowControlShape.plate:
        fill = plateColors[widget.control]!;
        ink = const Color(0xFFFFFFFF);
        radius = BorderRadius.circular(3);
      case PlWindowControlShape.aero:
        fill = _over
            ? (closing ? const Color(0xFFE04343) : const Color(0x66FFFFFF))
            : const Color(0x33FFFFFF);
        ink = closing && _over ? const Color(0xFFFFFFFF) : widget.colors.barFg;
        radius = const BorderRadius.vertical(bottom: Radius.circular(4));
        edge = Border.all(color: const Color(0x40FFFFFF));
      case PlWindowControlShape.circle:
        fill = _over ? widget.colors.hover : widget.colors.hover.withValues(alpha: 0.5);
        radius = BorderRadius.circular(width);
      case PlWindowControlShape.square:
        if (_over) {
          fill = closing ? (danger ?? widget.colors.hover) : widget.colors.hover;
          ink = closing ? const Color(0xFFFFFFFF) : widget.colors.barFg;
        }
    }

    // A traffic light shows its mark only under the pointer, which is what
    // makes three coloured dots read as three dots rather than as three icons.
    final bool showGlyph = switch (chrome.shape) {
      PlWindowControlShape.dot || PlWindowControlShape.glossDot => _over,
      _ => true,
    };

    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (PointerEnterEvent _) => setState(() => _over = true),
        onExit: (PointerExitEvent _) => setState(() => _over = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: width,
            height: metrics.control.height,
            decoration: BoxDecoration(color: fill, borderRadius: radius, border: edge),
            alignment: Alignment.center,
            child: showGlyph
                ? CustomPaint(
                    size: Size.square(metrics.glyph),
                    painter: PlWindowGlyphPainter(
                      control: widget.control,
                      maximized: widget.maximized,
                      chrome: chrome,
                      ink: ink,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

/// How far one arrow key press moves the corner. The same step `PlPanes` uses.
const double _keyboardStep = 16;

/// How thick an edge handle is, how large a corner one is, and how far along an
/// edge the corners leave for it.
///
/// A one-pixel line is a one-pixel target, which is not a target, so what can be
/// grabbed is a strip several pixels across just inside the frame.
const double _handleThickness = 6;
const double _handleCorner = 12;

/// Which edge or corner of a window a handle sits on.
///
/// Physical rather than logical, and deliberately: the resize cursor is the one
/// the platform draws, the geometry underneath is left and top, and a window is
/// an object on a surface rather than a run of text. Everything the *chrome*
/// does — which end the controls are on, which side the title starts from —
/// stays logical and mirrors under RTL.
enum _WindowEdge {
  n(north: true),
  s(south: true),
  w(west: true),
  e(east: true),
  nw(north: true, west: true),
  ne(north: true, east: true),
  sw(south: true, west: true),
  se(south: true, east: true);

  const _WindowEdge({this.north = false, this.south = false, this.west = false, this.east = false});

  final bool north;
  final bool south;
  final bool west;
  final bool east;

  /// What the pointer turns into over the handle.
  MouseCursor get cursor {
    if (!north && !south) {
      return SystemMouseCursors.resizeLeftRight;
    }
    if (!west && !east) {
      return SystemMouseCursors.resizeUpDown;
    }

    return north == west
        ? SystemMouseCursors.resizeUpLeftDownRight
        : SystemMouseCursors.resizeUpRightDownLeft;
  }

  /// Where it sits on the window.
  Positioned place(Widget child) {
    switch (this) {
      case _WindowEdge.n:
        return Positioned(
          left: _handleCorner,
          right: _handleCorner,
          top: 0,
          height: _handleThickness,
          child: child,
        );
      case _WindowEdge.s:
        return Positioned(
          left: _handleCorner,
          right: _handleCorner,
          bottom: 0,
          height: _handleThickness,
          child: child,
        );
      case _WindowEdge.w:
        return Positioned(
          top: _handleCorner,
          bottom: _handleCorner,
          left: 0,
          width: _handleThickness,
          child: child,
        );
      case _WindowEdge.e:
        return Positioned(
          top: _handleCorner,
          bottom: _handleCorner,
          right: 0,
          width: _handleThickness,
          child: child,
        );
      case _WindowEdge.nw:
        return Positioned(
          top: 0,
          left: 0,
          width: _handleCorner,
          height: _handleCorner,
          child: child,
        );
      case _WindowEdge.ne:
        return Positioned(
          top: 0,
          right: 0,
          width: _handleCorner,
          height: _handleCorner,
          child: child,
        );
      case _WindowEdge.sw:
        return Positioned(
          bottom: 0,
          left: 0,
          width: _handleCorner,
          height: _handleCorner,
          child: child,
        );
      case _WindowEdge.se:
        return Positioned(
          bottom: 0,
          right: 0,
          width: _handleCorner,
          height: _handleCorner,
          child: child,
        );
    }
  }
}

/// One arrow key press on the reachable corner.
class _NudgeWindowIntent extends Intent {
  const _NudgeWindowIntent(this.step);

  final Offset step;
}

/// One of the eight places a window can be taken hold of.
///
/// It draws nothing. A resize handle is a target rather than a mark: the frame
/// is already the line the pointer is aiming at, and a second one just inside it
/// would be a border the window does not have.
class _ResizeHandle extends StatefulWidget {
  const _ResizeHandle({
    required this.edge,
    required this.onStart,
    required this.onUpdate,
    this.ring,
    this.label,
    this.onNudge,
  });

  /// Which edge or corner this is, which decides both the cursor and the sums.
  final _WindowEdge edge;

  /// A gesture is starting, and the window measures itself.
  final VoidCallback onStart;

  /// How far the pointer moved since the last update.
  final ValueChanged<Offset> onUpdate;

  /// The focus ring's colour, on the one handle that can take the focus.
  final Color? ring;

  /// And what that handle is called.
  final String? label;

  /// And what an arrow key on it does. Its absence is what makes the other
  /// seven handles pointer-only.
  final ValueChanged<Offset>? onNudge;

  @override
  State<_ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<_ResizeHandle> {
  bool _focusVisible = false;

  @override
  Widget build(BuildContext context) {
    final ValueChanged<Offset>? onNudge = widget.onNudge;

    Widget target = const SizedBox.expand();

    if (_focusVisible && widget.ring != null) {
      target = CustomPaint(
        foregroundPainter: PlassFocusRingPainter(
          color: widget.ring!,
          borderRadius: BorderRadius.zero,
          offset: -focusRingWidth,
        ),
        child: target,
      );
    }

    Widget handle = MouseRegion(
      cursor: widget.edge.cursor,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onPanStart: (DragStartDetails details) => widget.onStart(),
        onPanUpdate: (DragUpdateDetails details) => widget.onUpdate(details.delta),
        child: target,
      ),
    );

    if (onNudge == null) {
      return ExcludeSemantics(child: handle);
    }

    handle = FocusableActionDetector(
      includeFocusSemantics: false,
      onShowFocusHighlight: (bool value) {
        if (_focusVisible != value) {
          setState(() => _focusVisible = value);
        }
      },
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowRight): _NudgeWindowIntent(
          Offset(_keyboardStep, 0),
        ),
        SingleActivator(LogicalKeyboardKey.arrowLeft): _NudgeWindowIntent(
          Offset(-_keyboardStep, 0),
        ),
        SingleActivator(LogicalKeyboardKey.arrowDown): _NudgeWindowIntent(Offset(0, _keyboardStep)),
        SingleActivator(LogicalKeyboardKey.arrowUp): _NudgeWindowIntent(Offset(0, -_keyboardStep)),
      },
      actions: <Type, Action<Intent>>{
        _NudgeWindowIntent: CallbackAction<_NudgeWindowIntent>(
          onInvoke: (_NudgeWindowIntent intent) {
            onNudge(intent.step);
            return null;
          },
        ),
      },
      child: handle,
    );

    return Semantics(
      button: true,
      label: widget.label,
      child: ExcludeSemantics(child: handle),
    );
  }
}
