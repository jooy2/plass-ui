/// A twelve-column row and the cells in it.
library;

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/grid.dart';
import 'package:plass_ui/src/types.dart';

/// One cell of a [PlGrid].
///
/// A **description rather than a widget**, which is the idiom this package
/// already uses for an accordion's folds and a table's columns, and it is here
/// for the same reason: the grid has to reason about its members. It packs them
/// into rows by the columns they take, and a `Widget` is opaque — there is no
/// asking one how wide it means to be.
///
/// It is a width and nothing else. No sheet, no padding, no typography: what
/// goes inside brings its own, and a cell that drew a sheet would make [span] a
/// visual decision.
@immutable
class PlGridItem {
  /// Creates a cell.
  const PlGridItem({required this.child, this.span, this.offset, this.alignSelf});

  /// What the cell holds, laid out to the width the span works out to.
  final Widget child;

  /// How many of the grid's columns the cell takes, read against the grid's
  /// `columns` — so `6` is a half of the default twelve and a quarter of
  /// twenty-four.
  ///
  /// A span wider than the row is clamped to the row rather than overflowing.
  /// Left out, the cell fills the row.
  final PlassResponsive<int>? span;

  /// Columns left empty *before* the cell — space pushed in ahead of it, not an
  /// absolute position in the row.
  ///
  /// First in a twelve-column row, an offset of 4 with a span of 4 is the
  /// middle third; after a cell that already took four columns, the same offset
  /// skips four more and lands on the last third.
  final PlassResponsive<int>? offset;

  /// Overrides the row's `alignItems` for this cell alone.
  ///
  /// Has nothing to say in a row aligned on a baseline, where there is one
  /// baseline for every cell or none — see [PlassAlignSelf].
  final PlassAlignSelf? alignSelf;
}

/// A twelve-column row, and the parent every [PlGridItem] needs.
///
/// ```dart
/// PlGrid(
///   spacing: const PlassResponsive<double>(3),
///   items: <PlGridItem>[
///     PlGridItem(span: const PlassResponsive<int>(12, md: 8), child: main),
///     PlGridItem(span: const PlassResponsive<int>(12, md: 4), child: aside),
///   ],
/// )
/// ```
///
/// It draws nothing, and it takes no `variant`, `color`, `elevation`, `size` or
/// `density`. A grid is not a surface — it is the arrangement of the surfaces
/// inside it — and there is no padding here either: the gutter round a screen is
/// a `PlContainer`'s and the padding round content is a `PlCard`'s, and a grid
/// with a track of its own would be a third one to keep in step. [spacing] is
/// the only measurement it owns, and it is the space *between* cells.
///
/// Nesting is a `PlGrid` inside a cell's `child`: the inner grid re-declares the
/// column count for its own subtree while the cell around it keeps the width the
/// outer grid gave it.
class PlGrid extends StatelessWidget {
  /// Creates a grid.
  const PlGrid({
    required this.items,
    this.columns = const PlassResponsive<int>(12),
    this.spacing = const PlassResponsive<double>(2),
    this.rowSpacing,
    this.columnSpacing,
    this.justify = PlassJustify.start,
    this.alignItems = PlassAlignItems.stretch,
    this.alignContent,
    this.wrap = true,
    super.key,
  });

  /// The cells.
  final List<PlGridItem> items;

  /// How many columns a row is divided into. Every span and every offset inside
  /// is read against this number, so twenty-four makes a span of twelve a half
  /// and not a full width.
  final PlassResponsive<int> columns;

  /// The gutter between cells, on Tailwind's spacing scale — `4` is 16 logical
  /// pixels, the same length `gap-4` is in the React package. Fractions are
  /// allowed, so `1.5` is 6.
  final PlassResponsive<double> spacing;

  /// The gutter between rows only. Falls back to [spacing].
  final PlassResponsive<double>? rowSpacing;

  /// The gutter between columns only. Falls back to [spacing].
  final PlassResponsive<double>? columnSpacing;

  /// How a row distributes the space its cells did not use.
  final PlassJustify justify;

