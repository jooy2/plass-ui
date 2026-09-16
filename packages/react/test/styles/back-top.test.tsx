/**
 * Whether a floating `PlBackTop` floats, which only the stylesheet can answer.
 *
 * The button is a `PlIconButton`, and `PlButton`'s own `relative` comes after
 * any `fixed` utility in `src/styles.css` and wins at the same specificity. So
 * a `fixed` class on this button never pinned it, and no component test could
 * have said so: without the real CSS loaded a utility is a name and nothing
 * else. Loaded the way `code-block.test.tsx` loads it.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlBackTop } from 'plass-ui';
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

const button = () => document.querySelector<HTMLButtonElement>('button[aria-label]')!;

describe('a floating PlBackTop', () => {
  it('is pinned over the page', async () => {
    await render(<PlBackTop />);

    expect(getComputedStyle(button()).position).toBe('fixed');
  });

  it('holds itself clear of the safe area', async () => {
    await render(<PlBackTop />);

    // The home indicator or the navigation bar of an edge-to-edge screen, on
    // top of the 24px the button sits off the corner. The browser running the
    // test has no safe area, so the declaration is read rather than its
    // resolved length.
    expect(button().style.insetBlockEnd).toContain('env(safe-area-inset-bottom');
  });

  it('but sits in the flow with floating off', async () => {
    await render(<PlBackTop floating={false} />);

    expect(getComputedStyle(button()).position).not.toBe('fixed');
    expect(button().style.insetBlockEnd).toBe('');
  });
});
