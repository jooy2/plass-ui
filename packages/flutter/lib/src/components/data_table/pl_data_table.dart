/// A table that owns its rows: it sorts them, narrows them to what was typed,
/// hands them out a page at a time and remembers which of them are ticked.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/checkbox/pl_checkbox.dart';
import 'package:plass_ui/src/components/pagination/pl_pagination.dart';
import 'package:plass_ui/src/components/skeleton/pl_skeleton.dart';
import 'package:plass_ui/src/components/text_field/pl_text_field.dart';
import 'package:plass_ui/src/internal/data_table.dart';
import 'package:plass_ui/src/internal/date.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/search.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/internal/table.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

export 'package:plass_ui/src/internal/data_table.dart' show PlassSort, PlassSortDirection;

/// Which way a column runs when it is sorted.
typedef PlDataTableSortDirection = PlassSortDirection;

/// The column being sorted on, and its direction.
typedef PlDataTableSort = PlassSort;

/// How many rows may be ticked at once.
///
/// [none] is the default. A table that draws a tick column it does nothing with
/// has promised something it does not do.
enum PlDataTableSelection {
  /// No tick column at all.
  none,

  /// One row at a time.
  single,

  /// Any number of rows, with a tick-everything box at the top.
  multiple,
}

/// How the rows are handed out.
enum PlDataTablePaging {
  /// All of them, in one body. Pair it with `maxHeight` and the rows scroll
  /// inside the sheet instead of the sheet growing.
  scroll,

  /// A slice at a time, with a pager in the footer. Right when a row's position
  /// in the whole set is information, and the only honest option when the rows
  /// are fetched a page at a time.
  pages,
}

/// The three things the table does to the rows, and the ones an application can
/// take back.
///
/// Naming a stage in `manual` means the rows arriving in `rows` have already
/// had it done to them — by a server, usually — so the table reports the
/// reader's intent and draws what it is given rather than doing the work twice.
enum PlDataTableStage {
  /// The rows arrive already in order.
  sort,

  /// The rows arrive already narrowed to the query.
  search,

  /// The rows arrive one page at a time.
  pages,
}

/// A column: its heading, how to get a cell out of a row, and what the row *is*
/// as far as the sort and the search are concerned.
///
/// [cell] is required, which is where this parts company with the React build:
/// there a column names a property and the cell is `row[key]` unless `render`
/// says otherwise, and Dart has no such lookup on an arbitrary type. [value] is
/// the other half of the same problem — the sort and the search cannot read a
/// widget, so a sortable or searchable column says what it holds.
@immutable
class PlDataTableColumn<T> {
  /// Creates a column.
  const PlDataTableColumn({
    required this.key,
    required this.cell,
    this.header,
    this.width,
    this.flex = 1,
    this.align = PlassAlign.start,
    this.value,
    this.sortable = false,
    this.compare,
    this.unsearchable = false,
  });

  /// Identifies the column to the sort.
  ///
  /// A plain [String], not a widget [Key]: the React build calls it the same
  /// thing, and a table sorted by `'customer'` in one build and by something
  /// else in the other would be two APIs.
  final String key;

  /// Builds the cell for a row.
  final Widget Function(T row, int index) cell;

  /// The heading.
  final Widget? header;

  /// A fixed width, in logical pixels.
  final double? width;

  /// How much of the leftover width this column takes.
  final double flex;

  /// Which edge the cell's content lines up against.
  final PlassAlign align;

  /// What this column *is*, for the sort and the search.
  ///
  /// A sortable column needs it, and so does a searchable one: [cell] returns a
  /// widget, and a widget has no order and no text to look inside.
  final Object? Function(T row)? value;

  /// Puts the heading in the sort rotation: ascending, descending, then back to
  /// the order the rows arrived in.
  final bool sortable;

  /// Orders two rows against each other, when [compareValues] on [value] is not
  /// enough.
  final int Function(T a, T b)? compare;

