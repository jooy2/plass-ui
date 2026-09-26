/**
 * How a `PlOtpField` slot eases as it takes the focus, which only the
 * stylesheet can answer.
 *
 * The focus is a `focus-within:` fill and edge on the slot's own transition
 * list, so the assertion is on the durations the slot resolves while it holds
 * the focus, read with `src/standalone.css` loaded the way `card.test.tsx`
 * loads it. No duration is asserted, only that the focus gets the one the blur
 * gets, and that reduced motion takes it away.
 */
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlOtpField } from 'plass-ui';
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

/** The field's first slot. */
async function renderSlot(): Promise<HTMLInputElement> {
  const screen = await render(<PlOtpField label="Code" variant="glass" length={4} />);

  return screen.getByRole('textbox').first().element() as HTMLInputElement;
}

describe('the one-time code stylesheet', () => {
  it('eases a slot into the focus over the duration it eases out of it', async () => {
    const slot = await renderSlot();
    const resting = getComputedStyle(slot).transitionDuration;

    expect(resting.split(',').some((one) => parseFloat(one) > 0)).toBe(true);

    slot.focus();

    expect(slot.matches(':focus')).toBe(true);
    expect(getComputedStyle(slot).transitionDuration).toBe(resting);
  });

  it('takes the focus at once under reduced motion', async () => {
    await emulateMedia({ reducedMotion: 'reduce' });

    const slot = await renderSlot();

    slot.focus();

    expect(slot.matches(':focus')).toBe(true);
    expect(
      getComputedStyle(slot)
        .transitionDuration.split(',')
        .every((one) => parseFloat(one) === 0)
    ).toBe(true);
  });
});
