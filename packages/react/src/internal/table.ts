/**
 * The ink a table is drawn with, and the reason two components share it.
 *
 * `PlTable` draws a grid it is given; `PlDataTable` sorts, filters and pages
 * its own rows and then draws one. They are two components because the second
 * has to call hooks and the first must not — a table whose every column is a
 * `render` callback is the one component in this library that a React server
 * component has to be able to render, and reading a context would take that
 * away. Two components drawing the same grid out of two copies of these
 * constants is how the rules under a sorted table end up a shade off the rules
 * under a plain one.
 */
import type * as React from 'react';
import { focusRingInsetClasses } from './styles.js';
import type { PlassDensity, PlassSize } from '../types.js';

/**
 * Row height, as vertical padding — and, like the horizontal track, a raw
 * length rather than a class. See the note on `paddingXValues`.
 */
export const cellPaddingYValues: Record<PlassDensity, Record<PlassSize, string>> = {
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
export const tableStyle: React.CSSProperties = {
  display: 'table',
  width: '100%',
  margin: 0,
  borderCollapse: 'collapse',
  borderSpacing: 0
};

export const rowClasses = /* @__PURE__ */ [
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
export const clickableRowClasses = /* @__PURE__ */ [
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
export const rowRule = '1px solid var(--plass-divider)';
export const headRule = '1px solid var(--plass-border)';
