/**
 * Where a floating `PlFloatingActionButton` lands on a screen with a safe area,
 * which only the stylesheet and the browser can answer together.
 *
 * `env()` has only physical names, so the inline side the button is against is
 * picked by an `rtl:` class, and without the real CSS loaded that class is a
 * name and nothing else. The browser running the suite has no safe area of its
 * own, so Chromium is given one through the DevTools protocol and the button's
 * resolved insets are read. Loaded the way `back-top.test.tsx` loads it.
 */
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { cdp, server } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlFloatingActionButton } from 'plass-ui';
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

function Plus() {
  return <svg viewBox="0 0 16 16" />;
}

/** A different number on every edge, so a wrong side cannot pass by accident. */
const INSETS = { top: 20, left: 40, bottom: 30, right: 10 };

/** What a desktop browser reports with no cutout and no home indicator. */
const NONE = { top: 0, left: 0, bottom: 0, right: 0 };

const setSafeArea = (insets: typeof INSETS) =>
  cdp().send('Emulation.setSafeAreaInsetsOverride', { insets });

describe('a floating PlFloatingActionButton on an edge-to-edge screen', () => {
  // The protocol call is Chromium's. The declarations it resolves are plain
  // CSS, and `PlFloatingActionButton.test.tsx` reads them in every engine.
  const emulated = it.runIf(server.browser === 'chromium');

  afterEach(async () => {
    if (server.browser === 'chromium') {
      await setSafeArea(NONE);
    }
  });

  emulated('stands the safe area and the offset off the bottom and the end', async () => {
    await setSafeArea(INSETS);
    await render(<PlFloatingActionButton icon={<Plus />} label="New" />);

    // 24px off each edge, and the home indicator and the cutout on top.
    expect(getComputedStyle(button()).bottom).toBe('54px');
    expect(getComputedStyle(button()).right).toBe('34px');
  });

  emulated('takes the safe area of the other side once the page runs right to left', async () => {
    await setSafeArea(INSETS);
    await render(
      <div dir="rtl">
        <PlFloatingActionButton icon={<Plus />} label="New" />
      </div>
    );

    // The end is on the left now, and so is the edge whose inset it clears.
    expect(getComputedStyle(button()).left).toBe('64px');
  });

  emulated('clears the top and the start when it is in that corner', async () => {
    await setSafeArea(INSETS);
    await render(<PlFloatingActionButton corner="top-start" icon={<Plus />} label="New" />);

    expect(getComputedStyle(button()).top).toBe('44px');
    expect(getComputedStyle(button()).left).toBe('64px');
  });

  emulated('adds the safe area to an offset of its own', async () => {
    await setSafeArea(INSETS);
    await render(<PlFloatingActionButton offset={8} icon={<Plus />} label="New" />);

    expect(getComputedStyle(button()).bottom).toBe('38px');
    expect(getComputedStyle(button()).right).toBe('18px');
  });
});
