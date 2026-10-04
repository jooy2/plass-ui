/**
 * Where a `PlScrollZone` inside a scaled ancestor scrolls to, which only the
 * stylesheet can answer: without it the strip does not clip, and a box that
 * does not clip cannot be scrolled at all.
 *
 * The zone is drawn at half its size by a `transform` on the box around it, as
 * a zone inside a scaled `PlMockup` is, with `src/standalone.css` loaded the way
 * `carousel.test.tsx` loads it.
 */
import * as React from 'react';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlScrollZone } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { emulateMedia } from '../support/media';
import { moveMouseOntoPage } from '../support/pointer';

let sheet: HTMLStyleElement;

beforeAll(async () => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);

  // Reduced motion makes a button's scroll instant, so the strip is where it
  // is going as soon as it is sent there rather than on its way.
  await emulateMedia({ reducedMotion: 'reduce' });
});

afterAll(async () => {
  sheet.remove();
  await emulateMedia({ reducedMotion: 'no-preference' });
});

type Layout = 'ltr' | 'rtl' | 'vertical';

const layouts: Layout[] = ['ltr', 'rtl', 'vertical'];

/**
 * A zone laid out at twice the size it is drawn at, holding six cards that run
 * past its end whichever way it runs.
 */
function Scaled({ layout }: { layout: Layout }) {
  const vertical = layout === 'vertical';

  return (
    <div
      dir={layout === 'rtl' ? 'rtl' : undefined}
      style={{ transform: 'scale(0.5)', transformOrigin: '0 0', width: 480 }}
    >
      <PlScrollZone
        data-testid="zone"
        orientation={vertical ? 'vertical' : 'horizontal'}
        style={vertical ? { height: 400 } : undefined}
      >
        {Array.from({ length: 6 }, (_, index) => (
          <div
            key={index}
            data-card={index + 1}
            style={vertical ? { height: 160 } : { width: 160, height: 80 }}
          >
            Card {index + 1}
          </div>
        ))}
      </PlScrollZone>
    </div>
  );
}

/** The box that scrolls: the one child of the zone that grows. */
function scroller(): HTMLElement {
  return document.querySelector<HTMLElement>('[data-testid="zone"] > .grow')!;
}

/**
 * How far along the strip the numbered card starts on the screen, from the
 * strip's leading edge: the left, the right under RTL, or the top.
 */
function startOf(card: number, layout: Layout): number {
  const strip = scroller().getBoundingClientRect();
  const box = document.querySelector(`[data-card="${card}"]`)!.getBoundingClientRect();

  if (layout === 'vertical') {
    return box.top - strip.top;
  }

  return layout === 'rtl' ? strip.right - box.right : box.left - strip.left;
}

describe('a PlScrollZone inside a scaled ancestor', () => {
  it.each(layouts)('goes to the next card and back to the one before it, %s', async (layout) => {
    const screen = await render(<Scaled layout={layout} />);

    await screen.getByRole('button', { name: 'Next' }).click();

    // The second card is where the first one was: at the leading edge.
    await expect.poll(() => startOf(2, layout)).toBeCloseTo(0, 0);

    await screen.getByRole('button', { name: 'Previous' }).click();

    await expect.poll(() => startOf(1, layout)).toBeCloseTo(0, 0);
  });

  it.each(layouts)('keeps the strip under the pointer dragging it, %s', async (layout) => {
    await render(<Scaled layout={layout} />);

    const element = scroller();
    const pointerId = await moveMouseOntoPage();
    const vertical = layout === 'vertical';
    // The way a pointer pulls the strip to go forwards along it.
    const forwards = layout === 'rtl' ? 1 : -1;
    const box = element.getBoundingClientRect();
    const from = { x: box.left + box.width / 2, y: box.top + box.height / 2 };

    /** Drags the strip `distance` screen pixels along its axis, from the middle of it. */
    function drag(distance: number) {
      const at = (moved: number) => ({
        bubbles: true,
        pointerType: 'mouse',
        pointerId,
        button: 0,
        clientX: vertical ? from.x : from.x + moved,
        clientY: vertical ? from.y + moved : from.y
      });

      element.dispatchEvent(new PointerEvent('pointerdown', { ...at(0), buttons: 1 }));
      element.dispatchEvent(new PointerEvent('pointermove', { ...at(distance), buttons: 1 }));
      element.dispatchEvent(new PointerEvent('pointerup', { ...at(distance), buttons: 0 }));
    }

    const before = startOf(1, layout);

    // As far on the screen as the pointer went, which is twice as far in the
    // strip's own pixels.
    drag(60 * forwards);

    expect(startOf(1, layout) - before).toBeCloseTo(-60, 0);

    drag(-40 * forwards);

    expect(startOf(1, layout) - before).toBeCloseTo(-20, 0);
  });
});
