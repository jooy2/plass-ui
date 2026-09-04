/// A column beside the content, and a drawer once the screen is too narrow.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/drawer/pl_drawer.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/page_layout.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

export 'package:plass_ui/src/internal/page_layout.dart' show PlassSidebarSide;

/// The default width.
///
/// `md` is 256, which is what a navigation rail has been since sidebars had
/// names: wide enough for two words and an icon, narrow enough that the article
/// beside it still holds a readable measure on a laptop.
const Map<PlassSize, double> _widths = <PlassSize, double>{
  PlassSize.xs: 176,
  PlassSize.sm: 208,
  PlassSize.md: 256,
  PlassSize.lg: 288,
  PlassSize.xl: 336,
};

/// How far one arrow key press moves the edge. The same step [PlPanes] uses.
const double _keyboardStep = 16;

/// How wide the grabbable track around the hairline is.
const double _handleTrack = 8;

/// One arrow key press on the resize handle.
class _NudgeIntent extends Intent {
  const _NudgeIntent(this.steps);

  final int steps;
}

/// A column beside the screen's content, and a drawer once the screen is too
/// narrow to hold one.
///
/// ```dart
/// PlPageLayout(
///   sidebar: PlSidebar(semanticLabel: 'Main navigation', child: navigation),
///   child: page,
/// )
/// ```
///
/// Two presentations of one panel, exactly as [PlDrawer] is: above the collapse
/// width it is a column in the layout that the content is laid out around, and
/// below it the same child is a drawer over a scrim with a focus trap, an
/// Escape and a way back to the trigger. They are one widget because they are
/// one thing — a caller should not have to swap widgets at a breakpoint — and
/// because the child is then built once either way rather than twice for a
/// screen reader to read twice.
///
/// It claims [SemanticsRole.complementary]: the region a screen reader offers
/// as related to the screen but not the screen.
class PlSidebar extends StatefulWidget {
  /// Creates a sidebar.
  const PlSidebar({
    this.child,
    this.side,
    this.width,
    this.minWidth = 160,
    this.maxWidth = 480,
    this.resizable = false,
    this.onResize,
    this.onResizeEnd,
    this.collapseBelow,
    this.open,
    this.onOpenChanged,
    this.title,
    this.divider = true,
    this.padded = true,
    this.variant = PlassVariant.glass,
    this.size,
    this.color,
    this.density,
    this.elevation = 0,
    this.semanticLabel,
    this.closeLabel,
    this.resizeLabel,
    super.key,
  }) : assert(minWidth <= maxWidth, 'minWidth must not be wider than maxWidth'),
       assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// Everything in it: navigation, a filter panel, a table of contents.
  final Widget? child;

  /// Which end of the band it takes. Logical, so it flips under RTL.
  ///
  /// Inside a [PlPageLayout] this is already decided by which slot the sidebar
  /// was handed to, and setting it again is only a way of disagreeing with the
  /// layout.
  final PlassSidebarSide? side;

  /// How wide the column is. Left out, it is the width [size] implies.
  ///
  /// With [resizable] it is only the width the sidebar *starts* at: dragging
  /// writes over it, and the caller hears about it through [onResize].
  final double? width;

  /// How narrow it may be dragged.
  final double minWidth;

  /// And how wide.
  final double maxWidth;

  /// Lets the reader drag the inner edge to change the column's width.
  ///
  /// Off by default. A sidebar that can be resized is a sidebar whose width is
  /// the reader's to remember, which means a caller who turns this on usually
  /// also wants to store what [onResizeEnd] reports.
  final bool resizable;

  /// Called with the width while the edge is being dragged.
  final ValueChanged<double>? onResize;

  /// Called once, with the same number, when it is let go.
  final ValueChanged<double>? onResizeEnd;

  /// The width below which the column becomes a drawer, measured against the
  /// window.
  ///
  /// Left out, the [PlPageLayout] above decides — which is the better answer
  /// when there is one, because the layout measures the space *it* was given
  /// rather than the window. Outside a layout, `null` keeps the sidebar a
  /// column at every width: one that collapsed with nothing on screen able to
  /// bring it back would be a sidebar the reader has lost.
  final PlassBreakpoint? collapseBelow;

