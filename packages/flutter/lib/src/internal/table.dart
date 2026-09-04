/// The grid two tables draw, and the reason it is written once.
///
/// [PlTable] draws a grid it is given; `PlDataTable` sorts, filters and pages
/// its own rows and then draws one. Everything below the columns is the same in
/// both — the measured column widths, the hover band, the one focus stop per
/// row, the rule between rows and the header pinned over the scroll — and two
/// copies of that is how the rows under a sorted table end up a shade off the
/// rows under a plain one.
///
/// What the two do differently is above it: what a column *is*, where the rows
/// came from, and what else the sheet holds. So this takes a column list that
/// has already forgotten the row type, and asks the caller what colour each row
/// should be rather than deciding it here.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// The room the "nothing here" line keeps above and below itself.
///
/// Deliberately much more than a row's padding: an empty table is a shape with
/// a hole in it, and a hole one line tall reads as a row that failed to render
/// rather than as an answer.
const double plassTableEmptyPaddingY = 32;

/// One column of the grid, with the row type already closed over.
@immutable
class PlassGridColumn {
  /// Creates a column.
  const PlassGridColumn({
    required this.cell,
    this.header,
    this.width,
    this.flex = 1,
    this.align = PlassAlign.start,
  });

  /// Builds the cell for the row at [index].
  final Widget Function(int index) cell;

  /// The heading, already wearing whatever the caller wanted it to wear.
  final Widget? header;

  /// A fixed width, in logical pixels.
  final double? width;

  /// How much of the leftover width this column takes, once every column has
  /// room for its content.
  ///
  /// `null` keeps the column out of the share-out entirely: it is as wide as
  /// its widest cell and no wider, which is what a column holding a control
  /// rather than data wants.
  final double? flex;

  /// Which edge the cell's content lines up against.
  final PlassAlign align;
}

/// The grid itself: the header row, the rows, and everything that happens to a
/// row when a pointer or a keyboard reaches it.
///
/// Laid out by Flutter's own [Table], which is also where the table, row, cell
/// and column-header semantics come from. Every column is measured from the
/// content in it, exactly as a browser's automatic table layout is, so the same
/// data comes out the same shape in both packages.
class PlassGrid extends StatefulWidget {
  /// Creates a grid.
  const PlassGrid({
    required this.columns,
    required this.rowCount,
    required this.size,
    required this.color,
    required this.density,
    this.rowKey,
    this.rowTint,
    this.empty,
    this.hoverable = false,
    this.onRowPressed,
    this.stickyHeader = false,
    this.maxHeight,
    this.semanticLabel,
    super.key,
  });

  /// The columns, in the order they appear.
  final List<PlassGridColumn> columns;

  /// How many rows there are.
  final int rowCount;

  /// Type scale and cell padding, already resolved against the theme.
  final PlassSize size;

  /// The family the hover band and the focus ring are drawn from.
  final PlassColor color;

  /// How tightly the rows pack.
  final PlassDensity density;

  /// A stable key per row.
  final LocalKey Function(int index)? rowKey;

  /// What colour a row rests at — striping, selection, anything the caller
  /// wants to say about a row. The hover band wins over whatever it returns,
  /// because a reader pointing at a row is asking about *that* row.
  final Color? Function(int index)? rowTint;

  /// What is shown instead of rows when there are none.
  final Widget? empty;

  /// Lights the row under the pointer.
  final bool hoverable;

  /// Makes rows activatable, and turns on the hover treatment with them.
  final void Function(int index)? onRowPressed;

  /// Pins the column names to the top of the grid while the rows scroll under
  /// them.
  ///
  /// A pinned header means two grids, and two grids each measured from their
  /// own content cannot agree on a column width — so what is drawn is **not**
  /// a second grid. There is one [Table] with its header row in it, and the
  /// pinned band is a copy of that row laid over the top of the scroll, each of
  /// its cells given the width the real header cell beside it was laid out at.
  /// One grid still decides every column; the band only repeats what it decided.
  final bool stickyHeader;

  /// A hard cap on the grid's height, in logical pixels.
  final double? maxHeight;

  /// The name a screen reader gives the table.
  final String? semanticLabel;

  @override
  State<PlassGrid> createState() => _PlassGridState();
}

