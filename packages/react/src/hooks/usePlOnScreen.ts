'use client';

import * as React from 'react';

export interface PlOnScreenOptions {
  /**
   * How much of the element has to be showing before it counts, from `0` to
   * `1`.
   * @default 0
   */
  threshold?: number;
  /**
   * How far outside the viewport still counts, as a CSS margin — `'200px'`
   * starts a fetch a screen early.
   */
  rootMargin?: string;
  /**
   * What it is measured against. The viewport when it is not given; a scrolling
   * panel otherwise.
   */
  root?: React.RefObject<Element | null>;
  /**
   * Stops watching the first time it appears.
   *
   * On by default, because the question a caller almost always has is "has this
   * been seen yet" rather than "is it on screen right now" — a lazily loaded
   * picture, a section that animates once, a page that fetches the next batch.
   * Turn it off for the answer that keeps changing.
   * @default true
   */
  once?: boolean;
}

/**
 * Whether an element is on screen.
 *
 * An `IntersectionObserver` with the three things a hook has to decide, and
 * the interesting one is `once`. It is **on** by default: the question a caller
 * almost always has is "has this been seen yet", not "is it on screen right
 * now", and a hook that kept answering the second one would re-render a page of
 * lazily loaded pictures every time the reader scrolled past any of them.
 *
 * `false` on a server and on the first render, which is the safe answer for
 * both of the things this is used for: nothing is fetched that did not need to
 * be, and nothing is played before a reader could see it.
 *
 * A browser with no observer is told **yes** rather than no. There is no way to
 * find out, and a picture that never loads is worse than one that loads early.
 *
 * @example
 * const section = React.useRef<HTMLDivElement>(null);
 * const seen = usePlOnScreen(section, { rootMargin: '200px' });
 */
export function usePlOnScreen(
  target: React.RefObject<Element | null>,
  { threshold = 0, rootMargin, root, once = true }: PlOnScreenOptions = {}
): boolean {
  const [onScreen, setOnScreen] = React.useState(false);

  React.useEffect(() => {
    const element = target.current;

    if (!element) {
      return undefined;
    }

    if (typeof IntersectionObserver === 'undefined') {
      // No way to find out. A picture that never loads is worse than one that
      // loads early.
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setOnScreen(true);

      return undefined;
    }

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setOnScreen(true);

          if (once) {
            observer.disconnect();
          }
        } else if (!once) {
          setOnScreen(false);
        }
      },
      { threshold, rootMargin, root: root?.current ?? null }
    );

    observer.observe(element);

    return () => observer.disconnect();
  }, [target, threshold, rootMargin, root, once]);

  return onScreen;
}
