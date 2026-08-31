/// A grid of data on a sheet of glass.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// The room the "nothing here" line keeps above and below itself.
///
/// Deliberately much more than a row's padding: an empty table is a shape with
/// a hole in it, and a hole one line tall reads as a row that failed to render
/// rather than as an answer.
const double _emptyPaddingY = 32;

/// A column: its heading, how wide it is, and how to get a cell out of a row.
///
/// This is the whole reason a table takes data rather than a grid of widgets.
/// Cells written out per row can silently disagree with the heading above them
/// about how many there are or what order they come in; a column list cannot.
///
/// [cell] is required, which is the one place this parts company with the React
/// build. There a column names a property and the cell is `row[key]` unless
/// `render` says otherwise; Dart has no such lookup on an arbitrary type, and a
/// map of `dynamic` bought at the price of the row's type would be a worse
/// bargain than writing the accessor.
@immutable
class PlTableColumn<T> {
  /// Creates a column.
  const PlTableColumn({
    required this.cell,
    this.header,
    this.width,
    this.flex = 1,
    this.align = PlassAlign.start,
  });

  /// Builds the cell for a row.
  final Widget Function(T row, int index) cell;

  /// The heading. Left out, the column is headed by nothing, which is what an
  /// actions column wants and what every other column does not.
  final Widget? header;

  /// A fixed width, in logical pixels.
  ///
  /// Left out, the column is as wide as its widest cell and then takes a [flex]
  /// share of whatever the sheet has left over.
  final double? width;

  /// How much of the leftover width this column takes, once every column has
  /// room for its content.
  ///
  /// The React build spells a proportion as a CSS length — `width: '30%'` — and
  /// this is the same idea in the units Flutter lays out in. Ignored when
  /// [width] is set, which is a width rather than a share.
  final double flex;

  /// Which edge the cell's content lines up against.
  ///
  /// [PlassAlign.start] by default. Numbers usually want [PlassAlign.end], so
  /// their digits line up in a column.
  final PlassAlign align;
}

