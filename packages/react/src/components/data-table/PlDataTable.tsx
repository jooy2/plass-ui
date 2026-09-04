'use client';

import * as React from 'react';
import { PlCheckbox } from '../checkbox/index.js';
import { PlPagination } from '../pagination/index.js';
import { PlSkeleton } from '../skeleton/index.js';
import { PlTextField } from '../text-field/index.js';
import {
  compareValues,
  keysBetween,
  nextSort,
  pageBounds,
  type PlassSort,
  type PlassSortDirection
} from '../../internal/data-table.js';
import { useDefaults } from '../../internal/defaults.js';
import { ChevronIcon } from '../../internal/icons.js';
import { useLabels } from '../../internal/labels.js';
import { searchHaystack, searchText } from '../../internal/search.js';
import {
  controlTextLeadingClasses,
  cx,
  focusRingInsetClasses,
  gapClasses,
  hasContent,
  metaTextClasses,
  paddingXValues,
  radiusClasses,
  sheetRestClasses,
  srOnlyClasses,
  surfaceSlots
} from '../../internal/styles.js';
import {
  cellPaddingYValues,
  clickableRowClasses,
  headRule,
  rowClasses,
  rowRule,
  tableStyle
} from '../../internal/table.js';
import type { PlTableAlign } from '../table/index.js';
import type { PlassElevation, PlassStyleProps } from '../../types.js';

/** Which way a column runs when it is sorted. */
export type PlDataTableSortDirection = PlassSortDirection;

/** The column being sorted on, and its direction. */
export type PlDataTableSort = PlassSort;

/**
 * How many rows may be ticked at once.
 *
 * `none` is the default. A table that draws a tick column it does nothing with
 * has promised something it does not do.
 */
export type PlDataTableSelection = 'none' | 'single' | 'multiple';

/**
 * How the rows are handed out.
 *
 * - `scroll` — all of them, in one body. Pair it with `maxHeight` and the rows
 *   scroll inside the sheet instead of the page growing.
 * - `pages` — a slice at a time, with a pager in the footer. Right when a row's
 *   position in the whole set is information, and the only honest option when
 *   the rows are fetched a page at a time.
 */
export type PlDataTablePaging = 'scroll' | 'pages';

/**
 * The three things the table does to the rows, and the ones an application can
 * take back.
 *
 * Naming a stage in `manual` means the rows arriving in `rows` have already had
 * it done to them — by a server, usually — so the table reports the reader's
 * intent and draws what it is given rather than doing the work twice.
 */
export type PlDataTableStage = 'sort' | 'search' | 'pages';

/**
 * A column: its heading, how to get a value out of a row, and how to draw one.
 *
 * The split between `value` and `render` is the shape of this type. `render`
 * decides what a reader sees; `value` decides what the sort and the search see.
 * Most columns need neither — the cell is `row[key]`, and that is what is
 * compared and matched. A column that draws a `PlChip` needs `render`, and it
 * needs `value` as well the moment it is sortable, because an element has no
 * order and no text a search can look inside.
 */
export interface PlDataTableColumn<Row> {
  /**
   * Identifies the column — to `sort`, and unless `value` or `render` says
   * otherwise, it names the property to read off each row.
   */
  key: string;
  /** The heading. Defaults to the `key`, which is usually not what you want. */
  header?: React.ReactNode;
  /**
   * The column's default width. A number is pixels; a string is any CSS length.
   *
   * "Default" is meant: the table still balances its columns to fill the sheet.
   */
  width?: number | string;
  /**
   * Text alignment. Numbers usually want `end` so their digits line up.
   * @default 'start'
   */
  align?: PlTableAlign;
  /** Renders the cell. Without it the cell is `row[key]` rendered as-is. */
  render?: (row: Row, index: number) => React.ReactNode;
  /**
   * What this column *is*, for the sort and the search.
   *
   * Defaults to `row[key]`. Give it whenever the cell is drawn rather than
   * printed: a status column showing a chip sorts on the status, and a name
   * column showing an avatar beside the name searches on the name.
   */
  value?: (row: Row) => unknown;
  /**
   * Puts the heading in the sort rotation: ascending, descending, then back to
   * the order the rows arrived in.
   * @default false
   */
  sortable?: boolean;
  /** Orders two rows against each other, when `compareValues` is not enough. */
  compare?: (a: Row, b: Row) => number;
  /**
   * Keeps this column out of the search. Right for a column of identifiers a
   * reader never types, where a match is a row they cannot see the reason for.
   * @default false
   */
  unsearchable?: boolean;
}