class _PlassGridState extends State<PlassGrid> {
  /// Which row the pointer is over, and which one the keyboard is on.
  ///
  /// Two fields rather than one interaction state, because a table's row is not
  /// a widget: [TableRow] paints the band and the ring, and the cells inside it
  /// are what the pointer and the focus actually reach. The row state has to
  /// live above both.
  int? _hovered;
  int? _focused;

  /// One key per column, on the real header's cells, so the pinned band can be
  /// given the widths the grid actually laid out.
  final List<GlobalKey> _headerKeys = <GlobalKey>[];

  /// Those widths, once they have been read.
  List<double>? _columnWidths;

  /// The width the grid was measured at, so a resize is measured again and
  /// anything else is not.
  double? _measuredAt;

  bool get _interactive => widget.onRowPressed != null;

  @override
  void initState() {
    super.initState();
    _syncKeys();
  }

  @override
  void didUpdateWidget(PlassGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncKeys();

    // The columns changed under the measurement, so it is worth nothing.
    if (widget.columns.length != oldWidget.columns.length) {
      _measuredAt = null;
      _columnWidths = null;
    }
  }

  void _syncKeys() {
    while (_headerKeys.length < widget.columns.length) {
      _headerKeys.add(GlobalKey());
    }

    if (_headerKeys.length > widget.columns.length) {
      _headerKeys.removeRange(widget.columns.length, _headerKeys.length);
    }
  }

  /// Reads how wide the grid actually laid each column out.
  ///
  /// Measured rather than computed, which is the whole of why a pinned header
  /// is possible at all: the widths belong to the one [Table] that owns every
  /// row, and a band that asks it for them cannot disagree with it.
  void _measure() {
    if (!mounted) {
      return;
    }

    final next = <double>[];

    for (final key in _headerKeys) {
      final box = key.currentContext?.findRenderObject() as RenderBox?;

      if (box == null || !box.hasSize) {
        return;
      }

      next.add(box.size.width);
    }

    if (_columnWidths == null || !listEquals(_columnWidths, next)) {
      setState(() => _columnWidths = next);
    }
  }

  void _press(int index) {
    widget.onRowPressed?.call(index);
  }

  void _hover(int index, {required bool over}) {
    if (over) {
      if (_hovered != index) {
        setState(() => _hovered = index);
      }

      return;
    }

    if (_hovered == index) {
      setState(() => _hovered = null);
    }
  }

  void _focus(int index, {required bool visible}) {
    if (visible) {
      if (_focused != index) {
        setState(() => _focused = index);
      }

      return;
    }

    if (_focused == index) {
      setState(() => _focused = null);
    }
  }

  /// A cell's own box: the padding, the alignment and — for a row that answers
  /// a press — the pointer and the keyboard.
  ///
  /// The gesture and the mouse region are outside the padding on purpose. A row
  /// is pressed anywhere on it, including the space between the text and the
  /// rule under it, and a hit region that stopped at the glyphs would be a row
  /// that ignores most of itself.
  Widget _cell(
    Widget content, {
    required PlassAlign align,
    required EdgeInsets padding,
    int? row,
    bool first = false,
  }) {
    Widget cell = Padding(
      padding: padding,
      child: Align(
        alignment: switch (align) {
          PlassAlign.start => AlignmentDirectional.centerStart,
          PlassAlign.center => Alignment.center,
          PlassAlign.end => AlignmentDirectional.centerEnd,
        },
        child: content,
      ),
    );

    if (row == null) {
      return cell;
    }

    if (_interactive) {
      cell = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _press(row),
        child: cell,
      );
    }

