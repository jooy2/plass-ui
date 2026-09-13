'use client';

/**
 * The wheel over a strip that runs the other way, and what happens when the
 * strip runs out of room.
 *
 * Two components have the same problem and it is not the one it looks like. A
 * mouse has one wheel, it points down the page, and a strip that runs across
 * the box has no use for that direction — so what the wheel does over a shelf
 * of cards or a bar of tabs is left to the browser, which is to say it is one
 * thing on one machine and another on the next. The pointer being on the strip
 * is the reader saying which of the two things under it they meant to move, and
 * this is what acts on that.
 *
 * The second half is what happens at the end of the strip. A nested scroller
 * that runs out hands the rest of the gesture to the page, and the reader who
 * was flicking a shelf along gets the whole page moving instead, without having
 * asked for it and usually without having noticed which pixel it happened at.
 * `overscroll` is the choice between the two answers, and neither of them is
 * "sometimes": see `PlassOverscroll`.
 *
 * Only the axis the browser has no answer for. A trackpad's two fingers, a tilt
 * wheel and Shift held down all produce a horizontal gesture, which scrolls a
 * horizontal strip on its own — and chains on its own, which is what
 * `overscroll-behavior-x` is for. Nothing here touches those.
 */

import * as React from 'react';
import type { PlassOverscroll } from '../types.js';

/**
 * What one line is worth in pixels, for the browsers that report a wheel in
 * lines rather than in pixels.
 */
const WHEEL_LINE = 16;

/**
 * How long after the strip last moved the wheel still belongs to it.
 *
 * The window a browser latches a nested scroller for, near enough: long enough
 * to cover the gap between two notches of a wheel being turned, short enough
 * that a reader who has stopped and looked at what arrived is scrolling the
 * page again by the time they reach for it.
 */
const LATCH_MS = 250;

export interface WheelScrollOptions {
  /** Whether the wheel is read at all. A strip that runs down the page is not. */
  enabled: boolean;
  /** What happens once the strip has nowhere left to go. */
  overscroll: PlassOverscroll;
}

/**
 * Turns a vertical wheel over a horizontal scroller into travel along it.
 *
 * A native listener rather than `onWheel`, because React attaches its own wheel
 * listener to the root passively, and `preventDefault` inside a passive
 * listener does nothing but log.
 */
export function useWheelScroll(
  ref: React.RefObject<HTMLElement | null>,
  { enabled, overscroll }: WheelScrollOptions
): void {
  React.useEffect(() => {
    const element = ref.current;

    if (!element || !enabled) {
      return;
    }

    /**
     * When the strip last moved on a wheel, which is what the latch reads.
     *
     * Never, to begin with. A `0` would be a move at the moment the page
     * started, so for the first quarter-second of a page's life a strip that
     * had never moved would hold the wheel anyway.
     */
    let moved = Number.NEGATIVE_INFINITY;

    const onWheel = (event: WheelEvent) => {
      // A gesture that already has a horizontal half is one the browser scrolls
      // the strip with by itself, and a second handler would double it.
      if (Math.abs(event.deltaY) <= Math.abs(event.deltaX)) {
        return;
      }

      const room = element.scrollWidth - element.clientWidth;

      // A pixel of slack, and the sentence the whole containment rests on: a
      // strip everything fits in is not a scroller, so it never takes the wheel
      // and never holds it. Without this, a bar of three tabs would be a place
      // on the page the reader cannot scroll past.
      if (room <= 1) {
        return;
      }

      const distance =
        event.deltaMode === event.DOM_DELTA_LINE
          ? event.deltaY * WHEEL_LINE
          : event.deltaMode === event.DOM_DELTA_PAGE
            ? event.deltaY * element.clientWidth
            : event.deltaY;

      // `abs`, because a right-to-left container counts its scroll backwards
      // from zero. How far along we are is a distance either way.
      const along = Math.abs(element.scrollLeft);
      const left = distance > 0 ? room - along > 1 : along > 1;

      if (!left) {
        // Nothing left this way. `contain` keeps the wheel anyway; `auto` gives
        // it back, but not in the middle of the gesture that was scrolling the
        // strip a moment ago.
        if (overscroll === 'contain' || event.timeStamp - moved < LATCH_MS) {
          event.preventDefault();
        }

        return;
      }

      // Which way "forward" is on the physical axis: flipped under RTL.
      const sign = getComputedStyle(element).direction === 'rtl' ? -1 : 1;

      moved = event.timeStamp;
      event.preventDefault();
      element.scrollBy({ left: distance * sign, behavior: 'auto' });
    };

    element.addEventListener('wheel', onWheel, { passive: false });

    return () => element.removeEventListener('wheel', onWheel);
  }, [enabled, overscroll, ref]);
}

/**
 * The class that keeps a scroller's *own* axis to itself.
 *
 * The other half of `overscroll`, and it is CSS rather than JavaScript because
 * this axis is one the browser already scrolls: a two-finger swipe along the
 * shelf, and on a Mac the swipe past the end of it that goes back a page.
 *
 * One axis, never both. A horizontal strip that also contained the vertical
 * axis would be a box a finger cannot scroll the page from, which is most of
 * the screen on a phone.
 */
export function overscrollClasses(overscroll: PlassOverscroll, horizontal: boolean): string {
  if (overscroll !== 'contain') {
    return '';
  }

  return horizontal ? 'overscroll-x-contain' : 'overscroll-y-contain';
}