  /// How cells sit against each other across the row.
  ///
  /// [PlassAlignItems.stretch] is the default, and it is what makes a row of
  /// cards the same height without anybody asking.
  final PlassAlignItems alignItems;

  /// Where the rows sit when the grid is shorter than the box holding it. Only
  /// ever visible on a grid with a height of its own, which is why leaving it
  /// out also leaves the grid as tall as its rows.
  final PlassJustify? alignContent;

  /// Whether a row that runs out of columns continues on the next one.
  ///
  /// Turning it off gives one row, and that row **scrolls sideways**. The React
  /// build's row simply overflows and leaves the scrolling to the page, which
  /// is not something a Flutter screen has — an overflowing `Row` is a debug
  /// banner and nothing a reader can reach. The widths are still measured
  /// against the visible box, because the measuring happens outside the
  /// scroller.
  final bool wrap;

  @override
  Widget build(BuildContext context) {
    // The breakpoint is the **window's**, not this grid's box, which is what a
    // CSS media query measures — so a grid nested three cards deep still
    // changes shape at the same width as everything else on the screen.
    final PlassBreakpoint breakpoint = PlassBreakpoint.of(MediaQuery.sizeOf(context).width);

    final int columnTotal = columnCount(columns.resolve(breakpoint));
    final double gapX = spacingValue((columnSpacing ?? spacing).resolve(breakpoint));
    final double gapY = spacingValue((rowSpacing ?? spacing).resolve(breakpoint));

    // A cell's width is a share of the row, so the row has to be measured
    // first. The React package spells the same arithmetic as a percentage and
    // lets the browser do it; there is no stylesheet here to spell it in.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double track = trackWidth(
          width: constraints.maxWidth,
          gap: gapX,
          columns: columnTotal,
        );

        final List<Widget> runs = <Widget>[];
        List<_Cell> run = <_Cell>[];
        int used = 0;

        void close() {
          if (run.isEmpty) {
            return;
          }

          runs.add(_run(context, run, gap: gapX));
          run = <_Cell>[];
          used = 0;
        }

        for (final PlGridItem item in items) {
          final int offset = item.offset == null
              ? 0
              : columnUnits(item.offset!.resolve(breakpoint), min: 0, columns: columnTotal);
          final int span = item.span == null
              ? columnTotal
              : columnUnits(item.span!.resolve(breakpoint), min: 1, columns: columnTotal);

          // Packed by columns rather than by measured width, which is the same
          // decision the widths already make: every cell is a whole number of
          // columns, so counting them cannot disagree with itself by a rounded
          // pixel the way comparing two `double`s can.
          if (wrap && used > 0 && used + offset + span > columnTotal) {
            close();
          }

          run.add(
            _Cell(
              item: item,
              width: track * span - gapX,
              offset: track * offset,
              alignSelf: item.alignSelf ?? PlassAlignSelf.auto,
            ),
          );
          used += offset + span;
        }

        close();