    if (_interactive || widget.hoverable) {
      cell = MouseRegion(
        cursor: _interactive ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) => _hover(row, over: true),
        onExit: (_) => _hover(row, over: false),
        child: cell,
      );
    }

    // One focus stop per row, and it lives in the row's first cell — the only
    // place it can, since the row itself is not a widget. What it lights is the
    // whole row, because the ring is painted by the row's decoration.
    if (_interactive && first) {
      cell = FocusableActionDetector(
        shortcuts: PlassInteractive.defaultShortcuts,
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (ActivateIntent _) {
              _press(row);

              return null;
            },
          ),
        },
        onShowFocusHighlight: (bool value) => _focus(row, visible: value),
        child: cell,
      );
    }

    return cell;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(widget.color);
    final size = widget.size;
    final text = controlTextLeading[size]!;
    final padX = paddingX[widget.density]![size]!;
    final padding = EdgeInsets.symmetric(
      horizontal: padX,
      vertical: cellPaddingY[widget.density]![size]!,
    );

    // Two weights of rule, and the whole of the table's structure. `divider`
    // scores one row off the next — the same ink a card and a list are scored
    // with, so a table on a card and the card's own rules are one family of
    // lines. The header sits on `border`, one step firmer, because the break
    // between the names of the columns and the data under them is the one
    // division a reader has to find without looking for it.
    final rowRule = BorderSide(color: tokens.divider, width: hairline);
    final headRule = BorderSide(color: tokens.border, width: hairline);

    /// One header cell's content, built the same way for the grid and for the
    /// band pinned over it — the band is a *copy* of the header, so anything
    /// written twice here is somewhere the two could come out different.
    Widget headerCell(PlassGridColumn column) {
      return _cell(
        DefaultTextStyle.merge(
          style: TextStyle(
            color: tokens.mutedFg,
            fontSize: text.size,
            height: text.height,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          // A heading is announced with every cell under it, which is most of
          // what makes a grid of numbers readable without eyes.
          child: Semantics(
            container: true,
            role: SemanticsRole.columnHeader,
            child: column.header ?? const SizedBox.shrink(),
          ),
        ),
        align: column.align,
        padding: padding,
      );
    }

    final grid = Table(
      columnWidths: <int, TableColumnWidth>{
        for (var index = 0; index < widget.columns.length; index += 1)
          index: switch (widget.columns[index].width) {
            final double width => FixedColumnWidth(width),
            // Measured from the content, exactly as a browser's automatic table
            // layout measures it, and then handed a share of whatever the sheet
            // has left over.
            null => IntrinsicColumnWidth(flex: widget.columns[index].flex),
          },
      },
      // Every cell is as tall as the tallest one in its row, so a row that
      // answers a press answers on all of itself rather than only on the line
      // of text that happens to be longest.
      defaultVerticalAlignment: TableCellVerticalAlignment.intrinsicHeight,
      children: <TableRow>[
        TableRow(
          decoration: BoxDecoration(border: Border(bottom: headRule)),
          children: <Widget>[
            for (var index = 0; index < widget.columns.length; index += 1)
              // Keyed only so the pinned band can be told how wide the grid
              // laid this column out. Nothing else reads them.
              KeyedSubtree(key: _headerKeys[index], child: headerCell(widget.columns[index])),
          ],
        ),
        for (var index = 0; index < widget.rowCount; index += 1)
          TableRow(
            key: widget.rowKey?.call(index),
            decoration: _rowDecoration(family, index: index, rule: rowRule, ring: family.ring),
            children: <Widget>[
              for (var column = 0; column < widget.columns.length; column += 1)
                _cell(
                  widget.columns[column].cell(index),
                  align: widget.columns[column].align,
                  padding: padding,
                  row: index,
                  first: column == 0,
                ),
            ],
          ),
      ],
    );

    // Everything the rows scroll past, and nothing a title should scroll with.
    Widget scrolling = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Semantics(label: widget.semanticLabel, child: grid),
          if (widget.rowCount == 0)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padX, vertical: plassTableEmptyPaddingY),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: tokens.mutedFg),
                textAlign: TextAlign.center,
                child: Center(child: widget.empty ?? const Text('No data')),
              ),
            ),
        ],
      ),
    );

    if (widget.maxHeight != null) {
      scrolling = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: widget.maxHeight!),
        child: scrolling,
      );
    }

    if (widget.stickyHeader) {
      scrolling = Stack(
        children: <Widget>[
          scrolling,
          if (_columnWidths != null)
            PositionedDirectional(
              top: 0,
              start: 0,
              end: 0,
              child: _PinnedHeader(
                // Opaque, and it has to be: rows pass directly underneath, and
                // a translucent band would let them through. The glass at its
                // densest laid over the page's own surface colour, flattened to
                // the one colour that is what those two stacked would look
                // like.
                fill: Color.alphaBlend(tokens.glassPress, tokens.surface),
                rule: headRule,
                widths: _columnWidths!,
                cells: <Widget>[for (final column in widget.columns) headerCell(column)],
              ),
            ),
        ],
      );

      // The widths are read after the frame that laid them out, and read again
      // whenever the grid is laid out at a different width. Assigning the cache
      // key here rather than inside the callback is what keeps a rebuild from
      // queueing a second measurement of the same layout.
      //
      // Held in a second name rather than reassigned: a builder that returned
      // the variable it was assigned to would be a widget containing itself.
      final Widget pinned = scrolling;

      scrolling = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (_measuredAt != constraints.maxWidth) {
            _measuredAt = constraints.maxWidth;
            WidgetsBinding.instance.addPostFrameCallback((Duration _) => _measure());
          }

          return pinned;
        },
      );
    }

    return DefaultTextStyle.merge(
      style: TextStyle(color: tokens.fg, fontSize: text.size, height: text.height),
      child: scrolling,
    );
  }

  /// The band behind a row, and the rule above it.
  ///
  /// A focused row trades both for the ring, which is drawn as the row's own
  /// border rather than as an outline around it: the sheet clips at its rounded
  /// corner, and a ring outside the first or last row would come back with its
  /// top or bottom sliced off.
  Decoration _rowDecoration(
    PlassColorFamily family, {
    required int index,
    required BorderSide rule,
    required Color ring,
  }) {
    final lit = widget.hoverable || _interactive;
    // The pointer wins over whatever the caller said the row rests at: a reader
    // pointing at a row is asking about that row, not about the set it is in.
    final fill = lit && _hovered == index ? family.soft : widget.rowTint?.call(index);

    if (_focused == index) {
      return BoxDecoration(
        color: fill,
        border: Border.all(color: ring, width: focusRingWidth),
      );
    }

    return BoxDecoration(
      color: fill,
      // Every row but the first, which already has the header's rule above it.
      border: index == 0 ? null : Border(top: rule),
    );
  }
}

