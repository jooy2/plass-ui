/// A grid of data on a sheet of glass.
library;

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
    this.onRowPressed,
    this.variant = PlassVariant.glass,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
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

  /// Makes rows activatable, and turns on the hover treatment with them.
  final void Function(T row, int index)? onRowPressed;

  /// What the sheet under the grid is made of.
  final PlassVariant variant;

  /// Type scale and cell padding.
  final PlassSize size;

  /// Semantic colour role. It reaches the hover tint and the focus ring, and
  /// nothing else: data arrives with its own colours.
  final PlassColor color;

  /// How tightly the rows pack. Padding only — never the type scale.
  final PlassDensity density;

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
  /// Which row the pointer is over, and which one the keyboard is on.
  ///
  /// Two fields rather than one interaction state, because a table's row is not
  /// a widget: [TableRow] paints the band and the ring, and the cells inside it
  /// are what the pointer and the focus actually reach. The row state has to
  /// live above both.
  int? _hovered;
  int? _focused;

  bool get _interactive => widget.onRowPressed != null;

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
            for (final column in widget.columns)
              _cell(
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
                  // A heading is announced with every cell under it, which is
                  // most of what makes a grid of numbers readable without eyes.
                  child: Semantics(
                    container: true,
                    role: SemanticsRole.columnHeader,
                    child: column.header ?? const SizedBox.shrink(),
                  ),
                ),
                align: column.align,
                padding: padding,
              ),
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

    return PlassSurfaceBox(
      surface: sheetSurface(tokens, variant: widget.variant, elevation: widget.elevation),
      borderRadius: BorderRadius.circular(PlassTokens.radius[size]!),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: tokens.fg, fontSize: text.size, height: text.height),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.caption != null)
              DecoratedBox(
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
              ),
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
