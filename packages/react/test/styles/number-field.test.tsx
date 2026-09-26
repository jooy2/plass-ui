/**
 * How a `PlNumberField` eases while a stepper is pressed and while the field
 * holds the focus, which only the stylesheet can answer.
 *
 * The press is an `active:` tint on the stepper's own transition list and the
 * focus a `focus-within:` fill and edge on the shell's, so the assertions are on
 * the durations each element resolves while a real press holds it, or while the
 * input holds the focus, read with `src/standalone.css` loaded the way
 * `card.test.tsx` loads it. The press is held for a moment with Playwright's
 * click `delay`, and read in the first task after it lands, well before it
 * lifts. No duration is asserted, only that the press and the focus get the one
 * the release and the blur get, and that reduced motion takes it away.
 */
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlNumberField } from 'plass-ui';
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

/** The field's input and the shell it sits in, which carries the focus styles. */
async function renderField(): Promise<{ input: HTMLInputElement; shell: HTMLElement }> {
  const screen = await render(<PlNumberField label="Guests" variant="glass" defaultValue={2} />);
  const input = screen.getByRole('textbox', { name: 'Guests' }).element() as HTMLInputElement;

  return { input, shell: input.parentElement as HTMLElement };
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

  it('eases the shell into the focus over the duration it eases out of it', async () => {
    const { input, shell } = await renderField();
    const resting = getComputedStyle(shell).transitionDuration;

    expect(resting.split(',').some((one) => parseFloat(one) > 0)).toBe(true);

    input.focus();

    expect(shell.matches(':focus-within')).toBe(true);
    expect(getComputedStyle(shell).transitionDuration).toBe(resting);
  });

  it('takes the focus at once under reduced motion', async () => {
    await emulateMedia({ reducedMotion: 'reduce' });

    const { input, shell } = await renderField();

    input.focus();

    expect(shell.matches(':focus-within')).toBe(true);
    expect(
      getComputedStyle(shell)
        .transitionDuration.split(',')
        .every((one) => parseFloat(one) === 0)
    ).toBe(true);
  });
});
