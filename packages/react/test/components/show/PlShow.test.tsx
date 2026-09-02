/**
 * The gate decides in CSS, so this loads the stylesheet — which every other
 * component test deliberately does not. There is nothing else to assert: the
 * component renders one `<div>` and two attributes, and the whole of what it
 * promises is what the browser then does with them at a width.
 *
 * The viewport is resized rather than `matchMedia` stubbed, for the reason
 * `usePlBreakpoint`'s tests give: the claim is that it changes where Tailwind's
 * `md:` changes, and the only way to check that is to ask the same engine.
 */
import { page } from 'vitest/browser';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlShow } from 'plass-ui';
import standaloneCss from '../../../src/standalone.css?inline';

let sheet: HTMLStyleElement;
let initial: [number, number];

beforeAll(() => {
  initial = [window.innerWidth, window.innerHeight];
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(async () => {
  sheet.remove();
  await page.viewport(...initial);
});

/** What the gate is doing right now, once the width has settled. */
async function displayAt(width: number): Promise<string> {
  await page.viewport(width, 600);

  const gate = document.querySelector('[data-testid="gate"]') as HTMLElement;

  await expect.poll(() => getComputedStyle(gate).display).not.toBe('');

  return getComputedStyle(gate).display;
}

describe('PlShow', () => {
  it('is not a box while it is showing', async () => {
    await render(
      <PlShow data-testid="gate">
        <span>Both</span>
      </PlShow>
    );

    // `display: contents` and not `block`: the children take part in the layout
    // around the gate exactly as they would have without it.
    expect(await displayAt(1000)).toBe('contents');
  });

  it('opens at its floor and stays open above it', async () => {
    await render(
      <PlShow data-testid="gate" from="md">
        <span>Wide</span>
      </PlShow>
    );

    expect(await displayAt(500)).toBe('none');
    // 768px is 48rem, the floor of `md` — the rung it is named for, not one above.
    expect(await displayAt(768)).toBe('contents');
    expect(await displayAt(1400)).toBe('contents');
  });

  it('closes at its ceiling, exclusively', async () => {
    await render(
      <PlShow data-testid="gate" until="md">
        <span>Narrow</span>
      </PlShow>
    );

    // Exclusive, so `until="md"` and `from="md"` are the two halves of one
    // decision: no width draws both and none draws neither.
    expect(await displayAt(500)).toBe('contents');
    expect(await displayAt(768)).toBe('none');
  });

  it('takes both bounds as a band', async () => {
    await render(
      <PlShow data-testid="gate" from="sm" until="lg">
        <span>Middle</span>
      </PlShow>
    );

    expect(await displayAt(500)).toBe('none');
    expect(await displayAt(700)).toBe('contents');
    expect(await displayAt(900)).toBe('contents');
    expect(await displayAt(1100)).toBe('none');
  });

  it('shows everywhere when it was given no bound at all', async () => {
    await render(
      <PlShow data-testid="gate">
        <span>Always</span>
      </PlShow>
    );

    expect(await displayAt(500)).toBe('contents');
    expect(await displayAt(1400)).toBe('contents');
  });

  it('keeps what it hides in the document and off the accessibility tree', async () => {
    const screen = await render(
      <PlShow data-testid="gate" from="lg">
        <button type="button">Filters</button>
      </PlShow>
    );

    await page.viewport(500, 600);

    // Both halves of a responsive layout are sent; `display: none` is what stops
    // one of them being drawn, read out, or tabbed into.
    expect(document.querySelector('[data-testid="gate"] button')).not.toBeNull();
    await expect.poll(() => screen.getByRole('button').query()).toBeNull();
  });
});
