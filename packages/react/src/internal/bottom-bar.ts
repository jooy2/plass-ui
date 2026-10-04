'use client';

import * as React from 'react';
import { layoutBox } from './layout-box.js';

/**
 * The room a `fixed` bottom bar takes, published for the page to reserve.
 *
 * `PlBottomNavigation` and `PlFloatingBottomNavigation` are held against the
 * bottom of the window and out of the flow, so the end of the page is always
 * under them, and so is a link a reader tabs to down there. The page is the
 * only thing that can make room — the bar cannot pad something it is not
 * inside — and it can only make exactly the right amount if it is told how
 * much. That depends on the size, the density, which names are drawn and the
 * home indicator, so it is measured rather than declared, and written onto the
 * root element where every rule on the page can read it.
 *
 * Written straight to the DOM rather than through state, for the reason
 * `PlPageLayout` gives for its own measurements: nothing in the tree reads the
 * number except CSS declarations, and a `setState` would re-render on every
 * resize to change nothing.
 */

/** The token the height is published as. Declared as `0px` in `styles.css`. */
export const bottomBarToken = '--plass-bottom-navigation-height';

/** Every fixed bottom bar on the page, which is almost always one. */
const bars = new Set<HTMLElement>();

let observer: ResizeObserver | null = null;

/**
 * Writes the tallest bar's height onto the root, or takes it off once there is
 * no bar, so the stylesheet's `0px` answers again.
 *
 * The tallest rather than the last, so two bars mounted at once — a page and a
 * dialog each with its own — reserve enough for either, and one unmounting does
 * not take the room away from the other.
 *
 * Each is the height the bar is laid out at, which is not always the height it
 * is drawn at. Inside a `transform`, a bar in a scaled `PlMockup` for one, a
 * `fixed` bar is fixed to that box rather than to the window, and covers only
 * what is laid out in it, in the pixels the bar is laid out in too. So the
 * height measured on the screen is turned into those, which is also what the
 * `ResizeObserver` that calls this watches.
 *
 * The ratio comes from the computed style, which writes a length to a few
 * decimals, so with nothing scaling the bar it is a few thousandths of a pixel
 * off the box on the screen. Two heights within a hundredth of a pixel are one
 * height, and the box on the screen, which is exact, is kept.
 */
function publish(): void {
  const root = document.documentElement;

  if (bars.size === 0) {
    root.style.removeProperty(bottomBarToken);

    return;
  }

  let tallest = 0;

  for (const bar of bars) {
    const drawn = bar.getBoundingClientRect().height;
    const laidOut = drawn * layoutBox(bar, false).perPixel;

    tallest = Math.max(tallest, Math.abs(laidOut - drawn) < 0.01 ? drawn : laidOut);
  }

  root.style.setProperty(bottomBarToken, `${tallest}px`);
}

/**
 * Publishes the element's height while `active`, which is while the bar is
 * `fixed`. A `sticky` or `static` bar is in the flow and covers nothing at the
 * end of the page, so it takes nothing.
 *
 * In a layout effect so the room is there on the frame the bar first paints,
 * rather than one frame after it has covered something.
 */
export function useBottomBarHeight(
  node: React.RefObject<HTMLElement | null>,
  active: boolean
): void {
  React.useLayoutEffect(() => {
    const element = node.current;

    if (!active || !element) {
      return;
    }

    bars.add(element);

    if (typeof ResizeObserver !== 'undefined') {
      observer ??= new ResizeObserver(publish);
      // The border box, because what the page has to clear is the whole sheet,
      // the home indicator's padding included.
      observer.observe(element, { box: 'border-box' });
    }

    publish();

    return () => {
      bars.delete(element);
      observer?.unobserve(element);

      if (bars.size === 0) {
        observer?.disconnect();
        observer = null;
      }

      publish();
    };
  }, [active, node]);
}
