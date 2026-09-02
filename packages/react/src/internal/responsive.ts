/**
 * The one shape a value takes when it changes with the width of the window, and
 * the one way it reaches CSS.
 *
 * It started as `PlGrid`'s private arithmetic and is here because a second
 * component wanted it — and because the *rule* is the interesting part, not the
 * code: a bare value applies everywhere, a map applies each entry from its own
 * breakpoint up, and a rung that was not named inherits the one below it.
 * `usePlBreakpointValue` resolves the same shape in JavaScript, so a caller who
 * has learned it once has learned all of it.
 *
 * ## Where the resolving happens, and why it is two places
 *
 * A responsive value that only decides **style** is resolved in **CSS**:
 * `responsiveSlots` writes one `--p-{name}-{rung}` per rung the caller named,
 * and the `@variant` blocks in `styles.css` cascade each slot down from the
 * rung above. That is what `PlGrid` and `PlContainer` use, and what makes them
 * free: no resize listener, no re-render, and a server render that is already
 * correct at every width because the browser resolves it.
 *
 * A responsive value that decides **structure** cannot be: an orientation
 * changes which DOM a component builds, which ARIA it claims, and which way its
 * arrow keys go, and no stylesheet can do that. Those resolve in JavaScript
 * through `usePlBreakpointValue`, and pay what that costs — the server renders
 * the `xs` entry and the browser corrects it on hydration.
 *
 * The split is not a compromise between the two; it is the honest line. A
 * component should reach for the CSS half whenever it can.
 */

import type * as React from 'react';
import type { PlassBreakpoint, PlassResponsive } from '../types.js';

/** Smallest first, which is also the order the media queries have to be in. */
export const breakpoints: readonly PlassBreakpoint[] = ['xs', 'sm', 'md', 'lg', 'xl'];

/** A bare value means "from `xs` up"; a map is already per-breakpoint. */
export function breakpointMap<T>(
  value: PlassResponsive<T> | undefined
): Partial<Record<PlassBreakpoint, T>> {
  if (value === undefined || value === null) return {};
  if (typeof value === 'object') return value as Partial<Record<PlassBreakpoint, T>>;

  return { xs: value };
}

/**
 * Turns a responsive value into the `--p-{name}-{breakpoint}` slots the CSS
 * reads, emitting only the breakpoints the caller actually named.
 *
 * The gaps are filled in by CSS rather than here: each breakpoint's rule falls
 * back through the ones below it, so `{ md: 6 }` needs one slot and not five.
 * That keeps the inline style on a grid item down to what was asked for.
 */
export function responsiveSlots<T>(
  name: string,
  value: PlassResponsive<T> | undefined,
  toCss: (value: T) => string
): React.CSSProperties {
  const map = breakpointMap(value);
  const slots: Record<string, string> = {};

  for (const breakpoint of breakpoints) {
    const entry = map[breakpoint];
    if (entry !== undefined) slots[`--p-${name}-${breakpoint}`] = toCss(entry);
  }

  return slots as React.CSSProperties;
}

/**
 * Fills in the `xs` entry of a partial map with the prop's own default.
 *
 * Without this, `spacing={{ md: 4 }}` would be a grid with no gutter at all
 * below 48rem — the CSS fallback rather than the documented default — and a
 * caller who narrowed one breakpoint would silently lose every other one. A map
 * says "from here up, use this instead"; it does not say "and nothing below".
 */
export function withBaseline<T>(
  value: PlassResponsive<T> | undefined,
  baseline: T
): PlassResponsive<T> {
  if (value === undefined || value === null) return baseline;
  if (typeof value === 'object') {
    return { xs: baseline, ...(value as Partial<Record<PlassBreakpoint, T>>) };
  }

  return value;
}
