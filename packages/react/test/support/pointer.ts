/**
 * Moves the browser's own mouse onto the page and returns the `pointerId` it
 * carries, for a test that dispatches a drag rather than performing one.
 *
 * A drag captures the pointer it was pressed with, and `setPointerCapture`
 * throws `NotFoundError` for a pointer the browser does not know. A real press
 * never runs into that. A dispatched one runs into it in two ways:
 *
 * - The mouse is pointer 1 in Chromium and WebKit and pointer 0 in Firefox, so
 *   no number written into a test is right in all three.
 * - Firefox knows the mouse only while it is over the page. While the pointer is
 *   parked outside the viewport, or has not moved since the browser started, it
 *   refuses every id.
 *
 * Moving the real mouse onto the page settles both, and the event that move
 * produces carries the id. The pointer is parked first, so the move is a real
 * one even when an earlier test left it on the same spot. It is left on the page
 * afterwards, because parking it again would make Firefox forget it before the
 * drag is dispatched.
 */
import { commands, page, userEvent } from 'vitest/browser';

export async function moveMouseOntoPage(): Promise<number> {
  const spot = document.createElement('div');

  spot.style.cssText = 'position: fixed; top: 0; left: 0; width: 8px; height: 8px;';
  document.body.append(spot);

  try {
    await commands.parkPointer();

    const moved = new Promise<number>((resolve) => {
      spot.addEventListener('pointermove', (event) => resolve(event.pointerId), { once: true });
    });

    await userEvent.hover(page.elementLocator(spot));

    return await moved;
  } finally {
    spot.remove();
  }
}
