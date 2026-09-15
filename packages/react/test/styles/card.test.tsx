/**
 * What an `interactive` card's lift does under reduced motion, which the
 * stylesheet decides.
 *
 * The lift is a `hover:` translate eased by the card's own transition, so the
 * assertion is on the transition that applies to `transform`, read with
 * `src/standalone.css` loaded the way `marquee.test.tsx` loads it. Nothing here
 * hovers, so no pointer and no timing is involved.
 */
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlCard } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { emulateMedia } from '../support/media';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

afterEach(async () => {
  await emulateMedia({ reducedMotion: 'no-preference' });
});

/**
 * The duration the card's transition gives `property`, in seconds. The two
 * lists pair up by position, and a shorter duration list repeats, as CSS
 * reads them.
 */
function durationOf(element: HTMLElement, property: string): number {
  const style = getComputedStyle(element);
  const properties = style.transitionProperty.split(',').map((one) => one.trim());
  const durations = style.transitionDuration.split(',').map((one) => parseFloat(one));
  const index = properties.indexOf(property);

  expect(index).not.toBe(-1);

  return durations[index % durations.length];
}

describe('the card stylesheet', () => {
  it('eases an interactive card’s lift', async () => {
    await render(
      <PlCard className="card-under-test" interactive>
        Body
      </PlCard>
    );

    const card = document.querySelector('.card-under-test') as HTMLElement;

    expect(durationOf(card, 'transform')).toBeGreaterThan(0);
  });

  it('lifts an interactive card at once under reduced motion', async () => {
    await emulateMedia({ reducedMotion: 'reduce' });

    await render(
      <PlCard className="card-under-test" interactive>
        Body
      </PlCard>
    );

    const card = document.querySelector('.card-under-test') as HTMLElement;

    expect(durationOf(card, 'transform')).toBe(0);
  });
});
