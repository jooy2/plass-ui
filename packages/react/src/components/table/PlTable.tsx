import * as React from 'react';
import {
  controlTextLeadingClasses,
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
import type { PlassAlign, PlassElevation, PlassStyleProps } from '../../types.js';

/** Which edge the text in a column lines up against. */
export type PlTableAlign = PlassAlign;

/**
 * A column: its heading, its default width, and how to get a cell out of a row.
 *
 * This is the whole reason a table takes data rather than markup. A `<td>`
 * written out per row can silently disagree with the `<th>` above it about how
 * many there are or what order they come in; a column list cannot.
 */
export interface PlTableColumn<Row> {
  /**
   * Identifies the column, and — unless `render` says otherwise — names the
   * property to read off each row.
   */
  key: string;
  /** The heading. Defaults to the `key`, which is usually not what you want. */
  header?: React.ReactNode;
  /**
   * The column's default width. A number is pixels; a string is any CSS length
   * (`'30%'`, `'12rem'`).
   *
   * "Default" is meant: the table still balances its columns to fill the sheet,
   * so this is a starting proportion rather than a guarantee.
   */
  width?: number | string;
  /**
   * Text alignment. Numbers usually want `end` so their digits line up in a
   * column; everything else wants `start`.
   * @default 'start'
   */
  align?: PlTableAlign;
  /**
   * Renders the cell. Without it the cell is `row[key]` rendered as-is, which
   * covers strings and numbers and nothing else.
   */
  render?: (row: Row, index: number) => React.ReactNode;
}

export interface PlTableProps<Row>
  extends PlassStyleProps, Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /**
   * Drop shadow depth. `0` is the default — a table is a grid set into the page
   * rather than a panel floating over it.
   * @default 0
   */
  elevation?: PlassElevation;
  /** The columns, in the order they appear. */
  columns: readonly PlTableColumn<Row>[];
  /** The rows. */
  rows: readonly Row[];
  /**
   * A stable key per row. Defaults to the row's index, which is fine for a
   * static table and wrong for one that sorts or filters.
   */
  getRowKey?: (row: Row, index: number) => React.Key;
  /** Shown above the grid, and read out as the table's accessible name. */
  caption?: React.ReactNode;
  /**
   * What to show instead of rows when `rows` is empty.
   * @default 'No data'
   */
  empty?: React.ReactNode;
  /**
   * Tints every other row. Useful on a wide table where the eye has to track
   * across; noise on a narrow one.
   * @default false
   */
  striped?: boolean;
  /** Lights the row under the pointer. @default false */
  hoverable?: boolean;
  /**
   * Pins the header while the rows scroll under it.
   *
   * It needs something to scroll *in*: a `position: sticky` header in a box
   * that is as tall as its content has nowhere to stick, so this does nothing
   * on its own. `maxHeight` is the usual answer and the two are made for each
   * other; a table inside a pane that already caps its own height works just as
   * well.
   * @default false
   */
  stickyHeader?: boolean;
  /**
   * A hard cap on the grid's height. A number is pixels; a string is any CSS
   * length (`'24rem'`, `'60vh'`).
   *
   * Past it the rows scroll inside the sheet rather than the page growing, and
   * the sheet keeps the size the layout around it was drawn for. It is the
   * other half of `stickyHeader`: capped without pinning, the column names
   * scroll away and the rest of the table is a grid of unlabelled numbers.
   *
   * The **grid** and not the sheet: a `caption` sits above the rows and outside
   * what is capped, because a caption that scrolled away would take the table's
   * accessible name with it.
   */
  maxHeight?: number | string;
  /** Makes rows activatable. Also turns on the hover treatment. */
  onRowClick?: (row: Row, index: number) => void;
}