/// A grid of data on a sheet of glass.
///
/// ```dart
/// PlTable<Invoice>(
///   caption: const Text('Recent invoices'),
///   hoverable: true,
///   rows: invoices,
///   columns: <PlTableColumn<Invoice>>[
///     PlTableColumn<Invoice>(header: const Text('Invoice'), cell: (Invoice row, int _) => Text(row.id)),
///     PlTableColumn<Invoice>(
///       header: const Text('Total'),
///       align: PlassAlign.end,
///       cell: (Invoice row, int _) => Text(row.total),
///     ),
///   ],
/// )
/// ```
///
/// The sheet is the ordinary Plass container — [variant], [size], [color],
/// [density] and [elevation] all mean what they mean everywhere else, and it is
/// never dyed. What the table adds is the part that is genuinely tabular: the
/// columns, the rows, and the fact that the two cannot drift apart.
///
/// Laid out by Flutter's own [Table], which is also where the table, row, cell
/// and column-header semantics come from. Every column is measured from the
/// content in it, exactly as a browser's automatic table layout is, so the same
/// data comes out the same shape in both packages.
///
/// There is no band behind the column names. The header is muted, semibold text
/// over a rule one step firmer than the ones between the rows: a filled strip
/// across the top of a grid is the fastest way to make data look like chrome,
/// and it puts all of a table's weight in the one place that needs none of it.
class PlTable<T> extends StatefulWidget {
  /// Creates a grid.
  const PlTable({
    required this.columns,
    required this.rows,
    this.rowKey,
    this.caption,
    this.empty,
    this.striped = false,
    this.hoverable = false,
    this.stickyHeader = false,
    this.maxHeight,
    this.onRowPressed,
    this.variant = PlassVariant.glass,
    this.size,
    this.color,
    this.density,
    this.elevation = 0,
    this.semanticLabel,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The columns, in the order they appear.
  ///
  /// Deliberately unasserted: `columns.length` cannot be read in a `const`
  /// constructor's initialiser list, and a table that could not be `const` for
  /// the sake of one check is a worse trade than an empty list drawing an empty
  /// grid.
  final List<PlTableColumn<T>> columns;

  /// The rows.
  final List<T> rows;

  /// A stable key per row.
  ///
  /// Left out, a row is identified by its position, which is right for a static
  /// table and wrong for one that sorts or filters: without it, sorting a table
  /// whose cells hold state moves the state and not the row.
  final LocalKey Function(T row, int index)? rowKey;

  /// Drawn above the grid, inside the sheet.
  final Widget? caption;

  /// What is shown instead of rows when [rows] is empty.
  ///
  /// A `Text('No data')` if it is left out. It is a parameter rather than a
  /// string read from a message catalogue for the reason every other message in
  /// the package is: a library that shipped translations would have to be told
  /// which language a screen is in, and the screen already knows.
  final Widget? empty;

  /// Tints every other row.
  ///
  /// Useful on a wide table where the eye has to track across; noise on a narrow
  /// one.
  final bool striped;

  /// Lights the row under the pointer.
  final bool hoverable;

  /// Pins the column names to the top of the grid while the rows scroll under
  /// them.
  ///
  /// The React build's page used to say this was impossible here, and the
  /// reason it gave was right: a pinned header means two grids, and two grids
  /// each measured from their own content cannot agree on a column width. What
  /// is drawn is therefore **not** a second grid. There is one [Table], with
  /// its header row in it exactly as before, and the pinned band is a copy of
  /// that row laid over the top of the scroll — each of its cells given the
  /// width the real header cell beside it was actually laid out at. One grid
  /// still decides every column; the band only repeats what it decided.
  ///
  /// It needs something to scroll in, and [maxHeight] is the usual answer — a
  /// grid as tall as its content has nothing to pin against.
  final bool stickyHeader;

  /// A hard cap on the grid's height, in logical pixels.
  ///
  /// Past it the rows scroll inside the sheet rather than the sheet growing.
  /// The **grid** and not the sheet: a [caption] sits above what scrolls, so a
  /// table's title cannot slide away from the table it names.
  ///
  /// Left out, the grid is as tall as its rows and scrolls only if something
  /// around it bounds its height — the scroll view is always there, so a table
  /// in a box too small for it scrolls rather than overflowing.
  final double? maxHeight;

  /// Makes rows activatable, and turns on the hover treatment with them.
  final void Function(T row, int index)? onRowPressed;

  /// What the sheet under the grid is made of.
  final PlassVariant variant;

  /// Type scale and cell padding.
  final PlassSize? size;

  /// Semantic colour role. It reaches the hover tint and the focus ring, and
  /// nothing else: data arrives with its own colours.
  final PlassColor? color;

  /// How tightly the rows pack. Padding only — never the type scale.
  final PlassDensity? density;

  /// Drop shadow depth, `0`–`3`.
  ///
  /// `0` is the default — a table is a grid set into the page rather than a
  /// panel floating over it.
  final PlassElevation elevation;

  /// The name a screen reader gives the table.
  ///
  /// [caption] is drawn *and* read, so a captioned table usually needs no name
  /// of its own. This is for the case where the two have to differ.
  final String? semanticLabel;

  @override
  State<PlTable<T>> createState() => _PlTableState<T>();
}

class _PlTableState<T> extends State<PlTable<T>> {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

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
  void didUpdateWidget(PlTable<T> oldWidget) {
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
    widget.onRowPressed?.call(widget.rows[index], index);
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
    final family = tokens.family(_color);
    final size = _size;
    final text = controlTextLeading[size]!;
    final padX = paddingX[_density]![size]!;
    final padding = EdgeInsets.symmetric(
      horizontal: padX,
      vertical: cellPaddingY[_density]![size]!,
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
    Widget headerCell(PlTableColumn<T> column) {
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
        for (var index = 0; index < widget.rows.length; index += 1)
          TableRow(
            key: widget.rowKey?.call(widget.rows[index], index),
            decoration: _rowDecoration(
              tokens,
              family,
              index: index,
              rule: rowRule,
              ring: family.ring,
            ),
            children: <Widget>[
              for (var column = 0; column < widget.columns.length; column += 1)
                _cell(
                  widget.columns[column].cell(widget.rows[index], index),
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
          if (widget.rows.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padX, vertical: _emptyPaddingY),
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

    final Widget? band = widget.caption == null
        ? null
        // Above what scrolls, so a table's title cannot slide away from the
        // table it names.
        : DecoratedBox(
            decoration: BoxDecoration(border: Border(bottom: rowRule)),
            child: Padding(
              padding: padding,
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: tokens.mutedFg,
                  fontSize: metaText[size]!,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
                child: widget.caption!,
              ),
            ),
          );

    return PlassSurfaceBox(
      surface: sheetSurface(tokens, variant: widget.variant, elevation: widget.elevation),
      borderRadius: BorderRadius.circular(PlassTokens.radius[size]!),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: tokens.fg, fontSize: text.size, height: text.height),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // The grid gives way when there is a height to give way *to*, so a
            // table in a box smaller than its rows scrolls rather than
            // overflowing it. Only then: a `Flexible` in a column with nothing
            // bounding its height is not a layout, it is an assertion — which
            // is exactly what a table inside a page's own scroll view would
            // hand it.
            final bool bounded = constraints.hasBoundedHeight;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ?band,
                if (bounded) Flexible(child: scrolling) else scrolling,
              ],
            );
          },
        ),
      ),
    );
  }

  /// The band behind a row, and the rule above it.
  ///
  /// A focused row trades both for the ring, which is drawn as the row's own
  /// border rather than as an outline around it: the sheet clips at its rounded
  /// corner, and a ring outside the first or last row would come back with its
  /// top or bottom sliced off.
  Decoration _rowDecoration(
    PlassTokens tokens,
    PlassColorFamily family, {
    required int index,
    required BorderSide rule,
    required Color ring,
  }) {
    final lit = widget.hoverable || _interactive;
    final fill = lit && _hovered == index
        ? family.soft
        : widget.striped && index.isOdd
        ? tokens.stripe
        : null;

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