  /// Whether the drawer is open. Only meaningful once the sidebar has
  /// collapsed; a column is not opened, it is there.
  ///
  /// Inside a [PlPageLayout] the layout owns this — it is what a
  /// [PlSidebarTrigger] anywhere on the screen talks to — so control it there
  /// rather than here. [onOpenChanged] still fires either way.
  final bool? open;

  /// Called when the drawer opens or closes.
  final ValueChanged<bool>? onOpenChanged;

  /// The heading, drawn only while the sidebar is a drawer.
  ///
  /// A column has the screen around it to say what it is; a panel that has
  /// covered the screen does not — so left out, [semanticLabel] is drawn as the
  /// heading instead. That is one thing this build does that the React one does
  /// not, and the reason is that a `PlDrawer` is named by what it draws.
  final Widget? title;

  /// Draws a hairline down the inner edge — the one facing the content. The
  /// outer edge is against the screen, where there is nothing on the other side
  /// to be separated from.
  final bool divider;

  /// The gutter and the air above and below the content.
  final bool padded;

  /// What the panel is made of. Never dyed — what is on it arrives with colours
  /// of its own.
  final PlassVariant variant;

  /// The panel's default width and the air around its content.
  final PlassSize? size;

  /// Semantic colour role. It reaches the focus ring on the handle and the
  /// rings inside, and nothing else.
  final PlassColor? color;

  /// Changes the padding and nothing else.
  final PlassDensity? density;

  /// Drop shadow depth, `0`–`3`. `0` and flat.
  final PlassElevation elevation;

  /// The name the region is announced by.
  ///
  /// Named by default, because a screen with two unnamed sidebars is a screen
  /// offering two regions called "complementary" — which Flutter refuses
  /// outright.
  final String? semanticLabel;

  /// What the drawer's close button says, once the sidebar has collapsed.
  final String? closeLabel;

  /// What the drag handle is announced as.
  final String? resizeLabel;

  @override
  State<PlSidebar> createState() => _PlSidebarState();
}

class _PlSidebarState extends State<PlSidebar> {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

  /// The dragged width, held in a notifier rather than in `setState`.
  ///
  /// Nothing in the panel depends on the number except one `SizedBox`, and a
  /// `setState` per pointer move would rebuild every row in the sidebar to
  /// change it. This is the Dart shape of the same decision the React build
  /// makes by writing the width straight onto the element.
  late final ValueNotifier<double> _width = ValueNotifier<double>(_initialWidth);

  bool _ownOpen = false;
  bool _sized = false;

