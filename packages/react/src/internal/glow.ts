import type * as React from 'react';

/**
 * Moves `.plass-glow`'s light to where the pointer is on the surface.
 *
 * Written straight to the element as `--p-mx` and `--p-my` rather than held in
 * state: it runs at pointer rate, and a `setState` here would re-render the
 * tree on every mouse move. It also runs while a finger is down, which is what
 * makes the light follow a drag on a touch screen, where there is no hover and
 * the `:active` layer does the work.
 *
 * `offsetX` and `offsetY` cost nothing, but they are measured from whatever the
 * pointer is over. On a surface whose own element is under the pointer — a
 * button, whose icons ignore the pointer — that is the surface, and they are
 * used as they are. On one that holds other elements the pointer can land on,
 * the position is read against the surface's own box instead.
 */
export function followPointer(event: React.PointerEvent<HTMLElement>): void {
  const element = event.currentTarget;
  let x = event.nativeEvent.offsetX;
  let y = event.nativeEvent.offsetY;

  if (event.target !== element) {
    const box = element.getBoundingClientRect();

    x = event.clientX - box.left;
    y = event.clientY - box.top;
  }

  element.style.setProperty('--p-mx', `${x}px`);
  element.style.setProperty('--p-my', `${y}px`);
}
