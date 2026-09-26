/// The skeleton a screen is hung on.
library;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/page_layout.dart';
import 'package:plass_ui/src/types.dart';

export 'package:plass_ui/src/internal/page_layout.dart' show PlPageLayoutSpan, PlassSidebarSide;

/// The skeleton a screen is hung on: a header, a footer, one sidebar or two,
/// and the content between them.
///
/// ```dart
/// PlPageLayout(
///   header: const PlHeader(brand: Text('Acme')),
///   sidebar: PlSidebar(child: navigation),
///   footer: const PlFooter(child: Text('© 2026 Acme')),
///   child: page,
/// )
/// ```
///
/// What it is really for is the **arrangement and the semantics**. A screen
/// assembled out of anonymous boxes is a screen a screen reader offers as one
/// undifferentiated region; the same screen built out of components that name
/// what they are is a screen with a table of contents. Those names come from
/// the components this one arranges — the layout itself draws no surface and
/// claims nothing except [SemanticsRole.main] around what it was given, and not
/// even that inside another layout, whose screen has its main region already.
///
/// It draws no gutter and no measure either. That is [PlContainer]'s job, and a
/// layout that also did it would be a second spelling of one idea — put a
/// container inside, where one route can hold a wide dashboard and the next a
/// narrow article.
///
/// **It fills the space it is given**, which is a [Column] of a header, an
/// [Expanded] band and a footer: put it under a [SizedBox.expand], a [Scaffold]
/// body or anything else with a bounded height. The content is not wrapped in a
/// scroll view — what scrolls, and in which direction, belongs to whatever is
/// put in [child].
class PlPageLayout extends StatefulWidget {
  /// Creates a screen skeleton.
  const PlPageLayout({
    this.child,
    this.header,
    this.footer,
    this.sidebar,
    this.endSidebar,
    this.headerSpan = PlPageLayoutSpan.full,
    this.footerSpan = PlPageLayoutSpan.full,
    this.collapseBelow = PlassBreakpoint.md,
    this.sidebarOpen,
    this.onSidebarOpenChanged,
    this.endSidebarOpen,
    this.onEndSidebarOpenChanged,
    this.mainSemanticLabel,
    super.key,
  });

  /// The screen. Given whatever the bars and the columns leave.
  final Widget? child;

  /// The bar across the top. A [PlHeader], usually.
  final Widget? header;

  /// The sheet at the end. A [PlFooter], usually.
  final Widget? footer;

  /// The leading column — the left of an English screen, the right of an Arabic
  /// one. A [PlSidebar] in here is told which end it is on and needs no `side`
  /// of its own.
  final Widget? sidebar;

  /// The trailing column, for the layouts that have two: navigation down one
  /// side and a table of contents, an inspector or a filter panel down the
  /// other. Each is a sidebar with its own width, its own drawer and its own
  /// trigger.
  final Widget? endSidebar;

  /// Which of the header and the sidebars takes the top corner.
  final PlPageLayoutSpan headerSpan;

  /// The same question for the footer, and it is worth answering separately: a
  /// dashboard with a full-height navigation rail still usually wants its
  /// copyright line under the content rather than under the rail.
  final PlPageLayoutSpan footerSpan;

  /// The width below which the sidebars stop being columns and become drawers,
  /// with a [PlSidebarTrigger] as the way to open them.
  ///
  /// `null` keeps them columns at every width. The comparison is against the
  /// space **this layout** was given rather than against the window, which is
  /// the one thing it can do better than the React build's media query: an app
  /// shell inside a pane collapses when the pane is narrow.
  final PlassBreakpoint? collapseBelow;

  /// Whether the leading sidebar's drawer is open.
  ///
  /// Passing it makes the drawer controlled: the layout stops holding the state
  /// and answers with what it is given, which is what a route change that has
  /// to close the drawer behind it needs.
  final bool? sidebarOpen;

  /// Called when the leading drawer opens or closes.
  final ValueChanged<bool>? onSidebarOpenChanged;

  /// The same two for the trailing sidebar.
  final bool? endSidebarOpen;

  /// See [endSidebarOpen].
  final ValueChanged<bool>? onEndSidebarOpenChanged;

  /// The name a screen reader gives the main region.
  ///
  /// Worth writing when a screen has more than one region worth naming. Left
  /// out, the region is announced by what is in it. A layout inside another
  /// claims no main region, so it gives this to nothing.
  final String? mainSemanticLabel;

  @override
  State<PlPageLayout> createState() => _PlPageLayoutState();
}

class _PlPageLayoutState extends State<PlPageLayout> {
  bool _ownStart = false;
  bool _ownEnd = false;

  bool get _startOpen => widget.sidebarOpen ?? _ownStart;

  bool get _endOpen => widget.endSidebarOpen ?? _ownEnd;

  void _setOpen(PlassSidebarSide side, bool open) {
    if (side == PlassSidebarSide.start) {
      if (widget.sidebarOpen == null) {
        setState(() => _ownStart = open);
      }
      widget.onSidebarOpenChanged?.call(open);
      return;
    }

    if (widget.endSidebarOpen == null) {
      setState(() => _ownEnd = open);
    }
    widget.onEndSidebarOpenChanged?.call(open);
  }

