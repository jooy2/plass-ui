'use client';

/**
 * One media query, answered as a boolean and kept answered.
 *
 * Every part of the library that has to know something about the window goes
 * through here — whether a sidebar has collapsed, whether the reader has asked
 * for less motion, and, since `hooks/usePlMediaQuery.ts`, whatever the caller
 * wants to ask. It is one file because the interesting part is not
 * `matchMedia`, it is the three answers around it.
 *
 * `useSyncExternalStore` rather than an effect and a `useState`, for the reason
 * that matters on a server: it has a **server snapshot**, and this one is
 * `false`. There is no window to measure, so nothing matches, and every
 * consumer of this hook is written so that `false` is the safe answer — the
 * markup that ships is the wide layout, the motion is the full one. React then
 * re-renders with the real answer as soon as it is hydrating in a browser.
 *
 * The subscription is per query rather than per component, which is what stops
 * a page with twenty responsive components installing twenty listeners for the
 * same string.
 */
import * as React from 'react';

/** One `MediaQueryList` per query string, shared by every caller of it. */
const lists = new Map<string, MediaQueryList>();

function listFor(query: string): MediaQueryList | null {
  if (typeof window === 'undefined' || !window.matchMedia) {
    return null;
  }

  let list = lists.get(query);

  if (!list) {
    list = window.matchMedia(query);
    lists.set(query, list);
  }

  return list;
}

/** A server has no window, so nothing matches. */
function onServer(): boolean {
  return false;
}

/**
 * The one query the library asks on its own behalf rather than the caller's.
 *
 * Named here rather than in `internal/animate.ts` because it is not only the
 * animations' business: a loading indicator answers it the other way round —
 * slowing rather than stopping, since a spinner that stopped would be lying
 * about whether anything is happening.
 */
export const reducedMotionQuery = '(prefers-reduced-motion: reduce)';

/**
 * Whether the window matches `query` right now, re-rendering when it stops.
 *
 * `null` is a query that cannot be asked — the `xs` rung of a ladder whose
 * floor is zero — and is always `false` rather than being a second code path at
 * every call site.
 */
export function useMediaQuery(query: string | null): boolean {
  const subscribe = React.useCallback(
    (onChange: () => void) => {
      const list = query === null ? null : listFor(query);

      if (!list) {
        return () => {};
      }

      list.addEventListener('change', onChange);

      return () => list.removeEventListener('change', onChange);
    },
    [query]
  );

  const snapshot = React.useCallback(() => {
    if (query === null) {
      return false;
    }

    return listFor(query)?.matches ?? false;
  }, [query]);

  return React.useSyncExternalStore(subscribe, snapshot, onServer);
}

/**
 * Whether the reader has asked their platform for less movement.
 *
 * A server has no reader and so no preference, which is the store's own answer
 * and is the right one here: the markup that ships is the one with the motion
 * in it, and a reader who asked for less gets it in the render after hydration
 * — before any of these animations has had a frame to run in.
 */
export function usePrefersReducedMotion(): boolean {
  return useMediaQuery(reducedMotionQuery);
}
