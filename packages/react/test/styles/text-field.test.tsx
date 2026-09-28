/**
 * The colour a `PlTextField`'s adornments are drawn in, and where a notched
 * label sits as the field takes the focus, which only the stylesheet can
 * answer.
 *
 * A glass field's family reaches its edge, its ring and its caret, and an
 * adornment is not one of them. It is read with `src/standalone.css` loaded the
 * way `card.test.tsx` loads it, at rest and again once the focus has landed and
 * anything it started easing has finished. No colour is asserted, only that an
 * adornment's is the one `--plass-muted-fg` resolves to either way.
 */
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { commands, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlTextField } from 'plass-ui';
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

/** The colour `value` resolves to inside `scope`, read off a probe put there. */
function resolved(scope: HTMLElement, value: string): string {
  const probe = document.createElement('span');

  probe.style.color = value;
  scope.append(probe);

  const color = getComputedStyle(probe).color;

  probe.remove();

  return color;
}

/** Waits out whatever the last change set easing, so a value is read settled. */
async function settle(element: HTMLElement): Promise<void> {
  await Promise.all(element.getAnimations({ subtree: true }).map((one) => one.finished));
}

describe('the text field stylesheet', () => {
  beforeEach(async () => {
    await commands.parkPointer();
  });

  it('keeps an adornment in the muted ink while the field holds the focus', async () => {
    const screen = await render(
      <PlTextField label="Weight" startIcon={<span>≈</span>} endIcon={<span>kg</span>} />
    );
    const input = screen.getByRole('textbox', { name: 'Weight' }).element() as HTMLElement;
    const shell = input.parentElement as HTMLElement;
    const start = screen.getByText('≈').element() as HTMLElement;
    const end = screen.getByText('kg').element() as HTMLElement;
    const muted = resolved(shell, 'var(--plass-muted-fg)');

    // The family has a colour of its own to hand the focus, so the question
    // means something.
    expect(resolved(shell, 'var(--p-accent)')).not.toBe(muted);
    expect(getComputedStyle(start).color).toBe(muted);
    expect(getComputedStyle(end).color).toBe(muted);

    input.focus();
    await expect.poll(() => document.activeElement).toBe(input);
    // `getAnimations` brings the style up to date first, so a transition the
    // focus started is among what is waited out.
    await settle(shell);

    expect(getComputedStyle(start).color).toBe(muted);
    expect(getComputedStyle(end).color).toBe(muted);
  });

  it('keeps a notched label where it was as the focus thickens the edge', async () => {
    const screen = await render(<PlTextField label="Email" labelPlacement="notch" />);
    const input = screen.getByRole('textbox', { name: 'Email' }).element() as HTMLElement;
    const edge = document.querySelector('fieldset') as HTMLElement;
    const label = document.querySelector('legend > label') as HTMLElement;
    const before = label.getBoundingClientRect();

    // A press rather than `focus()`: a text input matches `:focus-visible`
    // however it is focused by a person, and that is the rule that thickens
    // the edge.
    await userEvent.click(input);
    await expect.poll(() => input.matches(':focus-visible')).toBe(true);

    const after = label.getBoundingClientRect();

    // The edge has taken its extra pixel, and the label has not moved with it.
    expect(getComputedStyle(edge).borderInlineStartWidth).toBe('2px');
    expect(after.left).toBe(before.left);
    expect(after.top).toBe(before.top);
  });
});
