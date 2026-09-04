'use client';

import * as React from 'react';

/** The box an element is laid out at, in pixels. */
export interface PlElementSize {
  width: number;
  height: number;
}

/**
 * The content box, which is `clientWidth` with the padding taken back off.
 *
 * Read the same way for the first measurement and for every later one, rather
 * than taking the first from the element and the rest from the observer's
 * `contentRect`: two sources for one number is two numbers that can disagree by
 * a rounding.
 */
function contentBoxOf(element: HTMLElement): PlElementSize {
  const style = getComputedStyle(element);
  const across = parseFloat(style.paddingInlineStart) + parseFloat(style.paddingInlineEnd);
  const down = parseFloat(style.paddingBlockStart) + parseFloat(style.paddingBlockEnd);

  return {
    width: Math.max(0, element.clientWidth - across),
    height: Math.max(0, element.clientHeight - down)
  };
}

/**
 * How big an element is, kept up to date as it changes.
 *
 * A `ResizeObserver` and the two things a hook has to add. The first is
 * **when**: the size is read in a layout effect as well as from the observer,
 * because an observer's first callback arrives after a frame has been painted
 * and a component that laid itself out from `0 × 0` for one frame flashes.
 *
 * The second is what it reports: the **content box**, the room actually left
 * inside the element once its own padding has been taken off. A hand-written
 * version nearly always reports `getBoundingClientRect` or `borderBoxSize`
 * instead, which is a different number — and the wrong one for the question
 * that made somebody measure the element.
 *
 * `null` until there is an element to measure, which is the honest answer on a
 * server and on the first render: guessing `0` there would let a caller divide
 * by it.
 *
 * @example
 * const box = React.useRef<HTMLDivElement>(null);
 * const size = usePlElementSize(box);
 *
 * <div ref={box}>{size ? `${Math.round(size.width)}px` : null}</div>
 */
export function usePlElementSize(
  target: React.RefObject<HTMLElement | null>
): PlElementSize | null {
  const [size, setSize] = React.useState<PlElementSize | null>(null);

  React.useLayoutEffect(() => {
    const element = target.current;

    if (!element) {
      return undefined;
    }

    const read = () => {
      const next = contentBoxOf(element);

      // The same object back when nothing moved, so a resize that changed
      // something else does not re-render every caller of this.
      setSize((was) => (was?.width === next.width && was.height === next.height ? was : next));
    };

    read();

    if (typeof ResizeObserver === 'undefined') {
      // No observer means one measurement rather than none: a layout that is
      // right until something moves beats a layout that is never right.
      return undefined;
    }

    const observer = new ResizeObserver(read);

    observer.observe(element);

    return () => observer.disconnect();
  }, [target]);

  return size;
}
