/**
 * That the two light layers actually resolve to something drawable.
 *
 * `.plass-glow` is written in `src/styles.css` and painted on `::before` and
 * `::after`, so none of it can be read off the element a component test has —
 * and all three ways it fails are silent. A missing `--p-glow` leaves a gradient
 * that runs transparent to transparent, which paints nothing and throws nothing.
 * A missing `position: relative` hangs the layers off some ancestor, which draws
 * a bloom in the wrong box. A class on the wrong element draws the bloom over
 * the page instead of over the control. Every one of those passes a class-list
 * assertion, which is why this file loads the stylesheet.
 *
 * It asserts no design value — not a radius, a shade or a duration. Those move
 * with the design language, and a test that pins them turns a decision into a
 * failure. What is pinned here is that each piece reaches the next one.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlButton, PlTextField } from 'plass-ui';
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

/** The colour of the bloom's first stop, as the browser resolved it. */
function firstStop(layer: CSSStyleDeclaration): string {
  const [, stop] = /,\s*([^,]+),/.exec(layer.backgroundImage) ?? [];

  return stop ?? '';
}

describe('the interaction light', () => {
  it('resolves a colour on a key, whose slots come from `controlSlots`', async () => {
    const screen = await render(<PlButton>Save</PlButton>);
    const key = screen.getByRole('button').element() as HTMLElement;
    const bloom = getComputedStyle(key, '::before');

    expect(bloom.content).toBe('""');
    // Nothing is painted until a pointer arrives, which is what makes a page of
    // controls nobody is touching free.
    expect(bloom.opacity).toBe('0');
    expect(getComputedStyle(key).position).toBe('relative');
    expect(firstStop(bloom)).not.toBe('rgba(0, 0, 0, 0)');
  });

  it('resolves one on a field, whose slots come from `surfaceSlots`', async () => {
    await render(<PlTextField label="City" classNames={{ control: 'lit-under-test' }} />);

    const shell = document.querySelector('.lit-under-test') as HTMLElement;
    const bloom = getComputedStyle(shell, '::before');

    expect(bloom.content).toBe('""');
    expect(bloom.opacity).toBe('0');
    expect(getComputedStyle(shell).position).toBe('relative');
    expect(firstStop(bloom)).not.toBe('rgba(0, 0, 0, 0)');
  });

  it('moves both layers to wherever the pointer was written', async () => {
    await render(<PlTextField label="City" classNames={{ control: 'lit-under-test' }} />);

    const shell = document.querySelector('.lit-under-test') as HTMLElement;
    const centred = getComputedStyle(shell, '::before').backgroundImage;

    shell.dispatchEvent(
      new PointerEvent('pointermove', { bubbles: true, clientX: 42, clientY: 11 })
    );

    const moved = getComputedStyle(shell, '::before').backgroundImage;
    const flash = getComputedStyle(shell, '::after').backgroundImage;

    expect(moved).not.toBe(centred);
    // Both read the same two slots, so the press lands where the bloom is
    // rather than in the middle of the box.
    expect(/at ([\d.]+px [\d.]+px)/.exec(moved)?.[1]).toBe(
      /at ([\d.]+px [\d.]+px)/.exec(flash)?.[1]
    );
  });

  it('paints the bloom under what is written on the surface and the flash over it', async () => {
    const screen = await render(<PlButton>Save</PlButton>);
    const key = screen.getByRole('button').element() as HTMLElement;

    // A positioned pseudo-element paints above in-flow content, so without the
    // negative depth the bloom is laid over the label — faint on a white one and
    // not on dark ink, which is what a field is written in.
    expect(getComputedStyle(key, '::before').zIndex).toBe('-1');
    expect(getComputedStyle(key, '::after').zIndex).toBe('auto');
    // And the depth only means anything inside a stacking context the surface
    // owns; without one it falls through to whatever ancestor has the nearest.
    expect(getComputedStyle(key).isolation).toBe('isolate');
  });

  it('draws no layers at all on a field that is locked', async () => {
    await render(<PlTextField label="City" disabled classNames={{ control: 'lit-under-test' }} />);

    const shell = document.querySelector('.lit-under-test') as HTMLElement;

    expect(getComputedStyle(shell, '::before').content).toBe('none');
  });
});