export interface PlDataTableProps<Row>
  extends PlassStyleProps, Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'onSelect'> {
  /**
   * Drop shadow depth. `0` is the default — a table is a grid set into the page
   * rather than a panel floating over it.
   * @default 0
   */
  elevation?: PlassElevation;
  /** The columns, in the order they appear. */
  columns: readonly PlDataTableColumn<Row>[];
  /** The rows, in the order they arrived in. */
  rows: readonly Row[];
  /**
   * A stable key per row, and the one prop worth setting before any other.
   *
   * It defaults to the row's index, which is wrong for every table this
   * component is for: sorting moves a row and its index stays behind, so a
   * selection made before the sort belongs to different rows after it.
   */
  getRowKey?: (row: Row, index: number) => React.Key;
  /** Shown above the grid, and read out as the table's accessible name. */
  caption?: React.ReactNode;
  /** What to show instead of rows when there are none left to show. */
  empty?: React.ReactNode;
  /** Tints every other row. @default false */
  striped?: boolean;
  /** Lights the row under the pointer. @default false */
  hoverable?: boolean;
  /** Pins the header while the rows scroll under it. @default true */
  stickyHeader?: boolean;
  /** A hard cap on the grid's height. A number is pixels; a string is a CSS length. */
  maxHeight?: number | string;
  /** Makes rows activatable. Also turns on the hover treatment. */
  onRowClick?: (row: Row, index: number) => void;

  /** The sorted column and its direction. Pass it to control the sort. */
  sort?: PlDataTableSort | null;
  /** Where the sort starts when the table keeps it itself. */
  defaultSort?: PlDataTableSort | null;
  /** Called with the sort a heading press asks for, `null` for the third press. */
  onSortChange?: (sort: PlDataTableSort | null) => void;

  /** Draws a field above the grid that narrows the rows to what was typed. */
  searchable?: boolean;
  /** The query. Pass it to control the field. */
  search?: string;
  /** Where the query starts when the table keeps it itself. */
  defaultSearch?: string;
  /** Called with what the reader typed. */
  onSearchChange?: (search: string) => void;
  /** The field's placeholder. Defaults to the locale's word for searching. */
  searchPlaceholder?: string;

  /** How many rows may be ticked at once. @default 'none' */
  selection?: PlDataTableSelection;
  /** The ticked rows, as their keys. Pass it to control the selection. */
  selected?: readonly React.Key[];
  /** Where the selection starts when the table keeps it itself. */
  defaultSelected?: readonly React.Key[];
  /** Called with the keys of every ticked row. */
  onSelectedChange?: (selected: React.Key[], rows: Row[]) => void;
  /** Keeps a row out of the selection — a total line, a row already spent. */
  isRowSelectable?: (row: Row, index: number) => boolean;

  /** How the rows are handed out. @default 'scroll' */
  paging?: PlDataTablePaging;
  /** How many rows a page holds. @default 10 */
  pageSize?: number;
  /** The page being read, counted from `1`. Pass it to control the pager. */
  page?: number;
  /** Where the pager starts when the table keeps it itself. */
  defaultPage?: number;
  /** Called with the page a pager press asks for. */
  onPageChange?: (page: number) => void;
  /**
   * How many rows there are in total, when the table is only ever handed one
   * page of them. Required for `manual` paging and ignored without it.
   */
  rowCount?: number;

  /** The stages an application has already done to `rows` itself. */
  manual?: readonly PlDataTableStage[];

  /** Draws bars in place of the rows and marks the grid busy. @default false */
  loading?: boolean;
  /** Drawn in the toolbar, at the end. A filter, a button, a count of its own. */
  toolbar?: React.ReactNode;
  /** Drawn in the footer, at the start, in place of the row count. */
  footer?: React.ReactNode;
}

