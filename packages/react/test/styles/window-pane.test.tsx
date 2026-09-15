/**
 * What a macOS traffic light shows, which the stylesheet decides.
 *
 * The mark is held back with `opacity` and brought out by a hover on the set and
 * by the focus on one light, so nothing about it can be read off the markup —
 * the component writes the same two class names either way. `src/standalone.css`
 * is loaded the way `marquee.test.tsx` loads it, and the assertion is a mark
 * that is there or is not, never a shade or a size.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { commands, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlWindowPane } from 'plass-ui';
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

/** The box the mark is drawn in, inside the button of that name. */
function mark(button: HTMLElement): HTMLElement {
  return button.firstElementChild as HTMLElement;
}

const shown = (button: HTMLElement) => getComputedStyle(mark(button)).opacity === '1';

describe('the macOS traffic lights', () => {
  it('hold their marks back until something is pointing at them', async () => {
    const screen = await render(
      <PlWindowPane os="macos" title="Notes">
        Body
      </PlWindowPane>
    );

    await commands.parkPointer();

    expect(shown(screen.getByRole('button', { name: 'Close' }).element() as HTMLElement)).toBe(
      false
    );
  });

  it('shows the mark of the light the keyboard has reached, and only that one', async () => {
    const screen = await render(
      <>
        <button type="button">Before</button>
        <PlWindowPane os="macos" title="Notes">
          Body
        </PlWindowPane>
      </>
    );

    await commands.parkPointer();

    const before = screen.getByRole('button', { name: 'Before' }).element() as HTMLElement;
    const close = screen.getByRole('button', { name: 'Close' }).element() as HTMLElement;
    const minimize = screen.getByRole('button', { name: 'Minimize' }).element() as HTMLElement;

    // Tabbed into rather than focused from script: `:focus-visible` is the
    // browser's judgement about how the focus arrived, and only a real key press
    // makes that judgement the keyboard's.
    before.focus();
    await userEvent.keyboard('{Tab}');

    await expect.poll(() => document.activeElement).toBe(close);
    // Polled, because the mark fades in over `--plass-duration` rather than
    // appearing on the frame the focus arrived.
    await expect.poll(() => shown(close)).toBe(true);
    // A ring is on one light. Lighting the other two would say the pointer is
    // over the set, which it is not.
    expect(shown(minimize)).toBe(false);
  });
});