  double get _initialWidth => widget.width ?? _widths[_size]!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // The first place with a context that is safe to resolve a theme default
    // in. `_width` is `late final` and reads `_size` to initialise, so leaving
    // it to be touched first by `dispose` — which is what happens to a sidebar
    // nobody ever dragged — would mean an inherited lookup on a deactivated
    // element. That is an error rather than a warning.
    if (!_sized) {
      _sized = true;
      _width.value = _clamp(_initialWidth);
    }
  }

  @override
  void didUpdateWidget(PlSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.width != oldWidget.width || _size != oldWidget.size) {
      _width.value = _clamp(_initialWidth);
    }
  }

  @override
  void dispose() {
    _width.dispose();
    super.dispose();
  }

  double _clamp(double value) => value.clamp(widget.minWidth, widget.maxWidth);

  void _resize(double next, {required bool settled}) {
    final double sized = _clamp(next);
    _width.value = sized;
    widget.onResize?.call(sized);

    if (settled) {
      widget.onResizeEnd?.call(sized);
    }
  }

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);
    final PlassPageLayoutScope? layout = PlassPageLayoutScope.maybeOf(context);
    final PlassSidebarSide side =
        widget.side ?? PlassSidebarSideScope.maybeOf(context) ?? PlassSidebarSide.start;
    final TextDirection direction = Directionality.of(context);

    final bool collapsed = widget.collapseBelow != null
        ? MediaQuery.sizeOf(context).width < widget.collapseBelow!.width
        : layout?.collapsed ?? false;

    final bool open = widget.open ?? layout?.open[side] ?? _ownOpen;

    void changeOpen(bool next) {
      if (widget.open == null) {
        if (layout != null) {
          layout.setOpen(side, next);
        } else {
          setState(() => _ownOpen = next);
        }
      }

      widget.onOpenChanged?.call(next);
    }

    if (collapsed) {
      return PlDrawer(
        open: open,
        onOpenChanged: changeOpen,
        side: drawerSide(side, direction),
        // A panel that has covered the screen is named by what it draws, so the
        // region's name becomes its heading when nobody gave it one.
        title: widget.title ?? Text(widget.semanticLabel ?? PlassTheme.labelsOf(context).sidebar),
        closeLabel: widget.closeLabel ?? PlassTheme.labelsOf(context).sidebarClose,
        // An explicit width is the caller's decision and survives the change of
        // shape; the default one does not, because a column sized against the
        // article beside it and a panel sized against a phone are two different
        // numbers, and the drawer's own ladder already knows the second.
        extent: widget.width,
        size: _size,
        color: _color,
        density: _density,
        child: widget.child,
      );
    }

    Widget panel = Padding(
      padding: widget.padded
          ? EdgeInsets.symmetric(
              horizontal: sheetPaddingX[_density]![_size]!,
              vertical: sheetPaddingY[_density]![_size]!,
            )
          : EdgeInsets.zero,
      child: widget.child ?? const SizedBox.shrink(),
    );

    // The column scrolls on its own: a navigation list longer than the screen
    // has to be reachable without the screen beside it moving.
    panel = SingleChildScrollView(child: panel);

    if (widget.divider) {
      final BorderSide rule = BorderSide(color: tokens.divider, width: hairline);

      panel = DecoratedBox(
        decoration: BoxDecoration(
          // The rule goes on the edge that faces the page, which is the far
          // edge of whichever side the panel is on.
          border: side == PlassSidebarSide.start
              ? BorderDirectional(end: rule)
              : BorderDirectional(start: rule),
        ),
        child: panel,
      );
    }

    panel = PlassSurfaceBox(
      surface: sheetSurface(tokens, variant: widget.variant, elevation: widget.elevation),
      borderRadius: BorderRadius.zero,
      duration: PlassTokens.durationSlow,
      child: panel,
    );

    if (widget.resizable) {
      panel = Stack(
        children: <Widget>[
          Positioned.fill(child: panel),
          PositionedDirectional(
            top: 0,
            bottom: 0,
            // Straddling the inner edge rather than sitting inside it: a
            // hairline one logical pixel wide is a target one pixel wide, which
            // is not a target.
            start: side == PlassSidebarSide.start ? null : -_handleTrack / 2,
            end: side == PlassSidebarSide.start ? -_handleTrack / 2 : null,
            width: _handleTrack,
            child: _ResizeHandle(
              family: tokens.family(_color),
              label: widget.resizeLabel ?? PlassTheme.labelsOf(context).sidebarResize,
              outwards: side == PlassSidebarSide.start ? 1 : -1,
              width: _width,
              min: widget.minWidth,
              max: widget.maxWidth,
              onDrag: (double delta) => _resize(_width.value + delta, settled: false),
              onSettle: () => widget.onResizeEnd?.call(_width.value),
              // A key press is a whole gesture on its own — there is no "let
              // go" to wait for, so the settled callback fires with it.
              onNudge: (int steps) => _resize(_width.value + steps * _keyboardStep, settled: true),
            ),
          ),
        ],
      );
    }

    return Semantics(
      role: SemanticsRole.complementary,
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel ?? PlassTheme.labelsOf(context).sidebar,
      child: ValueListenableBuilder<double>(
        valueListenable: _width,
        builder: (BuildContext context, double width, Widget? child) =>
            SizedBox(width: width, child: child),
        child: panel,
      ),
    );
  }
}

