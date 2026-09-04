/// A grid of data on a sheet of glass.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/internal/table.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

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
class PlTable<T> extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final color = this.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
    final density = this.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;
    final text = controlTextLeading[size]!;

    final grid = PlassGrid(
      columns: <PlassGridColumn>[
        for (final column in columns)
          PlassGridColumn(
            cell: (int index) => column.cell(rows[index], index),
            header: column.header,
            width: column.width,
            flex: column.flex,
            align: column.align,
          ),
      ],
      rowCount: rows.length,
      size: size,
      color: color,
      density: density,
      rowKey: rowKey == null ? null : (int index) => rowKey!(rows[index], index),
      rowTint: striped ? (int index) => index.isOdd ? tokens.stripe : null : null,
      empty: empty,
      hoverable: hoverable,
      onRowPressed: onRowPressed == null ? null : (int index) => onRowPressed!(rows[index], index),
      stickyHeader: stickyHeader,
      maxHeight: maxHeight,
      semanticLabel: semanticLabel,
    );

    return PlassSurfaceBox(
      surface: sheetSurface(tokens, variant: variant, elevation: elevation),
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
                if (caption != null)
                  PlassTableBand(
                    size: size,
                    density: density,
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        color: tokens.mutedFg,
                        fontSize: metaText[size]!,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                      child: caption!,
                    ),
                  ),
                if (bounded) Flexible(child: grid) else grid,
              ],
            );
          },
        ),
      ),
    );
  }
}
