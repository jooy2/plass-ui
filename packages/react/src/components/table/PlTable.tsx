import * as React from 'react';
import {
  controlTextLeadingClasses,
  focusRingInsetClasses,
  metaTextClasses,
  paddingXValues,
  radiusClasses,
  sheetRestClasses,
  surfaceSlots
} from '../../internal/styles.js';
import type {
  PlassAlign,
  PlassDensity,
  PlassElevation,
  PlassSize,
  PlassStyleProps
} from '../../types.js';

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
   * Pins the header while the body scrolls. Only does anything if something
   * around the table actually constrains its height.
   * @default false
   */
  stickyHeader?: boolean;
  /** Makes rows activatable. Also turns on the hover treatment. */
  onRowClick?: (row: Row, index: number) => void;
}

/**
 * Row height, as vertical padding — and, like the horizontal track, a raw
 * length rather than a class. See the note on `paddingXValues`.
 */
const cellPaddingYValues: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: '0.375rem', sm: '0.5rem', md: '0.75rem', lg: '0.875rem', xl: '1rem' },
  compact: { xs: '0.125rem', sm: '0.25rem', md: '0.4375rem', lg: '0.5625rem', xl: '0.6875rem' }
};

/**
 * Everything a table is painted with is written inline, `<table>` included.
 *
 * This is the one component in the library that has to do that, and the reason
 * is the elements it renders. A PlButton owns its `<button>`; nobody else
 * styles it. `<table>`, `<th>` and `<td>` are different — VitePress's
 * `.vp-doc table`, Tailwind Typography's `.prose td` and every CSS framework in
 * existence style them by tag name, at two-class specificity that a one-class
 * Tailwind utility cannot outrank.
 *
 * Padding and alignment were already written inline for that reason. **The
 * borders, the display mode and the margins were not**, and that omission was
 * most of what a Plass table looked like on a documentation page: the host's
 * `td { border: 1px solid }` drew a full grid of cell rules the design never
 * asked for, its `table { display: block }` stopped `width: 100%` filling the
 * sheet, and its `table { margin: 20px 0 }` pushed the whole thing off the
 * top-left corner of the pane it is supposed to be flush inside. A grid of
 * boxed cells floating inside a rounded sheet is not a restrained table with a
 * problem — it is somebody else's table wearing this one's frame.
 *
 * So every cell states `border: 0` and then draws the one rule it actually
 * wants, and the `<table>` states the four properties a prose stylesheet is
 * known to take off it. It is verbose, and it is the only way the component
 * looks the same in a bare app and inside `.prose`.
 *
 * What is *not* inline is the row's own background, because it has a hover
 * state and inline styles have no `:hover`. It reads a `--p-row` slot instead,
 * which classes then set — a custom property is invisible to a host stylesheet,
 * so a one-class variant wins there without a fight.
 */
const tableStyle: React.CSSProperties = {
  display: 'table',
  width: '100%',
  margin: 0,
  borderCollapse: 'collapse',
  borderSpacing: 0
};

const rowClasses = /* @__PURE__ */ [
  '[--p-row:transparent]',
  '[transition:background-color_var(--plass-duration)_var(--plass-ease)]'
].join(' ');

/**
 * What a row that answers a press needs beyond the pointer treatment.
 *
 * `tabIndex` is the whole point: a row whose only way in is `onClick` is a
 * control a keyboard cannot reach at all, and `cursor-pointer` advertises it as
 * one anyway. The ring is inset rather than offset, because the sheet clips at
 * its own rounded edge and an outline drawn outside the first or last row is an
 * outline with its top or bottom sliced off.
 *
 * The `role` is deliberately left alone. `role="button"` on a `<tr>` reads well
 * in isolation and takes the row semantics off it — which orphans every `<td>`
 * inside from the table they belong to, and costs a screen reader the column
 * headers, the row position and the count.
 */
const clickableRowClasses = /* @__PURE__ */ [
  'cursor-pointer [outline:none]',
  focusRingInsetClasses
].join(' ');

/**
 * Two weights of rule, and the whole of the table's structure.
 *
 * `--plass-divider` scores one row off the next, the same ink a PlCard and a
 * PlList are scored with, so a table on a card and the card's own dividers are
 * one family of lines. The header sits on `--plass-border`, one step firmer,
 * because the break between the names of the columns and the data in them is
 * the one division a reader has to find without looking for it.
 *
 * Both are neutral inks rather than the `--plass-glass-line` this used to use.
 * That line is white, and a white rule between two rows of a white sheet is
 * not a rule — which is why the table had no visible structure of its own in
 * light mode, and why it looked like whatever grid the host page happened to
 * be drawing over it.
 *
 * They are on the *cells* rather than on the `<tr>`, which is where a rule can
 * be written inline and therefore where a host stylesheet cannot reach it.
 */
const rowRule = '1px solid var(--plass-divider)';
const headRule = '1px solid var(--plass-border)';

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
  onRowClick,
  className,
  style,
  ...props
}: PlTableProps<Row>) {
  const padX = paddingXValues[density][size];
  const padY = cellPaddingYValues[density][size];
  const clickable = Boolean(onRowClick);
  const lit = hoverable || clickable;

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
    borderBottom: headRule,
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
        'overflow-x-auto',
        radiusClasses[size],
        sheetRestClasses[variant],
        className ?? ''
      ]
        .filter(Boolean)
        .join(' ')}
      style={{ ...surfaceSlots(color, elevation), ...style }}
      {...props}
    >
      <table
        className={`text-start ${controlTextLeadingClasses[size]} text-(--plass-fg)`}
        style={tableStyle}
      >
        {caption ? (
          <caption
            className={`${metaTextClasses[size]} font-semibold text-(--plass-muted-fg)`}
            style={{ ...cellStyle, borderBottom: rowRule, textAlign: 'start' }}
          >
            {caption}
          </caption>
        ) : null}

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
                  : { width: typeof column.width === 'number' ? `${column.width}px` : column.width }
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
  );
}