        if (!wrap) {
          // One run, and it may be wider than the box. The measuring already
          // happened above, outside this scroller — a `LayoutBuilder` inside
          // one would be handed an infinite width and a percentage of infinity
          // is not a column.
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            // `start` and not `stretch`: inside a horizontal scroller there is
            // no width to stretch to, and asking for one is an infinite
            // constraint. A run that does not wrap is as wide as its cells.
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: runs,
            ),
          );
        }

        return Column(
          mainAxisSize: alignContent == null ? MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment: alignContent == null
              ? MainAxisAlignment.start
              : _mainAxis(alignContent!),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: gapY,
          children: runs,
        );
      },
    );
  }

  /// One run of cells.
  ///
  /// A row aligned on a baseline is the one shape that cannot also honour a
  /// per-cell alignment: CSS resolves a baseline per item, and a Flutter row is
  /// aligned on one baseline or on none. Every other row is a [_Run], which
  /// sizes itself to its tallest cell and then stretches or places each cell in
  /// that height — which is what makes `alignSelf` expressible at all.
  Widget _run(BuildContext context, List<_Cell> cells, {required double gap}) {
    // A row that does not wrap is inside a scroller, where the width is
    // unbounded — so it has to be as wide as its cells rather than as wide as
    // it is allowed to be, and there is no leftover space for `justify` to
    // distribute.
    final MainAxisSize mainAxisSize = wrap ? MainAxisSize.max : MainAxisSize.min;

    if (alignItems == PlassAlignItems.baseline) {
      return Row(
        mainAxisSize: mainAxisSize,
        mainAxisAlignment: _mainAxis(justify),
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        spacing: gap,
        children: <Widget>[for (final _Cell cell in cells) cell.build()],
      );
    }

    final PlassAlignSelf fallback = switch (alignItems) {
      PlassAlignItems.start => PlassAlignSelf.start,
      PlassAlignItems.center => PlassAlignSelf.center,
      PlassAlignItems.end => PlassAlignSelf.end,
      PlassAlignItems.stretch || PlassAlignItems.baseline => PlassAlignSelf.stretch,
    };

    return _Run(
      gap: gap,
      justify: justify,
      fill: mainAxisSize == MainAxisSize.max,
      textDirection: Directionality.of(context),
      children: <Widget>[
        for (final _Cell cell in cells)
          _RunSlot(
            align: cell.alignSelf == PlassAlignSelf.auto ? fallback : cell.alignSelf,
            child: cell.build(),
          ),
      ],
    );
  }

  static MainAxisAlignment _mainAxis(PlassJustify justify) {
    switch (justify) {
      // `stretch` is what CSS does with it: a member that already has a width
      // has nothing to stretch, so the row packs from the start.
      case PlassJustify.start:
      case PlassJustify.stretch:
        return MainAxisAlignment.start;
      case PlassJustify.center:
        return MainAxisAlignment.center;
      case PlassJustify.end:
        return MainAxisAlignment.end;
      case PlassJustify.spaceBetween:
        return MainAxisAlignment.spaceBetween;
      case PlassJustify.spaceAround:
        return MainAxisAlignment.spaceAround;
      case PlassJustify.spaceEvenly:
        return MainAxisAlignment.spaceEvenly;
    }
  }
}

/// One cell, measured.
@immutable
class _Cell {
  const _Cell({
    required this.item,
    required this.width,
    required this.offset,
    required this.alignSelf,
  });

  final PlGridItem item;
  final double width;
  final double offset;
  final PlassAlignSelf alignSelf;

  Widget build() {
    // `width` is already one gutter short, so the gap between two cells is the
    // gutter and no more — and a row of spans that add up to the column count
    // is exactly the width of the row.
    Widget cell = SizedBox(width: width < 0 ? 0 : width, child: item.child);

    if (offset > 0) {
      cell = Padding(
        padding: EdgeInsetsDirectional.only(start: offset),
        child: cell,
      );
    }

    return cell;
  }
}

/* ---------------------------------------------------------------------------
 * The run
 * ------------------------------------------------------------------------- */

/// How one cell sits across its run.
class _RunParentData extends ContainerBoxParentData<RenderBox> {
  PlassAlignSelf align = PlassAlignSelf.stretch;
}

/// Tells the run how the cell under it is aligned.
class _RunSlot extends ParentDataWidget<_RunParentData> {
  const _RunSlot({required this.align, required super.child});

  final PlassAlignSelf align;