/**
 * A grid of data on a sheet of glass.
 *
 * The sheet is the ordinary Plass container — `variant`, `size`, `color`,
 * `density` and `elevation` all mean what they mean everywhere else, and it is
 * never dyed. What the table adds is the part that is genuinely tabular: the
 * columns, the rows, and the fact that the two cannot drift apart.
 *
 * Not a `forwardRef`, because it is generic: a component wrapped in
 * `React.forwardRef` loses its type parameter, and `Row` is the whole point of
 * the API. `ref` is not offered rather than being offered with `Row` widened to
 * `any`.
 */
export function PlTable<Row>({
  variant = 'glass',
  size = 'md',
  color = 'primary',
  density = 'default',
  elevation = 0,
  columns,
  rows,
  getRowKey,
  caption,
  empty = 'No data',
  striped = false,
  hoverable = false,
  stickyHeader = false,
  maxHeight,
  onRowClick,
  className,
  style,
  ...props
}: PlTableProps<Row>) {
  const padX = paddingXValues[density][size];
  const padY = cellPaddingYValues[density][size];
  const clickable = Boolean(onRowClick);
  const lit = hoverable || clickable;
  const capped = maxHeight !== undefined;

  // `border: 0` first, then the one edge this cell actually draws. Written as
  // the longhand rather than a `border` shorthand carrying `0` so the rule and
  // the reset cannot be reordered into each other.
  const cellStyle: React.CSSProperties = {
    padding: `${padY} ${padX}`,
    border: 0,
    background: 'none'
  };

  const headCellStyle: React.CSSProperties = {
    ...cellStyle,
    // The rule under the column names, and the one place the table draws an
    // edge as a shadow rather than as a border. `border-collapse: collapse`
    // hands a cell's borders to the *table's* border grid, and that grid does
    // not travel with a `position: sticky` cell — so a pinned header keeps its
    // fill and leaves its underline behind at the top of the scroll. An inset
    // shadow belongs to the cell's own box and goes where the cell goes.
    ...(stickyHeader
      ? { boxShadow: `inset 0 -1px 0 var(--plass-border)` }
      : { borderBottom: headRule }),
    // No band behind the column names.
    //
    // The header used to be `--plass-glass-press`, one step up the glass ladder
    // — and one step up a ladder whose rungs are 62%, 76% and 88% white is, on
    // a light page, a white bar. A filled strip across the top of a grid is the
    // single fastest way to make data look like chrome, and it was doing that
    // while the rules between the rows underneath were invisible: all of the
    // table's weight in the one place that needed none of it. Muted, semibold
    // names over a firmer rule say "these are the columns" with nothing filled
    // in at all.
    //
    // A *pinned* header is the exception, and it is not decoration: rows pass
    // directly underneath it, and a translucent fill lets them through. Two
    // stacked opaque layers stop the light — the sheet's own densest glass over
    // the page's surface colour — which is the same trick a pinned first
    // column needs for the same reason.
    ...(stickyHeader
      ? {
          background:
            'linear-gradient(var(--plass-glass-press), var(--plass-glass-press)),' +
            ' linear-gradient(var(--plass-surface), var(--plass-surface))'
        }
      : null)
  };

  /** The rule above a row — every row but the first, which has the header's. */
  const bodyCellStyle = (index: number): React.CSSProperties =>
    index === 0 ? cellStyle : { ...cellStyle, borderTop: rowRule };

  return (
    <div
      className={[
        // The sheet clips, and the box inside it scrolls. Two elements rather
        // than one because a `caption` has to stay out of what scrolls: a
        // pinned header over rows that pass under it is the point of
        // `stickyHeader`, and a title that slid away above it would take the
        // table's name off the screen with it.
        'overflow-hidden',
        radiusClasses[size],
        sheetRestClasses[variant],
        className ?? ''
      ]
        .filter(Boolean)
        .join(' ')}
      style={{ ...surfaceSlots(color, elevation), ...style }}
      {...props}
    >
      {/*
        The title is drawn here and *named* down in the `<table>`, and the split
        is the whole reason this component has no hook in it.

        A `<caption>` is the semantically obvious element and it is in the wrong
        box: it belongs to the `<table>`, so it lives inside whatever scrolls
        the table — which is the one place a title must not be. So the visible
        one stays out here, where the Flutter build draws it too, and is marked
        `aria-hidden` because a screen reader gets the same words from the real
        `<caption>` instead.

        That used to be an `aria-labelledby`, which needed an id, which needed
        `React.useId` — and a component that calls a hook is a client component,
        which cost this one the ability to be rendered by a server component at
        all. Every column here takes a `render` callback, and a function cannot
        cross that boundary: a table on a server-rendered page could not use its
        own API. A native caption names the table with no id to generate.
      */}
      {caption ? (
        <div
          aria-hidden="true"
          className={`${metaTextClasses[size]} font-semibold text-(--plass-muted-fg)`}
          style={{ ...cellStyle, borderBottom: rowRule, textAlign: 'start' }}
        >
          {caption}
        </div>
      ) : null}

      <div
        className={[
          'overflow-x-auto',
          // Only when there is a cap to scroll against. A box that is as tall
          // as its content has nothing to scroll, and `overscroll-contain` on
          // one of those would swallow the page's own scroll at its edges.
          capped ? 'overflow-y-auto overscroll-contain' : ''
        ]
          .filter(Boolean)
          .join(' ')}
        style={capped ? { maxHeight } : undefined}
      >
        <table
          className={`text-start ${controlTextLeadingClasses[size]} text-(--plass-fg)`}
          style={tableStyle}
        >
          {/* The accessible name, and nothing a sighted reader meets: the same
              words are already drawn above the sheet. */}
          {caption ? <caption className={srOnlyClasses}>{caption}</caption> : null}
          {/* Widths belong on a `<col>`, not on the first row's cells: a width set
            on a `<th>` is a width the browser is free to renegotiate against
            every other row, and only the column element states it once. */}
          <colgroup>
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
              {columns.map((column) => (
                <th
                  key={column.key}
                  scope="col"
                  className={[
                    'font-semibold whitespace-nowrap text-(--plass-muted-fg)',
                    stickyHeader ? 'sticky top-0 z-10' : ''
                  ]
                    .filter(Boolean)
                    .join(' ')}
                  style={{ ...headCellStyle, textAlign: column.align ?? 'start' }}
                >
                  {column.header ?? column.key}
                </th>
              ))}
            </tr>
          </thead>

          <tbody>
            {rows.length === 0 ? (
              <tr className={rowClasses}>
                <td
                  colSpan={columns.length}
                  className="text-(--plass-muted-fg)"
                  style={{ ...cellStyle, padding: `2rem ${padX}`, textAlign: 'center' }}
                >
                  {empty}
                </td>
              </tr>
            ) : (
              rows.map((row, index) => (
                <tr
                  key={getRowKey ? getRowKey(row, index) : index}
                  className={[
                    rowClasses,
                    striped && index % 2 === 1 ? '[--p-row:var(--plass-stripe)]' : '',
                    lit ? 'hover:[--p-row:var(--p-soft)]' : '',
                    clickable ? clickableRowClasses : ''
                  ]
                    .filter(Boolean)
                    .join(' ')}
                  style={{ backgroundColor: 'var(--p-row)' }}
                  tabIndex={clickable ? 0 : undefined}
                  onClick={onRowClick ? () => onRowClick(row, index) : undefined}
                  onKeyDown={
                    onRowClick
                      ? (event) => {
                          // Only the row's own keys. A cell can hold a link or a
                          // button, and those have an Enter of their own — running
                          // both would open the row and follow the link at once.
                          if (event.target !== event.currentTarget) {
                            return;
                          }

                          if (event.key !== 'Enter' && event.key !== ' ') {
                            return;
                          }

                          // Space scrolls the page otherwise, which is the one
                          // thing a reader pressing it on a row did not ask for.
                          event.preventDefault();
                          onRowClick(row, index);
                        }
                      : undefined
                  }
                >
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
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