  /// Keeps this column out of the search. Right for a column of identifiers a
  /// reader never types, where a match is a row they cannot see the reason for.
  final bool unsearchable;
}

/// A table that owns its rows.
///
/// ```dart
/// PlDataTable<Invoice>(
///   rows: invoices,
///   rowKey: (Invoice row, int _) => row.id,
///   searchable: true,
///   selection: PlDataTableSelection.multiple,
///   paging: PlDataTablePaging.pages,
///   columns: <PlDataTableColumn<Invoice>>[
///     PlDataTableColumn<Invoice>(
///       key: 'customer',
///       header: const Text('Customer'),
///       sortable: true,
///       value: (Invoice row) => row.customer,
///       cell: (Invoice row, int _) => Text(row.customer),
///     ),
///   ],
/// )
/// ```
///
/// [PlTable] is the one to reach for when the rows are already in the order
/// they belong in. Everything below the columns is the same grid — the measured
/// widths, the hover band, the rule between rows, the pinned header — because
/// both draw it out of one place.
///
/// Every one of sort, search, selection and page is **controllable and
/// uncontrolled by default**, so the ordinary table is the code above and a
/// table backed by a server is the same code with [manual] and the four
/// callbacks. Nothing changes shape in between.
class PlDataTable<T> extends StatefulWidget {
  /// Creates a table.
  const PlDataTable({
    required this.columns,
    required this.rows,
    this.rowKey,
    this.caption,
    this.empty,
    this.striped = false,
    this.hoverable = false,
    this.stickyHeader = true,
    this.maxHeight,
    this.onRowPressed,
    this.sort,
    this.initialSort,
    this.onSortChanged,
    this.searchable = false,
    this.search,
    this.initialSearch = '',
    this.onSearchChanged,
    this.searchPlaceholder,
    this.selection = PlDataTableSelection.none,
    this.selected,
    this.initialSelected,
    this.onSelectedChanged,
    this.isRowSelectable,
    this.paging = PlDataTablePaging.scroll,
    this.pageSize = 10,
    this.page,
    this.initialPage = 1,
    this.onPageChanged,
    this.rowCount,
    this.manual = const <PlDataTableStage>[],
    this.loading = false,
    this.toolbar,
    this.footer,
    this.variant = PlassVariant.glass,
    this.size,
    this.color,
    this.density,
    this.elevation = 0,
    this.semanticLabel,
    this.selectAllLabel,
    this.selectRowLabel,
    this.searchLabel,
    super.key,
  }) : assert(pageSize > 0, 'pageSize must be at least 1'),
       assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The columns, in the order they appear.
  final List<PlDataTableColumn<T>> columns;

  /// The rows, in the order they arrived in.
  final List<T> rows;

  /// A stable key per row, and the one thing worth setting before anything
  /// else.
  ///
  /// Left out, a row is identified by its position — which is wrong for every
  /// table this widget is for: sorting moves a row and its position stays
  /// behind, so a selection made before the sort belongs to different rows
  /// after it.
  final Object Function(T row, int index)? rowKey;

  /// Drawn above the grid, inside the sheet.
  final Widget? caption;

  /// What is shown instead of rows when there are none left to show.
  final Widget? empty;

  /// Tints every other row.
  final bool striped;

  /// Lights the row under the pointer.
  final bool hoverable;

  /// Pins the column names to the top of the grid while the rows scroll under
  /// them. On by default here, where it is off for [PlTable]: a table that
  /// sorts is a table a reader scrolls.
  final bool stickyHeader;

  /// A hard cap on the grid's height, in logical pixels.
  final double? maxHeight;

  /// Makes rows activatable, and turns on the hover treatment with them.
  final void Function(T row, int index)? onRowPressed;

  /// The sorted column and its direction. Pass it to control the sort.
  final PlDataTableSort? sort;

  /// Where the sort starts when the table keeps it itself.
  final PlDataTableSort? initialSort;

  /// Called with the sort a heading press asks for, `null` for the third press.
  final ValueChanged<PlDataTableSort?>? onSortChanged;

