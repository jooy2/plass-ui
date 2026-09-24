/**
 * Whether a floating `PlBackTop` floats, which only the stylesheet can answer.
 *
 * The button is a `PlIconButton`, and `PlButton`'s own `relative` comes after
 * any `fixed` utility in `src/styles.css` and wins at the same specificity. So
 * a `fixed` class on this button never pinned it, and no component test could
 * have said so: without the real CSS loaded a utility is a name and nothing
 * else. Loaded the way `code-block.test.tsx` loads it.
 *
 * The same goes for the side of the safe area it clears: `env()` has only
 * physical names, so the inline end is picked by an `rtl:` class. Chromium is
 * given a safe area through the DevTools protocol, as
 * `floating-action-button.test.tsx` gives it one, and the resolved insets are
 * read.
 */
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { cdp, server } from 'vitest/browser';
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
    expect(button().style.insetInlineEnd).toContain('var(--p-safe-inline');
    // `env()` has only physical names, so the class says which one the end is:
    // the right, and the left once the page runs right to left.
    expect(button().className).toContain('[--p-safe-inline:env(safe-area-inset-right,0px)]');
    expect(button().className).toContain('rtl:[--p-safe-inline:env(safe-area-inset-left,0px)]');
  });

  it('but sits in the flow with floating off', async () => {
    await render(<PlBackTop floating={false} />);

    expect(getComputedStyle(button()).position).not.toBe('fixed');
    expect(button().style.insetBlockEnd).toBe('');
    expect(button().className).not.toContain('--p-safe-inline');
  });
});

/** A different number on every edge, so a wrong side cannot pass by accident. */
const INSETS = { top: 20, left: 40, bottom: 30, right: 10 };

/** What a desktop browser reports with no cutout and no home indicator. */
const NONE = { top: 0, left: 0, bottom: 0, right: 0 };

const setSafeArea = (insets: typeof INSETS) =>
  cdp().send('Emulation.setSafeAreaInsetsOverride', { insets });

describe('a floating PlBackTop on an edge-to-edge screen', () => {
  // The protocol call is Chromium's. The declarations it resolves are plain
  // CSS, and the tests above read them in every engine.
  const emulated = it.runIf(server.browser === 'chromium');

  afterEach(async () => {
    if (server.browser === 'chromium') {
      await setSafeArea(NONE);
    }
  });

  emulated('stands the safe area and the 24px off the bottom and the end', async () => {
    await setSafeArea(INSETS);
    await render(<PlBackTop />);

    // The home indicator, and the cutout of a screen held on its side.
    expect(getComputedStyle(button()).bottom).toBe('54px');
    expect(getComputedStyle(button()).right).toBe('34px');
  });

  emulated('takes the safe area of the other side once the page runs right to left', async () => {
    await setSafeArea(INSETS);
    await render(
      <div dir="rtl">
        <PlBackTop />
      </div>
    );

    // The end is on the left now, and so is the edge whose inset it clears.
    expect(getComputedStyle(button()).left).toBe('64px');
  });
});