/// The column names, held at the top of the grid while the rows go under them.
///
/// A copy of the header row rather than a grid of its own: every cell is put in
/// a box of the width the one [Table] laid the real header cell out at, so the
/// band cannot disagree with the data beneath it about where a column starts.
/// The real header is still down there, directly under this one at the top of
/// the scroll and hidden behind it everywhere else.
///
/// Silent, because the row it copies is not: the names are already announced as
/// column headers by the grid, and a second set would be every column named
/// twice.
class _PinnedHeader extends StatelessWidget {
  const _PinnedHeader({
    required this.fill,
    required this.rule,
    required this.widths,
    required this.cells,
  });

  /// An opaque colour. Rows pass under the band, and a translucent one is a
  /// band they show through.
  final Color fill;

  /// The rule under the names — the firmer of the table's two.
  final BorderSide rule;

  /// How wide the grid laid each column out.
  final List<double> widths;

  /// The names, built the same way the grid built them.
  final List<Widget> cells;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          border: Border(bottom: rule),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (var index = 0; index < cells.length; index += 1)
                SizedBox(width: index < widths.length ? widths[index] : null, child: cells[index]),
            ],
          ),
        ),
      ),
    );
  }
}

/// The band a caption or a toolbar sits in, above or below the grid, inside the
/// sheet and outside what scrolls.
///
/// A title that slid away above the rows would take the table's name off the
/// screen with it, which is the whole reason this is not part of the grid.
class PlassTableBand extends StatelessWidget {
  /// Creates a band.
  const PlassTableBand({
    required this.child,
    required this.size,
    required this.density,
    this.top = false,
    super.key,
  });

  /// What the band holds.
  final Widget child;

  /// The scale its padding is taken from.
  final PlassSize size;

  /// How tightly it packs.
  final PlassDensity density;

  /// Whether the rule is above the band rather than under it. A footer's rule
  /// is above it; a caption's and a toolbar's are under.
  final bool top;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final rule = BorderSide(color: tokens.divider, width: hairline);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: top ? Border(top: rule) : Border(bottom: rule),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: paddingX[density]![size]!,
          vertical: cellPaddingY[density]![size]!,
        ),
        child: child,
      ),
    );
  }
}
