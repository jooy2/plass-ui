/**
 * Everything a pointer drag takes from outside itself, and the one function
 * that gives all of it back.
 *
 * The arithmetic of a drag differs in every component that has one and stays
 * where it is. What is the same everywhere is the scaffold around it — three
 * listeners, a `data-dragging` to style against, the document's text selection,
 * and a teardown an unmount can call — and every copy of that scaffold is a
 * place for one of the four to be forgotten.
 *
 * There is deliberately **no `requestAnimationFrame` in here.** A `pointermove`
 * is already delivered once per frame in every browser the library supports —
 * `pointerrawupdate` is the uncoalesced one — so coalescing again would buy
 * nothing and cost a frame of latency on the one gesture where latency is the
 * whole feel of it.
 */

/**
 * The selection, taken for the length of a gesture.
 *
 * Written prefixed and through `setProperty` because WebKit implements only
 * `-webkit-user-select`: `style.userSelect = 'none'` hangs a plain JavaScript
 * property off the object, changes nothing, and Safari goes on selecting text
 * through the whole drag. It is taken off the document rather than fixed with
 * `preventDefault`, which would also stop the browser focusing what was
 * pressed and leave every mouse press wearing a keyboard focus ring.
 */
function takeSelection(): () => void {
  const body = document.body;
  const previous = body.style.getPropertyValue('-webkit-user-select');

  body.style.setProperty('-webkit-user-select', 'none');

  return () => {
    // Removed rather than blanked, so a page that never wrote the property
    // inline is left with the declaration it actually had.
    if (previous) {
      body.style.setProperty('-webkit-user-select', previous);
    } else {
      body.style.removeProperty('-webkit-user-select');
    }
  };
}

export interface PointerDragOptions {
  /**
   * The element the three listeners go on, and the one the pointer is captured
   * to. Capture is what retargets every later event here, so a drag survives
   * the pointer leaving the element it started on.
   */
  target: HTMLElement;
  /** The pointer that started it. */
  pointerId: number;
  /** Every move until the gesture ends. */
  onMove: (event: PointerEvent) => void;
  /**
   * The gesture ended the way it was meant to — the pointer was released.
   *
   * A `pointercancel` counts: the gesture is over and the caller wants to know
   * where it settled. What does **not** count is the drag being torn down by an
   * unmount — a component that disappeared did not finish resizing, and telling
   * a caller it did would set state on the way out of the tree. That split is
   * why `release` and `onEnd` are two things.
   */
  onEnd?: () => void;
  /** Whether the document's text selection is taken for the length of it. @default true */
  selectable?: boolean;
  /** Marks the target while it runs, for `data-dragging` to style against. @default true */
  mark?: boolean;
}

/**
 * Starts a drag. Returns `release` — everything above, given back.
 *
 * Call `release` from an unmount effect. It is idempotent, so the pointer's own
 * `pointerup` calling it first costs nothing.
 */
export function beginPointerDrag({
  target,
  pointerId,
  onMove,
  onEnd,
  selectable = true,
  mark = true
}: PointerDragOptions): () => void {
  const restoreSelection = selectable ? takeSelection() : null;

  if (mark) {
    target.dataset.dragging = 'true';
  }

  target.setPointerCapture?.(pointerId);

  let running = true;

  const release = () => {
    if (!running) {
      return;
    }

    running = false;
    target.removeEventListener('pointermove', onMove);
    target.removeEventListener('pointerup', end);
    target.removeEventListener('pointercancel', end);

    if (mark) {
      delete target.dataset.dragging;
    }

    restoreSelection?.();
  };

  const end = () => {
    release();
    onEnd?.();
  };

  target.addEventListener('pointermove', onMove);
  target.addEventListener('pointerup', end);
  target.addEventListener('pointercancel', end);

  return release;
}