  @override
  void applyParentData(RenderObject renderObject) {
    final _RunParentData data = renderObject.parentData! as _RunParentData;

    if (data.align != align) {
      data.align = align;
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => _Run;
}

/// One run of cells, as tall as its tallest cell.
///
/// This is what an `IntrinsicHeight` round a stretched `Row` used to do, done
/// without asking any cell for an intrinsic height. A `LayoutBuilder` cannot
/// answer that question, and a nested `PlGrid`, a chart, a table and a slider
/// all hold one, so a row with any of them in it threw. Here every cell is laid
/// out for real at its own height first, and a stretched cell is then laid out
/// again at the height of the run.
///
/// What that asks of a cell is the one thing the old row did not: a cell is
/// first laid out with no height to fill, so a `Spacer` or an `Expanded` in a
/// `Column` directly inside one has nothing to take. `MainAxisAlignment
/// .spaceBetween` pins a footer to the bottom of a stretched cell without
/// needing that height up front.
class _Run extends MultiChildRenderObjectWidget {
  const _Run({
    required this.gap,
    required this.justify,
    required this.fill,
    required this.textDirection,
    required super.children,
  });

  final double gap;
  final PlassJustify justify;

  /// Whether the run is as wide as it may be, rather than as wide as its cells.
  final bool fill;
  final TextDirection textDirection;

  @override
  _RenderRun createRenderObject(BuildContext context) {
    return _RenderRun(gap: gap, justify: justify, fill: fill, textDirection: textDirection);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderRun renderObject) {
    renderObject
      ..gap = gap
      ..justify = justify
      ..fill = fill
      ..textDirection = textDirection;
  }
}

class _RenderRun extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _RunParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _RunParentData> {
  _RenderRun({
    required double gap,
    required PlassJustify justify,
    required bool fill,
    required TextDirection textDirection,
  }) : _gap = gap,
       _justify = justify,
       _fill = fill,
       _textDirection = textDirection;

  double _gap;
  double get gap => _gap;
  set gap(double value) {
    if (_gap == value) return;
    _gap = value;
    markNeedsLayout();
  }

  PlassJustify _justify;
  PlassJustify get justify => _justify;
  set justify(PlassJustify value) {
    if (_justify == value) return;
    _justify = value;
    markNeedsLayout();
  }

  bool _fill;
  bool get fill => _fill;
  set fill(bool value) {
    if (_fill == value) return;
    _fill = value;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _RunParentData) {
      child.parentData = _RunParentData();
    }
  }

  @override
  void performLayout() {
    double height = 0;
    double content = 0;
    int count = 0;

    // Each cell at its own height. A cell carries its own width, and a `Row`
    // hands its children no width limit either, so neither does this.
    for (RenderBox? child = firstChild; child != null; child = childAfter(child)) {
      child.layout(const BoxConstraints(), parentUsesSize: true);
      height = math.max(height, child.size.height);
      content += child.size.width;
      count += 1;
    }

    height = constraints.constrainHeight(height);
    content += gap * math.max(0, count - 1);

    final double width = fill && constraints.hasBoundedWidth ? constraints.maxWidth : content;

    size = constraints.constrain(Size(width, height));

    final double leftover = math.max(0, size.width - content);
    final (double lead, double between) = switch (justify) {
      PlassJustify.start || PlassJustify.stretch => (0, gap),
      PlassJustify.center => (leftover / 2, gap),
      PlassJustify.end => (leftover, gap),
      PlassJustify.spaceBetween => count > 1 ? (0, gap + leftover / (count - 1)) : (0, gap),
      PlassJustify.spaceAround => (leftover / count / 2, gap + leftover / count),
      PlassJustify.spaceEvenly => (leftover / (count + 1), gap + leftover / (count + 1)),
    };

    double cursor = lead;

    for (RenderBox? child = firstChild; child != null; child = childAfter(child)) {
      final _RunParentData data = child.parentData! as _RunParentData;
      final bool stretch =
          data.align == PlassAlignSelf.stretch || data.align == PlassAlignSelf.auto;

      // Only a cell that is not already the height of the run is laid out
      // again, so a row of equal cells costs one pass.
      if (stretch && child.size.height != size.height) {
        child.layout(
          BoxConstraints.tightFor(width: child.size.width, height: size.height),
          parentUsesSize: true,
        );
      }

      final double dy = switch (data.align) {
        PlassAlignSelf.center => (size.height - child.size.height) / 2,
        PlassAlignSelf.end => size.height - child.size.height,
        _ => 0,
      };

      // Mirrored here rather than in `paint`, because a hit test and a
      // semantics rectangle read the offsets too.
      final double dx = textDirection == TextDirection.rtl
          ? size.width - cursor - child.size.width
          : cursor;

      data.offset = Offset(dx, dy);
      cursor += child.size.width + between;
    }
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToFirstActualBaseline(baseline);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
