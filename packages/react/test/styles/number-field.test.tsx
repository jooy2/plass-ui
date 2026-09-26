/**
 * How a `PlNumberField` stepper eases while it is pressed, which only the
 * stylesheet can answer.
 *
 * The press is an `active:` tint on the stepper's own transition list, so the
 * assertion is on the durations the stepper resolves while a real press holds
 * it, read with `src/standalone.css` loaded the way `card.test.tsx` loads it.
 * The press is held for a moment with Playwright's click `delay`, and read in
 * the first task after it lands, well before it lifts. No duration is
 * asserted, only that the press gets the one the release gets.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlNumberField } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

interface Held {
  /** Whether the stepper matched `:active` when it was read. */
  active: boolean;
  /** Its `transition-duration` list, as the browser resolved it. */
  durations: string;
}

/**
 * Presses `element` for a quarter of a second and reads its durations as soon
 * as the press has landed, while the browser holds it `:active`.
 */
async function readWhilePressed(element: HTMLElement): Promise<Held | undefined> {
  let held: Held | undefined;

  element.addEventListener(
    'pointerdown',
    () => {
      setTimeout(() => {
        held = {
          active: element.matches(':active'),
          durations: getComputedStyle(element).transitionDuration
        };
      }, 0);
    },
    { once: true }
  );

  await userEvent.click(element, { delay: 250 });

  return held;
}

describe('the number field stylesheet', () => {
  it('eases a stepper’s press over the duration it eases its release', async () => {
    const screen = await render(<PlNumberField label="Guests" defaultValue={2} />);
    const stepper = screen.getByRole('button', { name: 'Increase' }).element() as HTMLElement;
    const resting = getComputedStyle(stepper).transitionDuration;

    expect(resting.split(',').some((one) => parseFloat(one) > 0)).toBe(true);

    const held = await readWhilePressed(stepper);

    expect(held?.active).toBe(true);
    expect(held?.durations).toBe(resting);
  });
});
