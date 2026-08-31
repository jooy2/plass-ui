'use client';

import { useMediaQuery } from '../internal/media.js';

/**
 * Whether the window matches a CSS media query, as a boolean that re-renders
 * when the answer changes.
 *
 * The library has always had this — it is how a `PlSidebar` knows it has become
 * a drawer and how a `PlAnimate*` finds out that the reader asked for less
 * motion — and it is public now because the alternative in application code is
 * a `useState`, an effect and a listener that is nearly always subscribed one
 * render too late.
 *
 * **The first answer in a browser is the server's answer.** There is no window
 * to measure while the HTML is being generated, so this returns `false` on the
 * server and through the hydrating render, and the real answer arrives in the
 * render after that. Anything that has to be right in the *first* frame belongs
 * in CSS — a Tailwind variant, or the `--plass-*` token that variant sets — and
 * this hook is for the decisions CSS cannot make, like whether a component
 * exists at all.
 *
 * @example
 * const coarse = usePlMediaQuery('(pointer: coarse)');
 */
export function usePlMediaQuery(query: string): boolean {
  return useMediaQuery(query);
}
