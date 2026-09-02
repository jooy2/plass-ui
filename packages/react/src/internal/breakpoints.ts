'use client';

/**
 * The width of each rung, and the queries the library asks about them.
 *
 * The ladder itself is declared **in the stylesheet**, as
 * `--plass-breakpoint-*`, because a page must not have two answers about how
 * wide it is. That file explains the whole arrangement; the short version is
 * that a media query's *condition* cannot read a custom property, so the CSS
 * half resolves Tailwind's `--breakpoint-*` theme at build time through
 * `@variant`, and this — where a breakpoint is a *value* rather than a
 * condition — reads the same answer off the document at runtime.
 *
 * So a project that moves a breakpoint moves one thing:
 *
 *   @theme { --breakpoint-md: 50rem; }
 *
 * and both halves follow.
 */

import type { PlassBreakpointFloor } from '../types.js';

/**
 * Tailwind's own widths, and what is used when the stylesheet cannot be read.
 *
 * That is not an edge case: it is every server render, and the first client
 * render of a page whose CSS has not arrived. Both want the same answer the
 * shipped stylesheet has baked in, which is this.
 */
export const defaultFloors: Record<PlassBreakpointFloor, string> = {
  sm: '40rem',
  md: '48rem',
  lg: '64rem',
  xl: '80rem'
};

/**
 * The ladder as the document has it, read once.
 *
 * Once, because a breakpoint is a build-time decision on the CSS side — there
 * is nothing to keep up with. What *does* change at runtime is which rung the
 * window is on, and that is `matchMedia`'s job rather than this one's: these
 * values only ever build the query strings.
 *
 * The server's answer is not cached. It has no document to read and would
 * otherwise poison the client's first read in a runtime that keeps modules
 * across requests.
 */
let ladder: Record<PlassBreakpointFloor, string> | null = null;

export function breakpointFloors(): Record<PlassBreakpointFloor, string> {
  if (ladder) {
    return ladder;
  }

  if (typeof document === 'undefined' || typeof getComputedStyle === 'undefined') {
    return defaultFloors;
  }

  const root = getComputedStyle(document.documentElement);

  const read = (rung: PlassBreakpointFloor): string => {
    const value = root.getPropertyValue(`--plass-breakpoint-${rung}`).trim();

    return value === '' ? defaultFloors[rung] : value;
  };

  ladder = { sm: read('sm'), md: read('md'), lg: read('lg'), xl: read('xl') };

  return ladder;
}

/** `(width >= …)` — at this rung and above. */
export function fromQuery(rung: PlassBreakpointFloor): string {
  return `(width >= ${breakpointFloors()[rung]})`;
}

/** `(width < …)` — below this rung. The mirror of `fromQuery`, never both. */
export function belowQuery(rung: PlassBreakpointFloor): string {
  return `(width < ${breakpointFloors()[rung]})`;
}