  /// Draws a field above the grid that narrows the rows to what was typed.
  final bool searchable;

  /// The query. Pass it to control the field.
  final String? search;

  /// Where the query starts when the table keeps it itself.
  final String initialSearch;

  /// Called with what the reader typed.
  final ValueChanged<String>? onSearchChanged;

  /// The field's placeholder.
  final String? searchPlaceholder;

  /// How many rows may be ticked at once.
  final PlDataTableSelection selection;

  /// The ticked rows, as their keys. Pass it to control the selection.
  final List<Object>? selected;

  /// Where the selection starts when the table keeps it itself.
  final List<Object>? initialSelected;

  /// Called with the keys of every ticked row, and with the rows themselves.
  final void Function(List<Object> selected, List<T> rows)? onSelectedChanged;

  /// Keeps a row out of the selection — a total line, a row already spent.
  final bool Function(T row, int index)? isRowSelectable;

  /// How the rows are handed out.
  final PlDataTablePaging paging;

  /// How many rows a page holds.
  final int pageSize;

  /// The page being read, counted from `1`. Pass it to control the pager.
  final int? page;

  /// Where the pager starts when the table keeps it itself.
  final int initialPage;

  /// Called with the page a pager press asks for.
  final ValueChanged<int>? onPageChanged;

  /// How many rows there are in total, when the table is only ever handed one
  /// page of them. Required for manual paging and ignored without it.
  final int? rowCount;

  /// The stages an application has already done to [rows] itself.
  final List<PlDataTableStage> manual;

  /// Draws bars in place of the rows.
  final bool loading;

  /// Drawn in the toolbar, at the end. A filter, a button, a count of its own.
  final Widget? toolbar;

  /// Drawn in the footer, at the start, in place of the row count.
  final Widget? footer;

  /// What the sheet under the grid is made of.
  final PlassVariant variant;

  /// Type scale and cell padding.
  final PlassSize? size;

  /// Semantic colour role. It reaches the hover tint, the selection tint, the
  /// ticks and the focus ring, and nothing else: data arrives with its own
  /// colours.
  final PlassColor? color;

  /// How tightly the rows pack. Padding only — never the type scale.
  final PlassDensity? density;

  /// Drop shadow depth, `0`–`3`.
  final PlassElevation elevation;

  /// The name a screen reader gives the table.
  final String? semanticLabel;

  /// Names the box at the top of the tick column.
  final String? selectAllLabel;

  /// Names a row's own tick.
  final String? selectRowLabel;

  /// Names the search field.
  final String? searchLabel;

  @override
  State<PlDataTable<T>> createState() => _PlDataTableState<T>();
}

class _PlDataTableState<T> extends State<PlDataTable<T>> {
  late TextEditingController _search;
  PlassSort? _sort;
  late List<Object> _selected;
  late int _page;

  /// The last row a tick was pressed on, so shift can measure a range from it.
  Object? _anchor;

  @override
  void initState() {
    super.initState();
    _sort = widget.initialSort;
    _selected = List<Object>.of(widget.selected ?? widget.initialSelected ?? const <Object>[]);
    _page = widget.initialPage;
    _search = TextEditingController(text: widget.search ?? widget.initialSearch);
  }

