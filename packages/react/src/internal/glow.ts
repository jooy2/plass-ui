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

/**
 * `.plass-glow` and the `pointermove` that feeds it, composed with whatever
 * handler the caller already passed.
 *
 * Every surface that carries the light needs the same three things: the class,
 * `position: relative` for the two layers to hang off, and this handler. The
 * class and `relative` are written into each component's own base classes,
 * because Tailwind only generates what it has seen spelled out; the wiring is
 * here, so that every call site does not grow its own copy of it.
 *
 * `undefined` comes back when the surface is not interactive and the caller
 * passed nothing, which is what keeps a listener off an element that has no
 * light to move.
 */
export function glowPointerMove<E extends HTMLElement>(
  lit: boolean,
  onPointerMove?: React.PointerEventHandler<E>
): React.PointerEventHandler<E> | undefined {
  if (!lit) {
    return onPointerMove;
  }

  return (event) => {
    followPointer(event);
    onPointerMove?.(event);
  };
}