  @override
  Widget build(BuildContext context) {
    final Widget? header = widget.header;
    final Widget? footer = widget.footer;
    final Widget? sidebar = widget.sidebar;
    final Widget? endSidebar = widget.endSidebar;

    // Inside another layout this one is a region of that screen rather than a
    // screen, and the screen has its main region already: a second one is two
    // for a reader to choose between. So the role, and the name that goes with
    // it, are left to the outer layout. Looked up without depending on it,
    // because nothing the outer scope carries changes the answer.
    final bool nested = context.getInheritedWidgetOfExactType<PlassPageLayoutScope>() != null;

    Widget main = Semantics(
      role: nested ? null : SemanticsRole.main,
      label: nested ? null : widget.mainSemanticLabel,
      explicitChildNodes: true,
      child: widget.child ?? const SizedBox.shrink(),
    );

    // The middle column: the content, plus whichever bars belong to the view
    // rather than to the screen.
    main = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (header != null && widget.headerSpan == PlPageLayoutSpan.content) header,
        Expanded(child: main),
        if (footer != null && widget.footerSpan == PlPageLayoutSpan.content) footer,
      ],
    );

    final Widget band = _Band(
      children: <Widget>[
        if (sidebar != null) PlassSidebarSideScope(side: PlassSidebarSide.start, child: sidebar),
        Expanded(child: main),
        if (endSidebar != null)
          PlassSidebarSideScope(side: PlassSidebarSide.end, child: endSidebar),
      ],
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final PlassBreakpoint? floor = widget.collapseBelow;
        // A layout with no width to speak of yet — the frame before a pane is
        // measured — is not a narrow one, so an unbounded width is read as
        // wide. Collapsing on `infinity < 768` would open every drawer once.
        final bool collapsed =
            floor != null && constraints.maxWidth.isFinite && constraints.maxWidth < floor.width;

        return PlassPageLayoutScope(
          collapsed: collapsed,
          open: <PlassSidebarSide, bool>{
            PlassSidebarSide.start: _startOpen,
            PlassSidebarSide.end: _endOpen,
          },
          setOpen: _setOpen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (header != null && widget.headerSpan == PlPageLayoutSpan.full) header,
              Expanded(child: band),
              if (footer != null && widget.footerSpan == PlPageLayoutSpan.full) footer,
            ],
          ),
        );
      },
    );
  }
}

/// The band between the bars: the sidebars and the content, laid out, read and
/// tabbed through in that order as a [Row] would, but painted and asked about a
/// pointer with the sidebars above the content.
///
/// A sidebar's resize handle straddles its inner edge, so half of it lies over
/// the content, and over a header or a footer that spans only the content. A
/// [Row] paints its children in order and asks the last one about a pointer
/// first, which would put the content over a start sidebar's handle: a fill
/// would cover the outer half, and a scroll view would take a press there
/// before the handle was asked. Only the order of painting and of asking
/// differs from a [Row], never the order of the children, because that is the
/// order a screen reader reads them in and the Tab key visits them in.
///
/// A glass sidebar's blur reads what was painted before it, so the content
/// beside either sidebar reaches the inner edge of its blur.
class _Band extends Row {
  const _Band({required super.children}) : super(crossAxisAlignment: CrossAxisAlignment.stretch);

  @override
  RenderFlex createRenderObject(BuildContext context) {
    return _RenderBand(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: getEffectiveTextDirection(context),
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      clipBehavior: clipBehavior,
      spacing: spacing,
    );
  }
}

class _RenderBand extends RenderFlex {
  _RenderBand({
    required super.mainAxisAlignment,
    required super.mainAxisSize,
    required super.crossAxisAlignment,
    required super.textDirection,
    required super.verticalDirection,
    required super.textBaseline,
    required super.clipBehavior,
    required super.spacing,
  });

  /// Whether [child] is a sidebar: the content is the one child with a flex.
  static bool _isSidebar(RenderBox child) => ((child.parentData! as FlexParentData).flex ?? 0) == 0;

  // `RenderFlex.paint` paints its children through this, clipped or not.
  @override
  void defaultPaint(PaintingContext context, Offset offset) {
    for (final bool sidebars in const <bool>[false, true]) {
      RenderBox? child = firstChild;

      while (child != null) {
        final FlexParentData data = child.parentData! as FlexParentData;

        if (_isSidebar(child) == sidebars) {
          context.paintChild(child, data.offset + offset);
        }

        child = data.nextSibling;
      }
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (final bool sidebars in const <bool>[true, false]) {
      RenderBox? child = lastChild;

      while (child != null) {
        final RenderBox box = child;
        final FlexParentData data = box.parentData! as FlexParentData;

        if (_isSidebar(box) == sidebars &&
            result.addWithPaintOffset(
              offset: data.offset,
              position: position,
              hitTest: (BoxHitTestResult result, Offset local) =>
                  box.hitTest(result, position: local),
            )) {
          return true;
        }

        child = data.previousSibling;
      }
    }

    return false;
  }
}