  @override
  void didUpdateWidget(PlDataTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.search != null && widget.search != _search.text) {
      _search.text = widget.search!;
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

  PlassSort? get _currentSort => widget.sort ?? _sort;
  List<Object> get _currentSelected => widget.selected ?? _selected;

  bool get _doesSort => !widget.manual.contains(PlDataTableStage.sort);
  bool get _doesSearch => !widget.manual.contains(PlDataTableStage.search);
  bool get _doesPage => !widget.manual.contains(PlDataTableStage.pages);
  bool get _ticks => widget.selection != PlDataTableSelection.none;

  Object _keyOf(T row, int index) => widget.rowKey?.call(row, index) ?? index;

  Object? _valueOf(PlDataTableColumn<T> column, T row) => column.value?.call(row);

  /// The rows the reader can see: narrowed, ordered, and cut to a page.
  List<T> get _shown {
    var rows = widget.rows;

    if (_doesSearch && _search.text.isNotEmpty) {
      // The query is folded once here rather than once per row per column.
      final needle = searchText(_search.text);
      final wanted = widget.columns.where((PlDataTableColumn<T> one) => !one.unsearchable);

      rows = rows
          .where(
            (T row) => searchHaystack(<String?>[
              for (final column in wanted) _valueOf(column, row)?.toString(),
            ]).contains(needle),
          )
          .toList();
    }

    final sort = _currentSort;

    if (_doesSort && sort != null) {
      final column = widget.columns
          .where((PlDataTableColumn<T> one) => one.key == sort.key)
          .firstOrNull;

      if (column != null) {
        final direction = sort.direction == PlassSortDirection.asc ? 1 : -1;

        // A copy, because sorting the caller's list in place would reorder the
        // rows they still hold a reference to.
        rows = List<T>.of(rows)
          ..sort((T a, T b) {
            // The comparator is asked first and the direction applied to what
            // it said, so a caller's own ordering reverses the way the built-in
            // one does rather than needing to know which way round it is asked.
            final answer = column.compare != null
                ? column.compare!(a, b)
                : compareValues(_valueOf(column, a), _valueOf(column, b));

            return answer * direction;
          });
      }
    }

    _ordered = rows;

    if (widget.paging != PlDataTablePaging.pages || !_doesPage) {
      return rows;
    }

    final (int start, int end) = pageBounds(
      rows.length,
      _currentPage(rows.length),
      widget.pageSize,
    );

    return rows.sublist(start, end);
  }

  /// Every row the reader could reach, before the page was cut out of it. Set
  /// by [_shown], which is the only thing that knows it.
  List<T> _ordered = <T>[];

  int _total(int ordered) => _doesPage ? ordered : (widget.rowCount ?? ordered);

  int _pageCount(int ordered) => (_total(ordered) / widget.pageSize).ceil().clamp(1, 1 << 30);

  int _currentPage(int ordered) => (widget.page ?? _page).clamp(1, _pageCount(ordered));

  void _goSort(String key) {
    final next = nextSort(_currentSort, key);

    if (widget.sort == null) {
      setState(() => _sort = next);
    }

    // Back to the first page: a reader who re-sorted is looking at a different
    // set of rows, and page nine of it is not where they were.
    _goPage(1);
    widget.onSortChanged?.call(next);
  }

  void _goSearch(String next) {
    if (widget.search == null) {
      setState(() {});
    }

    _goPage(1);
    widget.onSearchChanged?.call(next);
  }

  void _goPage(int next) {
    if (widget.page == null && next != _page) {
      setState(() => _page = next);
    }

    if (next != (widget.page ?? _page)) {
      widget.onPageChanged?.call(next);
    }
  }

  void _goSelected(List<Object> next) {
    if (widget.selected == null) {
      setState(() => _selected = next);
    }

    final wanted = next.toSet();
    final rows = <T>[
      for (var index = 0; index < widget.rows.length; index += 1)
        if (wanted.contains(_keyOf(widget.rows[index], index))) widget.rows[index],
    ];

    widget.onSelectedChanged?.call(next, rows);
  }

  bool _selectable(T row, int index) =>
      _ticks && (widget.isRowSelectable?.call(row, index) ?? true);

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final labels = PlassTheme.labelsOf(context);
    final size = _size;
    final color = _color;
    final density = _density;
    final family = tokens.family(color);
    final text = controlTextLeading[size]!;

    final shown = _shown;
    final ordered = _ordered;
    final selected = _currentSelected;

    final shownKeys = <Object>[
      for (var index = 0; index < shown.length; index += 1) _keyOf(shown[index], index),
    ];
    final selectableHere = <Object>[
      for (var index = 0; index < shown.length; index += 1)
        if (_selectable(shown[index], index)) shownKeys[index],
    ];
    final tickedHere = shownKeys.where(selected.contains).toList();
    final allTicked = selectableHere.isNotEmpty && tickedHere.length == selectableHere.length;

    void toggleAll() {
      final rest = selected.where((Object one) => !selectableHere.contains(one)).toList();

      _goSelected(allTicked ? rest : <Object>[...rest, ...selectableHere]);
    }

    void toggleRow(Object rowKey) {
      if (widget.selection == PlDataTableSelection.single) {
        _goSelected(selected.contains(rowKey) ? <Object>[] : <Object>[rowKey]);
        _anchor = rowKey;

        return;
      }

      // A shift-click extends from the last row that was pressed to this one,
      // in the order the rows are *currently* in — which is what a reader
      // dragging down a sorted page means by "these".
      final range = HardwareKeyboard.instance.isShiftPressed;

      if (range && _anchor != null && _anchor != rowKey) {
        final between = keysBetween(
          shownKeys,
          _anchor as Object,
          rowKey,
        ).where(selectableHere.contains).toList();

        _goSelected(<Object>[
          ...selected.where((Object one) => !between.contains(one)),
          ...between,
        ]);

        return;
      }

      _anchor = rowKey;
      _goSelected(
        selected.contains(rowKey)
            ? selected.where((Object one) => one != rowKey).toList()
            : <Object>[...selected, rowKey],
      );
    }

    final rowsDrawn = widget.loading
        ? (widget.paging == PlDataTablePaging.pages ? widget.pageSize : 5)
        : shown.length;

    final columns = <PlassGridColumn>[
      if (_ticks)
        PlassGridColumn(
          // Measured rather than fixed, and it has to be: the box is a
          // different size on every rung of the ladder and sits inside the
          // grid's own horizontal padding, so any number written here would be
          // right at one size and clip the tick at another. No flex keeps the
          // column out of the share-out of whatever the sheet has left over —
          // a tick column that grew with the table would be a column of ticks
          // floating in the middle of a lot of nothing.
          flex: null,
          header: widget.selection == PlDataTableSelection.multiple
              ? PlCheckbox(
                  size: size,
                  color: color,
                  value: allTicked,
                  // Neither ticked nor unticked: some of this page is. The box
                  // has to say so, because a half-filled page under a plain
                  // unticked box reads as "nothing here is chosen".
                  indeterminate: tickedHere.isNotEmpty && !allTicked,
                  onChanged: selectableHere.isEmpty ? null : (bool _) => toggleAll(),
                  semanticLabel: widget.selectAllLabel ?? labels.selectAll,
                )
              // A single-selection table has a tick column and nothing to put at
              // the top of it.
              : null,
          cell: (int index) {
            if (widget.loading) {
              return PlSkeleton(size: size, color: color, shape: PlSkeletonShape.rect, width: 16);
            }

            final rowKey = shownKeys[index];

            return PlCheckbox(
              size: size,
              color: color,
              value: selected.contains(rowKey),
              onChanged: _selectable(shown[index], index) ? (bool _) => toggleRow(rowKey) : null,
              semanticLabel: widget.selectRowLabel ?? labels.selectRow,
            );
          },
        ),
      for (final column in widget.columns)
        PlassGridColumn(
          width: column.width,
          flex: column.flex,
          align: column.align,
          header: column.sortable
              ? _SortableHeader(
                  direction: _currentSort?.key == column.key ? _currentSort!.direction : null,
                  onPressed: () => _goSort(column.key),
                  labels: labels,
                  child: column.header ?? const SizedBox.shrink(),
                )
              : column.header,
          cell: (int index) => widget.loading
              ? PlSkeleton(size: size, color: color)
              : column.cell(shown[index], index),
        ),
    ];

    final grid = PlassGrid(
      columns: columns,
      rowCount: rowsDrawn,
      size: size,
      color: color,
      density: density,
      rowKey: widget.loading ? null : (int index) => ValueKey<Object>(shownKeys[index]),
      rowTint: (int index) {
        if (!widget.loading && index < shownKeys.length && selected.contains(shownKeys[index])) {
          return family.soft;
        }

        return widget.striped && index.isOdd ? tokens.stripe : null;
      },
      empty: widget.empty ?? Text(labels.empty),
      hoverable: widget.hoverable,
      onRowPressed: widget.onRowPressed == null || widget.loading
          ? null
          : (int index) => widget.onRowPressed!(shown[index], index),
      stickyHeader: widget.stickyHeader,
      maxHeight: widget.maxHeight,
      semanticLabel: widget.semanticLabel,
    );

    final total = _total(ordered.length);
    final pageCount = _pageCount(ordered.length);
    final hasFooter =
        (widget.paging == PlDataTablePaging.pages && pageCount > 1) || widget.footer != null;

    return PlassSurfaceBox(
      surface: sheetSurface(tokens, variant: widget.variant, elevation: widget.elevation),
      borderRadius: BorderRadius.circular(PlassTokens.radius[size]!),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: tokens.fg, fontSize: text.size, height: text.height),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // The grid gives way when there is a height to give way *to*. A
            // `Flexible` in a column with nothing bounding its height is not a
            // layout, it is an assertion.
            final bool bounded = constraints.hasBoundedHeight;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (widget.caption != null)
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
                      child: widget.caption!,
                    ),
                  ),
                if (widget.searchable || widget.toolbar != null)
                  PlassTableBand(
                    size: size,
                    density: density,
                    child: Row(
                      spacing: gap[size]!,
                      children: <Widget>[
                        if (widget.searchable)
                          Expanded(
                            child: PlTextField(
                              size: size,
                              color: color,
                              density: density,
                              controller: _search,
                              onChanged: _goSearch,
                              placeholder: widget.searchPlaceholder ?? labels.search,
                              semanticLabel: widget.searchLabel ?? labels.search,
                            ),
                          )
                        else
                          const Spacer(),
                        ?widget.toolbar,
                      ],
                    ),
                  ),
                if (bounded) Flexible(child: grid) else grid,
                if (hasFooter)
                  PlassTableBand(
                    size: size,
                    density: density,
                    top: true,
                    child: Row(
                      spacing: gap[size]!,
                      children: <Widget>[
                        DefaultTextStyle.merge(
                          style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!),
                          child: widget.footer ?? Text('${shown.length} / $total'),
                        ),
                        const Spacer(),
                        if (widget.paging == PlDataTablePaging.pages)
                          PlPagination(
                            size: size,
                            color: color,
                            density: density,
                            count: pageCount,
                            page: _currentPage(ordered.length),
                            onPageChanged: _goPage,
                          ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A heading that can be pressed, with the mark that says which way it runs.
///
/// The mark is drawn for every sortable column rather than only for the sorted
/// one, because a heading that becomes pressable when the pointer arrives is a
/// heading nobody presses. The unsorted state is faint and the sorted one is
/// not, which is a change of weight rather than an appearance.
class _SortableHeader extends StatelessWidget {
  const _SortableHeader({
    required this.child,
    required this.direction,
    required this.onPressed,
    required this.labels,
  });

  final Widget child;
  final PlassSortDirection? direction;
  final VoidCallback onPressed;
  final PlassLabels labels;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      // Said out loud, where the React build sets `aria-sort` and every screen
      // reader speaks it in the reader's own language. Flutter's semantics have
      // no sort direction, so the heading has to carry the word itself.
      value: switch (direction) {
        null => null,
        PlassSortDirection.asc => labels.sortedAscending,
        PlassSortDirection.desc => labels.sortedDescending,
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: <Widget>[
              Flexible(child: child),
              Opacity(
                opacity: direction == null ? 0.3 : 1,
                child: PlassGlyph(
                  PlassGlyphShape.chevron,
                  size: 12,
                  quarterTurns: direction == PlassSortDirection.asc ? 2 : 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
