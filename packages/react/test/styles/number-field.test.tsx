/**
 * How a `PlNumberField` eases while a stepper is pressed and while the field
 * holds the focus, what a stepper does under the pointer, and how far one that
 * cannot step is faded, which only the stylesheet can answer.
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
import type * as React from 'react';
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { commands, userEvent } from 'vitest/browser';
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

  describe('a stepper under the pointer', () => {
    /**
     * The stepper's glyph colour at rest and then with the pointer over it.
     *
     * The accent is a `:hover` colour on the stepper's own button, and a
     * disabled button still matches `:hover`. Reduced motion puts the colour
     * on at once, so nothing has to wait out the ease. No colour is asserted,
     * only whether the pointer changes it.
     */
    async function stepperColours(
      field: React.ReactElement,
      name: string,
      disabled: boolean
    ): Promise<{ rest: string; hovered: string }> {
      await commands.parkPointer();
      await emulateMedia({ reducedMotion: 'reduce' });

      const screen = await render(field);
      const stepper = screen.getByRole('button', { name });

      if (disabled) {
        await expect.element(stepper).toBeDisabled();
      } else {
        await expect.element(stepper).toBeEnabled();
      }

      const rest = getComputedStyle(stepper.element()).color;

      await userEvent.hover(stepper);

      return { rest, hovered: getComputedStyle(stepper.element()).color };
    }

    it('turns the glyph of a stepper that can be pressed to the accent', async () => {
      const { rest, hovered } = await stepperColours(
        <PlNumberField label="Guests" defaultValue={2} />,
        'Increase',
        false
      );

      expect(hovered).not.toBe(rest);
    });

    it('keeps the glyph of a stepper that has run into `min` in its muted ink', async () => {
      const { rest, hovered } = await stepperColours(
        <PlNumberField label="Guests" defaultValue={0} min={0} />,
        'Decrease',
        true
      );

      expect(hovered).toBe(rest);
    });

    it('keeps the glyph of a stepper in a disabled field in its muted ink', async () => {
      const { rest, hovered } = await stepperColours(
        <PlNumberField label="Guests" defaultValue={2} disabled />,
        'Increase',
        true
      );

      expect(hovered).toBe(rest);
    });
  });

  describe('a stepper that cannot step', () => {
    /** The shell the named field's input sits in, which carries its fade. */
    function shellOf(screen: Awaited<ReturnType<typeof render>>, name: string): HTMLElement {
      return screen.getByRole('textbox', { name }).element().parentElement as HTMLElement;
    }

    const opacityOf = (element: Element) => getComputedStyle(element).opacity;

    it('leaves the steppers of a disabled field at the half its shell is drawn at', async () => {
      await emulateMedia({ reducedMotion: 'reduce' });

      const screen = await render(
        <PlNumberField label="Guests" defaultValue={0} min={0} disabled />
      );
      const decrease = screen.getByRole('button', { name: 'Decrease' });
      const increase = screen.getByRole('button', { name: 'Increase' });

      await expect.element(decrease).toBeDisabled();
      await expect.element(increase).toBeDisabled();

      // The shell already fades everything in it, so a fade of their own
      // would draw them at a quarter, the one at `min` included.
      expect(Number(opacityOf(shellOf(screen, 'Guests')))).toBeLessThan(1);
      expect(opacityOf(decrease.element())).toBe('1');
      expect(opacityOf(increase.element())).toBe('1');
    });

    it('fades a stepper that has run into `min` in a live field as a disabled field is faded', async () => {
      await emulateMedia({ reducedMotion: 'reduce' });

      const screen = await render(
        <>
          <PlNumberField label="Guests" defaultValue={0} min={0} />
          <PlNumberField label="Rooms" defaultValue={1} disabled />
        </>
      );
      const decrease = screen.getByRole('button', { name: 'Decrease' }).first();
      const increase = screen.getByRole('button', { name: 'Increase' }).first();

      await expect.element(decrease).toBeDisabled();
      await expect.element(increase).toBeEnabled();

      expect(opacityOf(shellOf(screen, 'Guests'))).toBe('1');
      expect(opacityOf(decrease.element())).toBe(opacityOf(shellOf(screen, 'Rooms')));
      expect(opacityOf(increase.element())).toBe('1');
    });
  });
});
