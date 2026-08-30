/// The vocabulary a screen's structure is written in, and what the components
/// that build one share.
///
/// The Dart half of the React package's `internal/page-layout.ts`, and it is
/// here for the same reason: several components read it — [PlPageLayout],
/// [PlHeader], [PlFooter], [PlSidebar] and [PlSidebarTrigger] — and every one
/// of them is also usable on its own. Keeping the scope in the layout's file
/// would make a header import a layout it may never be inside.
///
/// What the React version also has and this does not is the **measurement**.
/// There, a sidebar that holds its place has to be told how tall the header is,
/// because a `sticky` bar sits across the top of the window without taking
/// anything out of the flow. Here a [Column] has already done that arithmetic:
/// the band below the header is exactly what the header left, so there is
/// nothing to measure and nothing to write anywhere.
///
/// None of it is exported from `plass_ui.dart`.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/types.dart';

/// Which end of the band a sidebar takes. Logical, so it flips under RTL.
enum PlassSidebarSide {
  /// The leading end — the left of an English screen, the right of an Arabic one.
  start,

  /// The trailing end.
  end,
}

/// How far across a header or a footer reaches.
///
/// - [full] — the whole width, with the sidebars beginning underneath it. The
///   arrangement of a website: one bar across the top, and the screen below it.
/// - [content] — only the column between the sidebars, which run the full
///   height beside it. The arrangement of an application: the navigation is the
///   outermost thing on the screen and the bar belongs to the view.
///
/// There is no third value, because there is no third arrangement: what is
/// being decided is which of the two takes the corner.
enum PlPageLayoutSpan {
  /// The whole width.
  full,

  /// Only the column between the sidebars.
  content,
}

/// What a sidebar and a trigger read off the layout around them.
class PlassPageLayoutScope extends InheritedWidget {
  /// Wraps the band a layout arranges.
  const PlassPageLayoutScope({
    required this.collapsed,
    required this.open,
    required this.setOpen,
    required super.child,
    super.key,
  });

  /// Whether the layout is narrow enough that its sidebars are drawers.
  ///
  /// Measured with a [LayoutBuilder] against the space the layout was actually
  /// given rather than against the window, which is the one thing this can do
  /// better than a media query: an app shell inside a pane collapses when *the
  /// pane* is narrow, not when the window is.
  final bool collapsed;

  /// Whether each side's drawer is open. Only meaningful while [collapsed].
  final Map<PlassSidebarSide, bool> open;

  /// Opens or closes one of them.
  final void Function(PlassSidebarSide side, bool open) setOpen;

  /// The layout above, or `null` when there is not one.
  ///
  /// A sidebar, a header and a footer all build perfectly well without one —
  /// they are a panel, a bar and a bar. What they cannot do on their own is
  /// agree with each other about where they sit, which is the whole of what a
  /// layout adds and the reason a component has to be able to tell.
  static PlassPageLayoutScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PlassPageLayoutScope>();
  }

  @override
  bool updateShouldNotify(PlassPageLayoutScope oldWidget) {
    return collapsed != oldWidget.collapsed ||
        open[PlassSidebarSide.start] != oldWidget.open[PlassSidebarSide.start] ||
        open[PlassSidebarSide.end] != oldWidget.open[PlassSidebarSide.end];
  }
}

/// Which end of the band the sidebar being built right now takes.
///
/// A second, one-value scope rather than a field on the one above, because it
/// is the one fact that differs *between* two sidebars in the same layout: the
/// layout wraps each slot in its own scope, so a sidebar handed to the trailing
/// slot needs no `side` of its own to know where it is. Absent is "nobody
/// said", which a standalone sidebar reads as [PlassSidebarSide.start].
class PlassSidebarSideScope extends InheritedWidget {
  /// Wraps one sidebar.
  const PlassSidebarSideScope({required this.side, required super.child, super.key});

  /// The end this sidebar takes.
  final PlassSidebarSide side;

  /// The side named for this subtree, or `null` when nobody said.
  static PlassSidebarSide? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PlassSidebarSideScope>()?.side;
  }

  @override
  bool updateShouldNotify(PlassSidebarSideScope oldWidget) => side != oldWidget.side;
}

/// [PlassSidebarSide.start] and [PlassSidebarSide.end] as the two sides a
/// [PlDrawer] speaks.
///
/// A sidebar says which end of the band it takes, because that is a layout
/// question and a layout flips under RTL on its own. A drawer is attached to an
/// edge of the screen, which [PlassSide] names physically for the same reason a
/// tooltip above a button is above it in every writing direction — so the two
/// have to be translated, and the ambient [TextDirection] is what translates
/// them.
PlassSide drawerSide(PlassSidebarSide side, TextDirection direction) {
  final bool rtl = direction == TextDirection.rtl;

  if (side == PlassSidebarSide.start) {
    return rtl ? PlassSide.right : PlassSide.left;
  }

  return rtl ? PlassSide.left : PlassSide.right;
}
