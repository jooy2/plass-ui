/**
 * What a `PlCombobox` chevron does under the pointer, which only the
 * stylesheet can answer.
 *
 * The accent is a `:hover` colour on the chevron's own button, and a disabled
 * button still matches `:hover`, so the assertion is on the colour the chevron
 * resolves with a real pointer over it, read with `src/standalone.css` loaded
 * the way `card.test.tsx` loads it. Reduced motion puts the colour on at once,
 * so nothing has to wait out the ease. No colour is asserted, only whether the
 * pointer changes it.
 */
import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { commands, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlCombobox, type PlComboboxOption } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { emulateMedia } from '../support/media';

const items: PlComboboxOption[] = [
  { value: 'seoul', label: 'Seoul' },
  { value: 'lisbon', label: 'Lisbon' }
];

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

beforeEach(async () => {
  await commands.parkPointer();
  await emulateMedia({ reducedMotion: 'reduce' });
});

afterEach(async () => {
  await emulateMedia({ reducedMotion: 'no-preference' });
});

/** The chevron's colour at rest and then with the pointer over it. */
async function chevronColours(disabled: boolean): Promise<{ rest: string; hovered: string }> {
  // No `label`: the field's label names the chevron too once there is one.
  const screen = await render(<PlCombobox items={items} disabled={disabled} />);
  const chevron = screen.getByRole('button', { name: 'Open' });

  await expect.element(chevron).toBeInTheDocument();

  const rest = getComputedStyle(chevron.element()).color;

  await userEvent.hover(chevron);

  return { rest, hovered: getComputedStyle(chevron.element()).color };
}

describe('the combobox stylesheet', () => {
  it('turns the chevron of a field that can be used to the accent under the pointer', async () => {
    const { rest, hovered } = await chevronColours(false);

    expect(hovered).not.toBe(rest);
  });

  it('keeps the chevron of a disabled field in its muted ink under the pointer', async () => {
    const { rest, hovered } = await chevronColours(true);

    expect(hovered).toBe(rest);
  });

  it('leaves the chevron and the × of a disabled field at the half its shell is drawn at', async () => {
    const screen = await render(
      <PlCombobox items={items} defaultValue="seoul" clearable disabled />
    );
    const chevron = screen.getByRole('button', { name: 'Open' });
    const clear = screen.getByRole('button', { name: 'Clear' });

    await expect.element(chevron).toBeDisabled();
    await expect.element(clear).toBeDisabled();

    // The shell already fades everything in it, so a fade of their own would
    // draw them at a quarter, where a disabled `PlSelect`'s chevron is at half.
    expect(getComputedStyle(chevron.element()).opacity).toBe('1');
    expect(getComputedStyle(clear.element()).opacity).toBe('1');
  });
});
