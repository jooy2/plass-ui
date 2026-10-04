'use client';

/**
 * When a component that measures its own children has to measure them again.
 *
 * A component handed its children as `children` is handed a new reference on
 * every render a parent does, whether anything in them changed or not, so a
 * layout effect that lists `children` reads the layout back on every one of
 * those renders. `PlSegmentedButton` and `PlFloatingBottomNavigation` both did,
 * and a screen with several of them recalculated the layout between each one's
 * reads and the next one's writes.
 *
 * This runs on every commit as well, but it reads only the DOM tree, never the
 * layout, and calls back only when the commit changed something the children
 * can have moved with:
 *
 * - one of `deps`, which are the props the component sizes its children by;
 * - the markup under the element: a child added, removed or moved, text
 *   edited, a `class`, a `style` or a `dir` changed. A `MutationObserver`
 *   records those, and its records are taken in the layout effect, before the
 *   browser delivers them, so they are exactly the ones the commit being
 *   checked made. A parent rendering again with the same `style` writes
 *   nothing, since React sets only the declarations whose values changed, and
 *   the `style` of the element the callback writes its own answer to, such as
 *   a sliding tile, is the answer landing rather than anything that moved;
 * - the nearest `dir` above the element, since a document turned over in the
 *   same commit moves every child without touching the markup under it.
 *
 * A change made outside a commit of the component, such as a child that updates
 * itself or a font that loads, is left to the component's `ResizeObserver`,
 * which answers it when it changes a size, as it did before.
 */

import * as React from 'react';

/**
 * Calls `onChange` before the browser paints, on the first commit and on every
 * later one that changed `deps`, the markup under `ref`, or the direction it
 * runs in. `output` is the element `onChange` writes to, whose own `style` does
 * not count.
 */
export function useCommitChange(
  ref: React.RefObject<HTMLElement | null>,
  deps: readonly unknown[],
  onChange: () => void,
  output?: React.RefObject<HTMLElement | null>
): void {
  const mutationsRef = React.useRef<MutationObserver | null>(null);
  const lastRef = React.useRef<readonly unknown[] | null>(null);

  React.useLayoutEffect(() => {
    const element = ref.current;

    if (!element || typeof MutationObserver === 'undefined') {
      return;
    }

    // Nothing is done when the records are delivered. The ones that matter
    // are taken by the effect below, at the commit that made them; the rest
    // were made outside a commit, which is the `ResizeObserver`'s to answer.
    const observer = new MutationObserver(() => {});

    observer.observe(element, {
      subtree: true,
      childList: true,
      characterData: true,
      attributeFilter: ['class', 'style', 'dir']
    });
    mutationsRef.current = observer;

    return () => {
      observer.disconnect();
      mutationsRef.current = null;
    };
  }, [ref]);

  React.useLayoutEffect(() => {
    const element = ref.current;

    if (!element) {
      return;
    }

    const written = output?.current;
    const edited = (mutationsRef.current?.takeRecords() ?? []).some(
      (record) => !(record.attributeName === 'style' && record.target === written)
    );
    const next = [...deps, element.closest('[dir]')?.getAttribute('dir')];
    const last = lastRef.current;

    if (
      !edited &&
      last !== null &&
      next.length === last.length &&
      next.every((part, index) => Object.is(part, last[index]))
    ) {
      return;
    }

    lastRef.current = next;
    onChange();
  });
}
