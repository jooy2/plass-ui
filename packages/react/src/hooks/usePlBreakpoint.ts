'use client';

import { fromQuery } from '../internal/breakpoints.js';
import { resolveAt } from '../internal/responsive.js';
import { useMediaQuery } from '../internal/media.js';
import type { PlassBreakpoint, PlassResponsive } from '../types.js';

/**
 * Which rung of the breakpoint ladder the window is on.
 *
 * Four queries rather than one `innerWidth` read, and deliberately: a width
 * measured in JavaScript is a number that has to be compared against a `rem`,
 * and a `rem` is whatever the reader has set their font size to. `matchMedia`
 * asks the same engine the stylesheet asks, so a component that switches at
 * `md` here switches with the `md:` utilities beside it rather than a few
 * pixels away from them.
 *
 * The widths come off the document — see `internal/breakpoints.ts` — so a
 * project that moves a breakpoint in its Tailwind theme moves this too.
 *
 * **`xs` is the server's answer**, and the first one a browser renders. See
 * `usePlMediaQuery` for what follows from that.
 */
export function usePlBreakpoint(): PlassBreakpoint {
  const sm = useMediaQuery(fromQuery('sm'));
  const md = useMediaQuery(fromQuery('md'));
  const lg = useMediaQuery(fromQuery('lg'));
  const xl = useMediaQuery(fromQuery('xl'));

  if (xl) return 'xl';
  if (lg) return 'lg';
  if (md) return 'md';
  if (sm) return 'sm';

  return 'xs';
}

/**
 * A `PlassResponsive` value, resolved for the width the window is at.
 *
 * The same shape and the same rule as `PlGrid`'s own props: a bare value
 * applies everywhere, and a map applies each entry **from its own breakpoint
 * up**, so `{ xs: 1, md: 3 }` is `1` on a phone and `3` from 48rem. An entry
 * cascades to the rungs above it, which is what keeps a responsive value to the
 * breakpoints it actually names.
 *
 * It exists because there is a class of decision CSS cannot make — how many
 * items to fetch, which of two components to mount, how many characters to
 * truncate at — and writing it out by hand means repeating the ladder in
 * numbers a stylesheet will later disagree with.
 *
 * `undefined` when the map named no rung at or below the current one:
 * `{ lg: 3 }` on a phone is not `3`, and guessing a value the caller did not
 * write would be worse than saying so.
 *
 * An object is read as a **map**, exactly as it is in a responsive prop — so a
 * value that is itself an object has to be wrapped in a map to be passed
 * through: `{ xs: { … } }`.
 */
export function usePlBreakpointValue<T>(value: PlassResponsive<T>): T | undefined {
  return resolveAt(value, usePlBreakpoint());
}