/** The width of the tick column, which is a control rather than data. */
const tickWidths: Record<string, string> = {
  xs: '2rem',
  sm: '2.25rem',
  md: '2.75rem',
  lg: '3rem',
  xl: '3.5rem'
};

/**
 * A heading that can be pressed, and the only place this component draws a
 * control that is not one of the library's own.
 *
 * A `PlButton` here would be a control on a control: it brings a background, a
 * radius and a height of its own into a cell whose whole job is to sit flush
 * against the rule under it. So the heading is a bare `<button>` wearing the
 * heading's own type, and it takes the inset focus ring for `clickableRow`'s
 * reason — the sheet clips at its rounded corner, and a ring drawn outside the
 * first header cell would have its top sliced off.
 */
const sortButtonClasses = /* @__PURE__ */ cx(
  'inline-flex items-center gap-1 [outline:none]',
  'font-semibold whitespace-nowrap text-inherit',
  '[background:none] [border:0] [padding:0] [margin:0] cursor-pointer',
  'hover:text-(--plass-fg) [transition:color_var(--plass-duration)_var(--plass-ease)]',
  focusRingInsetClasses
);

/**
 * The mark beside a sorted heading.
 *
 * It is drawn for every sortable column rather than only for the sorted one,
 * because a heading that becomes pressable when the pointer arrives is a
 * heading nobody presses. The unsorted state is faint and the sorted one is
 * not, which is a change of weight rather than an appearance.
 */
function SortMark({ direction }: { direction: PlDataTableSortDirection | null }) {
  return (
    <span
      aria-hidden="true"
      className={cx(
        '[&_svg]:size-[1em] [&_svg]:shrink-0',
        '[transition:opacity_var(--plass-duration)_var(--plass-ease),transform_var(--plass-duration)_var(--plass-ease)]',
        direction === null ? 'opacity-30' : 'opacity-100',
        direction === 'asc' ? 'rotate-180' : ''
      )}
    >
      <ChevronIcon />
    </span>
  );
}

/**
 * A table that owns its rows: it sorts them, narrows them to what was typed,
 * hands them out a page at a time and remembers which of them are ticked.
 *
 * `PlTable` is the one to reach for when the rows are already in the order they
 * belong in — it renders on a server, which this cannot, because every one of
 * these is a decision that has to be remembered between renders.
 *
 * ```tsx
 * <PlDataTable
 *   columns={[
 *     { key: 'name', header: 'Name', sortable: true },
 *     { key: 'amount', header: 'Amount', align: 'end', sortable: true }
 *   ]}
 *   rows={invoices}
 *   getRowKey={(row) => row.id}
 *   searchable
 *   selection="multiple"
 *   paging="pages"
 * />
 * ```
 *
 * Every one of sort, search, selection and page is **controllable and
 * uncontrolled by default**, so the ordinary table is the markup above and a
 * table backed by a server is the same markup with `manual` and the four
 * handlers. Nothing changes shape in between.
 *
 * Not a `forwardRef`, for `PlTable`'s reason: a component wrapped in
 * `React.forwardRef` loses its type parameter, and `Row` is the whole point.
 */
