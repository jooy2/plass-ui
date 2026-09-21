import * as React from 'react';

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

/** The keys a reader leaves a field on rather than writes in it with. */
const leavingKeys = /* @__PURE__ */ new Set([
  'Tab',
  'Escape',
  'Shift',
  'Control',
  'Alt',
  'Meta',
  'CapsLock'
]);

/**
 * What a field's shell needs to carry the light: the `pointermove` that moves
 * it, and the attribute that puts it away while the field is being typed into.
 *
 * The second half is the part a key does not want. A pointer resting on a field
 * has been parked — the hand is on the keyboard, the bloom has stopped following
 * anything, and it is sitting under the sentence being written. It fades out on
 * the first keystroke and comes back on the next real pointer move, so the light
 * is only ever on while it is still saying something.
 *
 * `pointermove` is exactly the signal wanted: a mouse held still while its owner
 * types never fires one, and the first nudge of the hand back onto it does. The
 * flag is mirrored in a ref so the state is set once per change of it rather than
 * once per frame of a gesture — the coordinates themselves are still written
 * straight to the element and re-render nothing.
 *
 * The keys that do not count as typing are the ones a reader *leaves* on: `Tab`
 * hands the field to the next control, `Escape` closes whatever is over it, and
 * a modifier on its own is the first half of a chord. A light that goes out on a
 * `Shift` which turns out to be the start of `Shift+Tab` is a light that
 * flickered for no reason.
 *
 * Spread onto the same element `.plass-glow` is on, which is the shell and never
 * the control inside it — the box the light is drawn in has to be the box the
 * reader sees. A `keydown` in the control reaches the shell by bubbling.
 */
export function useFieldLight(lit: boolean): {
  'data-quiet'?: '';
  onPointerMove?: React.PointerEventHandler<HTMLElement>;
  onKeyDown?: React.KeyboardEventHandler<HTMLElement>;
} {
  const [quiet, setQuiet] = React.useState(false);
  const quieted = React.useRef(false);

  const change = React.useCallback((next: boolean) => {
    if (quieted.current !== next) {
      quieted.current = next;
      setQuiet(next);
    }
  }, []);

  const onPointerMove = React.useCallback(
    (event: React.PointerEvent<HTMLElement>) => {
      followPointer(event);
      change(false);
    },
    [change]
  );

  const onKeyDown = React.useCallback(
    (event: React.KeyboardEvent<HTMLElement>) => {
      if (!leavingKeys.has(event.key)) {
        change(true);
      }
    },
    [change]
  );

  if (!lit) {
    return {};
  }

  return { 'data-quiet': quiet ? '' : undefined, onPointerMove, onKeyDown };
}
