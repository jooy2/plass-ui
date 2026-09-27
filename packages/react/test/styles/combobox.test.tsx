/**
 * What a `PlCombobox` chevron does under the pointer, and how faded its chips
 * are drawn, which only the stylesheet can answer.
 *
 * The accent is a `:hover` colour on the chevron's own button, and a disabled
 * button still matches `:hover`, so the assertion is on the colour the chevron
 * resolves with a real pointer over it, read with `src/standalone.css` loaded
 * the way `card.test.tsx` loads it. Reduced motion puts the colour on at once,
 * so nothing has to wait out the ease. No colour is asserted, only whether the
 * pointer changes it, and no opacity, only how many fades a chip is drawn
 * through.
 */
import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { commands, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlChip, PlCombobox, type PlComboboxOption } from 'plass-ui';
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

/** The opacity `element` is drawn at, with every fade above it multiplied in. */
function drawnOpacity(element: Element): number {
  let opacity = 1;

  for (let node: Element | null = element; node; node = node.parentElement) {
    opacity *= Number(getComputedStyle(node).opacity);
  }

  return opacity;
}

/** How many of `element` and the elements above it drain its colour. */
function drains(element: Element): number {
  let count = 0;

  for (let node: Element | null = element; node; node = node.parentElement) {
    count += getComputedStyle(node).filter.includes('saturate(') ? 1 : 0;
  }

  return count;
}

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

  it('leaves the chevron of a disabled field at the half its shell is drawn at', async () => {
    const screen = await render(<PlCombobox items={items} defaultValue="seoul" disabled />);
    const chevron = screen.getByRole('button', { name: 'Open' });

    await expect.element(chevron).toBeDisabled();

    // The shell already fades everything in it, so a fade of its own would draw
    // it at a quarter, where a disabled `PlSelect`'s chevron is at half.
    expect(getComputedStyle(chevron.element()).opacity).toBe('1');
  });

  describe('the chips of a `multiple` field', () => {
    it('draws the chips of a disabled field at the one fade its shell is drawn at', async () => {
      const screen = await render(
        <PlCombobox
          items={items}
          multiple
          defaultValue={['seoul', 'lisbon']}
          disabled
          classNames={{ control: 'shell-under-test' }}
        />
      );
      const shell = document.querySelector('.shell-under-test') as HTMLElement;

      await expect.element(screen.getByText('Seoul')).toBeInTheDocument();

      expect(drawnOpacity(shell)).toBeLessThan(1);

      for (const name of ['Seoul', 'Lisbon']) {
        const chip = screen.getByText(name).element();

        expect(drawnOpacity(chip)).toBe(drawnOpacity(shell));
        expect(drains(chip)).toBe(1);
      }
    });

    it('still draws the chips of a disabled field as a disabled chip is drawn', async () => {
      const screen = await render(
        <>
          <PlChip disabled>Draft</PlChip>
          <PlCombobox items={items} multiple defaultValue={['seoul']} disabled />
          <PlCombobox items={items} multiple defaultValue={['lisbon']} />
        </>
      );
      const chipOf = (name: string) => screen.getByText(name).element().parentElement as Element;

      for (const property of ['color', 'borderColor', 'boxShadow', 'cursor'] as const) {
        expect(getComputedStyle(chipOf('Seoul'))[property]).toBe(
          getComputedStyle(chipOf('Draft'))[property]
        );
      }

      // The neutral ink of a disabled chip, not the accent a live one takes.
      expect(getComputedStyle(chipOf('Seoul')).color).not.toBe(
        getComputedStyle(chipOf('Lisbon')).color
      );
    });

    it('draws the chips of a live field unfaded', async () => {
      const screen = await render(
        <PlCombobox items={items} multiple defaultValue={['seoul', 'lisbon']} />
      );

      await expect.element(screen.getByText('Seoul')).toBeInTheDocument();

      for (const name of ['Seoul', 'Lisbon']) {
        const chip = screen.getByText(name).element();

        expect(drawnOpacity(chip)).toBe(1);
        expect(drains(chip)).toBe(0);
      }
    });

    it('still fades a chip disabled on its own, outside a field', async () => {
      const screen = await render(
        <>
          <PlChip disabled>Draft</PlChip>
          <PlCombobox
            items={items}
            defaultValue="seoul"
            disabled
            classNames={{ control: 'shell-under-test' }}
          />
        </>
      );
      const shell = document.querySelector('.shell-under-test') as HTMLElement;
      const chip = screen.getByText('Draft').element();

      expect(drawnOpacity(chip)).toBeLessThan(1);
      expect(drawnOpacity(chip)).toBe(drawnOpacity(shell));
      expect(drains(chip)).toBe(1);
    });
  });
});
