import type * as React from 'react';

/** What a component scrolls, or follows the scroll of. */
export type PlassScrollTarget =
  Window | HTMLElement | React.RefObject<HTMLElement | null> | (() => Window | HTMLElement | null);

/** What `target` names, or the window when it names nothing. */
export function resolveScrollTarget(
  target: PlassScrollTarget | undefined
): Window | HTMLElement | null {
  if (target === undefined) {
    return typeof window === 'undefined' ? null : window;
  }

  if (typeof target === 'function') {
    return target();
  }

  if ('current' in target) {
    return target.current;
  }

  return target;
}
