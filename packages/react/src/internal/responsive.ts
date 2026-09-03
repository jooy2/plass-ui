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
import { fromQuery } from './breakpoints.js';
import { useMediaQuery } from './media.js';
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

/** Whether a value is a per-breakpoint map rather than one answer for all of them. */
export function isResponsiveMap<T>(value: PlassResponsive<T> | undefined): boolean {
  return value !== undefined && value !== null && typeof value === 'object';
}

/**
 * A responsive value at one rung of the ladder.
 *
 * Walks **down** from that rung rather than up from `xs`: the nearest entry at
 * or below the window is the one that applies, and walking down finds it
 * without having to know which rungs were named.
 *
 * `undefined` when the map named no rung at or below — `{ lg: 3 }` on a phone
 * is not `3`, and guessing a value the caller did not write would be worse than
 * saying so.
 */
export function resolveAt<T>(
  value: PlassResponsive<T> | undefined,
  at: PlassBreakpoint
): T | undefined {
  const map = breakpointMap(value);

  for (let index = breakpoints.indexOf(at); index >= 0; index -= 1) {
    const found = map[breakpoints[index]];

    if (found !== undefined) {
      return found;
    }
  }

  return undefined;
}

/**
 * A responsive prop a component has to resolve **itself**, with its own default
 * behind it.
 *
 * For the props CSS cannot decide: an orientation changes which DOM a component
 * builds, which ARIA it claims and which way its arrow keys go, and no
 * stylesheet can do any of that. The cost is the one every JavaScript answer
 * about width pays — a server renders the `xs` entry and the browser corrects
 * it on hydration — which is why a prop that only decides *style* should use
 * `responsiveSlots` instead and never come here.
 *
 * **A bare value subscribes to nothing.** `useMediaQuery(null)` is a hook that
 * adds no listener, so a component whose orientation is one word costs exactly
 * what it cost before this existed: the four queries are only asked when there
 * is a map to answer with. Twenty tab bars on a page that never change shape
 * install no listeners between them.
 */
export function useResponsiveValue<T>(value: PlassResponsive<T> | undefined, fallback: T): T {
  const responsive = isResponsiveMap(value);

  const sm = useMediaQuery(responsive ? fromQuery('sm') : null);
  const md = useMediaQuery(responsive ? fromQuery('md') : null);
  const lg = useMediaQuery(responsive ? fromQuery('lg') : null);
  const xl = useMediaQuery(responsive ? fromQuery('xl') : null);

  if (!responsive) {
    return (value ?? fallback) as T;
  }

  const at: PlassBreakpoint = xl ? 'xl' : lg ? 'lg' : md ? 'md' : sm ? 'sm' : 'xs';

  // A map that named nothing at or below the window falls back to the
  // component's own default rather than to nothing: `{ md: 'vertical' }` is
  // "vertical from md", and below it the component is what it always was.
  return resolveAt(value, at) ?? fallback;
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