/// The track around the sidebar's inner edge.
///
/// Its own widget rather than [PlPanes]' handle: that one is described in
/// **percentage shares** of a split and reports its value as one, and a
/// sidebar's width is a number of pixels with a floor and a ceiling. Two
/// different values with two different announcements; what they share is the
/// shape, which is written the same way in both.
class _ResizeHandle extends StatefulWidget {
  const _ResizeHandle({
    required this.family,
    required this.label,
    required this.outwards,
    required this.width,
    required this.min,
    required this.max,
    required this.onDrag,
    required this.onSettle,
    required this.onNudge,
  });

  final PlassColorFamily family;
  final String label;

  /// `1` when dragging toward the end of the axis makes the column wider.
  final int outwards;

  final ValueListenable<double> width;
  final double min;
  final double max;
  final ValueChanged<double> onDrag;
  final VoidCallback onSettle;
  final ValueChanged<int> onNudge;

  @override
  State<_ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<_ResizeHandle> {
  bool _hovered = false;
  bool _dragging = false;
  bool _focusVisible = false;

  @override
  Widget build(BuildContext context) {
    final bool lit = _hovered || _dragging || _focusVisible;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;

    Widget mark = AnimatedContainer(
      duration: PlassTokens.duration,
      curve: PlassTokens.ease,
      color: lit ? widget.family.soft : null,
    );

    if (_focusVisible) {
      mark = CustomPaint(
        foregroundPainter: PlassFocusRingPainter(
          color: widget.family.ring,
          borderRadius: BorderRadius.zero,
          offset: -focusRingWidth,
        ),
        child: mark,
      );
    }

    Widget handle = MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (PointerEnterEvent event) => setState(() => _hovered = true),
      onExit: (PointerExitEvent event) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onHorizontalDragStart: (DragStartDetails details) => setState(() => _dragging = true),
        // Positive is always "wider", so a drag under RTL — where the leading
        // edge is on the right — moves the edge the way the pointer went rather
        // than the way the axis is numbered.
        onHorizontalDragUpdate: (DragUpdateDetails details) =>
            widget.onDrag((rtl ? -details.delta.dx : details.delta.dx) * widget.outwards),
        onHorizontalDragEnd: (DragEndDetails details) {
          setState(() => _dragging = false);
          widget.onSettle();
        },
        child: mark,
      ),
    );

    handle = FocusableActionDetector(
      includeFocusSemantics: false,
      onShowFocusHighlight: (bool value) {
        if (_focusVisible != value) {
          setState(() => _focusVisible = value);
        }
      },
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowRight): _NudgeIntent(1),
        SingleActivator(LogicalKeyboardKey.arrowLeft): _NudgeIntent(-1),
      },
      actions: <Type, Action<Intent>>{
        _NudgeIntent: CallbackAction<_NudgeIntent>(
          onInvoke: (_NudgeIntent intent) {
            widget.onNudge((rtl ? -intent.steps : intent.steps) * widget.outwards);
            return null;
          },
        ),
      },
      child: handle,
    );

    // Flutter's semantics tree has no `separator` role and no `valuenow`, so a
    // handle is what it actually is to a screen reader: a control with a value
    // that can be turned up and down.
    return ValueListenableBuilder<double>(
      valueListenable: widget.width,
      builder: (BuildContext context, double width, Widget? child) => Semantics(
        slider: true,
        label: widget.label,
        value: '${width.round()}',
        increasedValue: '${(width + _keyboardStep).clamp(widget.min, widget.max).round()}',
        decreasedValue: '${(width - _keyboardStep).clamp(widget.min, widget.max).round()}',
        onIncrease: () => widget.onNudge(1),
        onDecrease: () => widget.onNudge(-1),
        child: child,
      ),
      child: ExcludeSemantics(child: handle),
    );
  }
}
