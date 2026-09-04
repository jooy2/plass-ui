/**
 * The arithmetic and the vocabulary `PlGrid`, `PlGridItem` and `PlFlex` share.
 *
 * Like `internal/styles.ts` this is the library talking to itself, and it lives
 * here rather than in any of their folders for one reason: the grid is one
 * system in two elements and neither should have to import the other, and a
 * flex box distributes and aligns its children with the same five words — so a
 * caller who has learned `justify` on one has learned it on all three.
 *
 * What is *not* here is the layout itself. A column width is
 * `(100% + gap) * span / columns - gap`, it has to change at four breakpoints,
 * and it is the width of an element whose column count is declared on its
 * parent — none of which Tailwind can spell, because Tailwind only ever sees
 * class names written out literally and `columns` is a number a caller picks.
 * So the widths are real CSS in `styles.css`, driven by the `--p-*` slots this
 * file generates. That is the same split the rest of the library makes:
 * per-instance values go in inline custom properties, never in class names.
 */

import type { PlassAlignItems, PlassAlignSelf, PlassJustify } from '../types.js';

/**
 * A count of columns, as a plain number for `calc()` to divide by.
 *
 * Rounded and floored at 1 because the value ends up as a divisor: a grid of
 * 2.5 columns is not a thing anybody meant, and a grid of 0 is a division by
 * zero that would take the width declaration down with it.
 */
export function columnCount(value: number): string {
  return String(Math.max(1, Math.round(value)));
}

/** A span or an offset. Same rounding; an offset of 0 is meaningful. */
export function columnUnits(value: number, min: number): string {
  return String(Math.max(min, Math.round(value)));
}

export const spanValue = (value: number) => columnUnits(value, 1);
export const offsetValue = (value: number) => columnUnits(value, 0);

/**
 * One step of `spacing`, in `rem`.
 *
 * This is Tailwind's spacing scale and not Material's 8px one: `spacing={4}` is
 * `1rem`, exactly what `gap-4` already means and what `p-4` in the sheet
 * padding tables already is. Every other number in this library is on that
 * ladder, and a grid that measured its gutters differently from the card around
 * it would be the one place a caller has to stop and convert.
 */
const SPACING_STEP = 0.25;

/**
 * A gutter, as a length.
 *
 * Fractions are the point — `spacing={1.5}` is `0.375rem`, the same step
 * `gap-1.5` is — so the multiplication is rounded to five places rather than
 * left to print `0.30000000000000004rem` into the DOM.
 */
export function spacingValue(units: number): string {
  const rem = Math.max(0, units) * SPACING_STEP;

  return `${Number(rem.toFixed(5))}rem`;
}

/* ---------------------------------------------------------------------------
 * Alignment
 *
 * These *are* literal class names, so they stay in Tailwind. The positional
 * values map onto `flex-start`/`flex-end` rather than the logical `start`/`end`
 * because a flex container is what is underneath, and the bare logical keywords
 * are the newer spelling of the two.
 * ------------------------------------------------------------------------- */

export const justifyClasses: Record<PlassJustify, string> = {
  start: 'justify-start',
  center: 'justify-center',
  end: 'justify-end',
  'space-between': 'justify-between',
  'space-around': 'justify-around',
  'space-evenly': 'justify-evenly',
  stretch: 'justify-stretch'
};

export const alignItemsClasses: Record<PlassAlignItems, string> = {
  start: 'items-start',
  center: 'items-center',
  end: 'items-end',
  stretch: 'items-stretch',
  baseline: 'items-baseline'
};

/**
 * Where the *rows* sit when the grid is shorter than the box holding it. Only
 * ever visible on a grid with a height of its own, which is why it takes the
 * full distribution vocabulary and `alignItems` does not.
 */
export const alignContentClasses: Record<PlassJustify, string> = {
  start: 'content-start',
  center: 'content-center',
  end: 'content-end',
  'space-between': 'content-between',
  'space-around': 'content-around',
  'space-evenly': 'content-evenly',
  stretch: 'content-stretch'
};

export const alignSelfClasses: Record<PlassAlignSelf, string> = {
  auto: 'self-auto',
  start: 'self-start',
  center: 'self-center',
  end: 'self-end',
  stretch: 'self-stretch',
  baseline: 'self-baseline'
};