export function PlDataTable<Row>({
  variant = 'glass',
  size: sizeProp,
  color: colorProp,
  density: densityProp,
  elevation = 0,
  columns,
  rows,
  getRowKey,
  caption,
  empty: emptyProp,
  striped = false,
  hoverable = false,
  stickyHeader = true,
  maxHeight,
  onRowClick,
  sort: sortProp,
  defaultSort = null,
  onSortChange,
  searchable = false,
  search: searchProp,
  defaultSearch = '',
  onSearchChange,
  searchPlaceholder,
  selection = 'none',
  selected: selectedProp,
  defaultSelected,
  onSelectedChange,
  isRowSelectable,
  paging = 'scroll',
  pageSize = 10,
  page: pageProp,
  defaultPage = 1,
  onPageChange,
  rowCount,
  manual,
  loading = false,
  toolbar,
  footer,
  className,
  style,
  ...props
}: PlDataTableProps<Row>) {
  const defaults = useDefaults();
  const labels = useLabels();
  const size = sizeProp ?? defaults.size ?? 'md';
  const color = colorProp ?? defaults.color ?? 'primary';
  const density = densityProp ?? defaults.density ?? 'default';
  const empty = emptyProp ?? labels.empty;

  const [uncontrolledSort, setUncontrolledSort] = React.useState(defaultSort);
  const [uncontrolledSearch, setUncontrolledSearch] = React.useState(defaultSearch);
  const [uncontrolledSelected, setUncontrolledSelected] = React.useState<readonly React.Key[]>(
    defaultSelected ?? []
  );
  const [uncontrolledPage, setUncontrolledPage] = React.useState(defaultPage);

  const sort = sortProp === undefined ? uncontrolledSort : sortProp;
  const search = searchProp ?? uncontrolledSearch;
  const selected = selectedProp ?? uncontrolledSelected;

  const doesSort = !manual?.includes('sort');
  const doesSearch = !manual?.includes('search');
  const doesPage = !manual?.includes('pages');

  const key = React.useCallback(
    (row: Row, index: number) => (getRowKey ? getRowKey(row, index) : index),
    [getRowKey]
  );

  /** What a column *is*, as the sort and the search see it. */
  const valueOf = React.useCallback(
    (column: PlDataTableColumn<Row>, row: Row) =>
      column.value ? column.value(row) : (row as Record<string, unknown>)[column.key],
    []
  );

  // The query is folded once here rather than once per row per column, which is
  // the difference between a `normalize` call and several thousand of them on
  // every keystroke. See `internal/search.ts`.
  const needle = searchText(search);

  const found = React.useMemo(() => {
    if (!doesSearch || needle === '') {
      return rows;
    }

    const wanted = columns.filter((column) => !column.unsearchable);

    return rows.filter((row) =>
      searchHaystack(wanted.map((column) => valueOf(column, row))).includes(needle)
    );
  }, [rows, columns, needle, doesSearch, valueOf]);

  const ordered = React.useMemo(() => {
    if (!doesSort || sort === null) {
      return found;
    }

    const column = columns.find((one) => one.key === sort.key);

    if (!column) {
      return found;
    }

    const direction = sort.direction === 'asc' ? 1 : -1;

    // A copy, because sorting the caller's array in place would reorder the
    // rows they still hold a reference to. `toSorted` is not reached for: this
    // package supports one browser generation further back than it.
    return [...found].sort((a, b) => {
      // The comparator is asked first and the direction applied to whatever it
      // said, so a caller's own ordering reverses the way the built-in one does
      // rather than needing to know which way round it is being asked.
      const answer = column.compare
        ? column.compare(a, b)
        : compareValues(valueOf(column, a), valueOf(column, b));

      return answer * direction;
    });
  }, [found, columns, sort, doesSort, valueOf]);

  const total = doesPage ? ordered.length : (rowCount ?? ordered.length);
  const pageCount = Math.max(1, Math.ceil(total / pageSize));
  const page = Math.min(Math.max(pageProp ?? uncontrolledPage, 1), pageCount);

  const shown = React.useMemo(() => {
    if (paging !== 'pages' || !doesPage) {
      return ordered;
    }

    const [start, end] = pageBounds(ordered.length, page, pageSize);

    return ordered.slice(start, end);
  }, [ordered, paging, doesPage, page, pageSize]);

  const shownKeys = React.useMemo(() => shown.map(key), [shown, key]);

  /** The last row a tick was pressed on, so shift can measure a range from it. */
  const anchor = React.useRef<React.Key | null>(null);

  const goSort = (columnKey: string) => {
    const next = nextSort(sort, columnKey);

    if (sortProp === undefined) {
      setUncontrolledSort(next);
    }

    // Back to the first page: a reader who re-sorted is looking at a different
    // set of rows, and page nine of it is not where they were.
    goPage(1);
    onSortChange?.(next);
  };

  const goSearch = (next: string) => {
    if (searchProp === undefined) {
      setUncontrolledSearch(next);
    }

    goPage(1);
    onSearchChange?.(next);
  };

  function goPage(next: number) {
    if (pageProp === undefined) {
      setUncontrolledPage(next);
    }

    if (next !== page) {
      onPageChange?.(next);
    }
  }

  const selectable = (row: Row, index: number) =>
    selection !== 'none' && (isRowSelectable ? isRowSelectable(row, index) : true);

  const goSelected = (next: React.Key[]) => {
    if (selectedProp === undefined) {
      setUncontrolledSelected(next);
    }

    const wanted = new Set(next);

    onSelectedChange?.(
      next,
      // Out of every row the table has, not only the page on screen: a
      // selection that survives paging must hand back the rows it survived on.
      rows.filter((row, index) => wanted.has(key(row, index)))
    );
  };

  const tickedHere = shownKeys.filter((one) => selected.includes(one));
  const selectableHere = shown.filter(selectable).map(key);
  const allTicked = selectableHere.length > 0 && tickedHere.length === selectableHere.length;

  const toggleAll = () => {
    const rest = selected.filter((one) => !selectableHere.includes(one));

    goSelected(allTicked ? rest : [...rest, ...selectableHere]);
  };

  const toggleRow = (rowKey: React.Key, range: boolean) => {
    if (selection === 'single') {
      goSelected(selected.includes(rowKey) ? [] : [rowKey]);
      anchor.current = rowKey;

      return;
    }

    // A shift-click extends from the last row that was pressed to this one, in
    // the order the rows are *currently* in — which is what a reader dragging
    // down a sorted page means by "these".
    if (range && anchor.current !== null && anchor.current !== rowKey) {
      const between = keysBetween(shownKeys, anchor.current, rowKey).filter((one) =>
        selectableHere.includes(one)
      );

      goSelected([...selected.filter((one) => !between.includes(one)), ...between]);

      return;
    }

    anchor.current = rowKey;
    goSelected(
      selected.includes(rowKey) ? selected.filter((one) => one !== rowKey) : [...selected, rowKey]
    );
  };

  const padX = paddingXValues[density][size];
  const padY = cellPaddingYValues[density][size];
  const clickable = Boolean(onRowClick);
  const lit = hoverable || clickable;
  const capped = maxHeight !== undefined;
  const ticks = selection !== 'none';
  const span = columns.length + (ticks ? 1 : 0);

  // Every one of these is inline for the reason `internal/table.ts` gives: a
  // host stylesheet's `td { border: 1px solid }` outranks a Tailwind utility.
  const cellStyle: React.CSSProperties = {
    padding: `${padY} ${padX}`,
    border: 0,
    background: 'none'
  };

  const headCellStyle: React.CSSProperties = {
    ...cellStyle,
    ...(stickyHeader
      ? {
          boxShadow: 'inset 0 -1px 0 var(--plass-border)',
          background:
            'linear-gradient(var(--plass-glass-press), var(--plass-glass-press)),' +
            ' linear-gradient(var(--plass-surface), var(--plass-surface))'
        }
      : { borderBottom: headRule })
  };

  /**
   * The rule above a row — every row but the first, which has the header's.
   *
   * `borderTop` is always present rather than added for the rows that draw one.
   * The rows here are re-keyed by every sort, filter and page, so the same cell
   * goes from being the first row to being the third; React warns — rightly —
   * when a longhand is *removed* from an element whose shorthand is still set,
   * because which of the two wins then depends on the order they were applied
   * in. Stating `0` is the same rule as not stating one, and nothing is removed.
   */
  const bodyCellStyle = (index: number): React.CSSProperties => ({
    ...cellStyle,
    borderTop: index === 0 ? 0 : rowRule
  });

  const barStyle: React.CSSProperties = {
    padding: `${padY} ${padX}`,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: '0.75rem'
  };

  const hasToolbar = searchable || hasContent(toolbar);
  const hasFooter = (paging === 'pages' && pageCount > 1) || hasContent(footer);

  return (
    <div
      className={cx('overflow-hidden', radiusClasses[size], sheetRestClasses[variant], className)}
      style={{ ...surfaceSlots(color, elevation), ...style }}
      {...props}
    >
      {/* The title, drawn here and *named* down in the `<table>`. A `<caption>`
          belongs to the table, so it lives inside whatever scrolls it — which
          is the one place a title must not be when the header is pinned. */}
      {hasContent(caption) ? (
        <div
          aria-hidden="true"
          className={cx(metaTextClasses[size], 'font-semibold text-(--plass-muted-fg)')}
          style={{ ...cellStyle, borderBottom: rowRule, textAlign: 'start' }}
        >
          {caption}
        </div>
      ) : null}

      {hasToolbar ? (
        <div style={{ ...barStyle, borderBottom: rowRule }}>
          {searchable ? (
            <PlTextField
              size={size}
              color={color}
              density={density}
              value={search}
              onChange={(event) => goSearch(event.target.value)}
              placeholder={searchPlaceholder ?? labels.search}
              aria-label={labels.search}
              className="min-w-0 flex-1"
            />
          ) : (
            <span />
          )}
          {hasContent(toolbar) ? (
            <div className={cx('flex items-center', gapClasses[size])}>{toolbar}</div>
          ) : null}
        </div>
      ) : null}

      <div
        className={cx('overflow-x-auto', capped && 'overflow-y-auto overscroll-contain')}
        style={capped ? { maxHeight } : undefined}
      >
        <table
          className={cx('text-start', controlTextLeadingClasses[size], 'text-(--plass-fg)')}
          style={tableStyle}
          aria-busy={loading || undefined}
        >
          {hasContent(caption) ? <caption className={srOnlyClasses}>{caption}</caption> : null}

          <colgroup>
            {ticks ? <col style={{ width: tickWidths[size] }} /> : null}
            {columns.map((column) => (
              <col
                key={column.key}
                style={
                  column.width === undefined
                    ? undefined
                    : {
                        width: typeof column.width === 'number' ? `${column.width}px` : column.width
                      }
                }
              />
            ))}
          </colgroup>

          <thead>
            <tr>
              {ticks ? (
                <th
                  scope="col"
                  className={cx(stickyHeader && 'sticky top-0 z-10')}
                  style={headCellStyle}
                >
                  {selection === 'multiple' ? (
                    <PlCheckbox
                      size={size}
                      color={color}
                      checked={allTicked}
                      // Neither ticked nor unticked: some of this page is. The
                      // box has to say so, because a half-filled page under a
                      // plain unticked box reads as "nothing here is chosen".
                      indeterminate={tickedHere.length > 0 && !allTicked}
                      onCheckedChange={toggleAll}
                      disabled={selectableHere.length === 0}
                      aria-label={labels.selectAll}
                    />
                  ) : (
                    // A single-selection table has a tick column and nothing to
                    // put at the top of it. The header cell still has to exist,
                    // or every row is one cell wider than its heading row.
                    <span className={srOnlyClasses}>{labels.selectRow}</span>
                  )}
                </th>
              ) : null}

              {columns.map((column) => {
                const sorted = sort?.key === column.key ? sort.direction : null;

                return (
                  <th
                    key={column.key}
                    scope="col"
                    className={cx(
                      'font-semibold whitespace-nowrap text-(--plass-muted-fg)',
                      stickyHeader && 'sticky top-0 z-10'
                    )}
                    style={{ ...headCellStyle, textAlign: column.align ?? 'start' }}
                    // The sort is announced by the *heading*, which is what a
                    // screen reader reads when it enters a cell in this column.
                    // A state on the button inside would only be heard by a
                    // reader who happened to land on the button.
                    aria-sort={
                      column.sortable
                        ? sorted === 'asc'
                          ? 'ascending'
                          : sorted === 'desc'
                            ? 'descending'
                            : 'none'
                        : undefined
                    }
                  >
                    {column.sortable ? (
                      <button
                        type="button"
                        className={sortButtonClasses}
                        onClick={() => goSort(column.key)}
                      >
                        {column.header ?? column.key}
                        <SortMark direction={sorted} />
                      </button>
                    ) : (
                      (column.header ?? column.key)
                    )}
                  </th>
                );
              })}
            </tr>
          </thead>

          <tbody>
            {loading ? (
              // As many bars as a page holds, so the grid does not change height
              // when the rows arrive — the jump that makes a reader lose the row
              // they were about to press.
              Array.from({ length: paging === 'pages' ? pageSize : 5 }, (_, index) => (
                <tr key={index} className={rowClasses}>
                  {Array.from({ length: span }, (__, cell) => (
                    <td key={cell} style={bodyCellStyle(index)}>
                      <PlSkeleton size={size} color={color} />
                    </td>
                  ))}
                </tr>
              ))
            ) : shown.length === 0 ? (
              <tr className={rowClasses}>
                <td
                  colSpan={span}
                  className="text-(--plass-muted-fg)"
                  style={{ ...cellStyle, padding: `2rem ${padX}`, textAlign: 'center' }}
                >
                  {empty}
                </td>
              </tr>
            ) : (
              shown.map((row, index) => {
                const rowKey = key(row, index);
                const ticked = selected.includes(rowKey);
                const canTick = selectable(row, index);

                return (
                  <tr
                    key={rowKey}
                    // `aria-selected` and not a class alone: a row that is
                    // visibly tinted and silently unselected is a row a screen
                    // reader disagrees with the screen about.
                    aria-selected={ticks ? ticked : undefined}
                    className={cx(
                      rowClasses,
                      striped && index % 2 === 1 && '[--p-row:var(--plass-stripe)]',
                      ticked && '[--p-row:var(--p-soft)]',
                      lit && 'hover:[--p-row:var(--p-soft)]',
                      clickable && clickableRowClasses
                    )}
                    style={{ backgroundColor: 'var(--p-row)' }}
                    tabIndex={clickable ? 0 : undefined}
                    onClick={onRowClick ? () => onRowClick(row, index) : undefined}
                    onKeyDown={
                      onRowClick
                        ? (event) => {
                            // Only the row's own keys. A cell can hold a link or
                            // a tick, and those have an Enter of their own.
                            if (event.target !== event.currentTarget) {
                              return;
                            }

                            if (event.key !== 'Enter' && event.key !== ' ') {
                              return;
                            }

                            event.preventDefault();
                            onRowClick(row, index);
                          }
                        : undefined
                    }
                  >
                    {ticks ? (
                      <td style={bodyCellStyle(index)}>
                        <PlCheckbox
                          size={size}
                          color={color}
                          checked={ticked}
                          disabled={!canTick}
                          // The native event, for the one bit of it a range
                          // needs: whether shift was down. Base UI hands the
                          // details object rather than the event itself.
                          onCheckedChange={(_, details) =>
                            toggleRow(
                              rowKey,
                              Boolean((details.event as Partial<MouseEvent>).shiftKey)
                            )
                          }
                          // A press on the tick is a press on the tick. Without
                          // this it is also a press on the row, so a selectable
                          // table with `onRowClick` fires both at once.
                          onClick={(event) => event.stopPropagation()}
                          aria-label={labels.selectRow}
                        />
                      </td>
                    ) : null}

                    {columns.map((column) => (
                      <td
                        key={column.key}
                        style={{ ...bodyCellStyle(index), textAlign: column.align ?? 'start' }}
                      >
                        {column.render
                          ? column.render(row, index)
                          : ((row as Record<string, unknown>)[column.key] as React.ReactNode)}
                      </td>
                    ))}
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>

      {hasFooter ? (
        <div style={{ ...barStyle, borderTop: rowRule }}>
          <span className={cx(metaTextClasses[size], 'text-(--plass-muted-fg)')}>
            {hasContent(footer) ? footer : `${shown.length} / ${total}`}
          </span>
          {paging === 'pages' ? (
            <PlPagination
              size={size}
              color={color}
              density={density}
              count={pageCount}
              page={page}
              onPageChange={goPage}
            />
          ) : null}
        </div>
      ) : null}
    </div>
  );
}
