/**
 * Which way `PlCodeBlock theme="auto"` goes, which the stylesheet decides.
 *
 * `auto` is the one theme that has no colours of its own: it takes the page's,
 * and the page says which it is in four ways — the system preference, a `.dark`
 * or `.light` class, and a `data-theme` attribute. The component writes only
 * `data-code-theme="auto"`, so every one of those answers is a selector in
 * `src/styles.css` and none of them can be asserted from the component test.
 *
 * Loaded the way `marquee.test.tsx` loads it, and asserting the same way: the
 * `auto` block is compared against what `light` and `dark` resolve to rather
 * than against a shade, because the shades belong to the design language.
 */
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlCodeBlock } from 'plass-ui';
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
  await emulateMedia({ colorScheme: 'no-preference' });
  document.documentElement.classList.remove('light', 'dark');
  document.documentElement.removeAttribute('data-theme');
});

/** The ground the two house themes paint, for the `auto` block to be compared against. */
async function groundOf(theme: 'light' | 'dark'): Promise<string> {
  const screen = await render(<PlCodeBlock theme={theme} code="const one = 1;" />);
  const element = screen.container.querySelector('.plass-code') as HTMLElement;

  return getComputedStyle(element).getPropertyValue('--p-code-bg').trim();
}

/** The ground `auto` resolves to with the page in whatever state the test has put it. */
async function autoGround(): Promise<string> {
  const screen = await render(<PlCodeBlock theme="auto" code="const one = 1;" />);
  const element = screen.container.querySelector('.plass-code') as HTMLElement;

  return getComputedStyle(element).getPropertyValue('--p-code-bg').trim();
}

describe('the code block stylesheet', () => {
  it('follows the system preference when the page has said nothing', async () => {
    await emulateMedia({ colorScheme: 'dark' });
    expect(await autoGround()).toBe(await groundOf('dark'));

    await emulateMedia({ colorScheme: 'light' });
    expect(await autoGround()).toBe(await groundOf('light'));
  });

  it('follows a page forced dark against a light system', async () => {
    await emulateMedia({ colorScheme: 'light' });

    document.documentElement.classList.add('dark');
    expect(await autoGround()).toBe(await groundOf('dark'));

    document.documentElement.classList.remove('dark');
    document.documentElement.setAttribute('data-theme', 'dark');
    expect(await autoGround()).toBe(await groundOf('dark'));
  });

  it('follows a page forced light against a dark system, by the class as well as the attribute', async () => {
    await emulateMedia({ colorScheme: 'dark' });

    document.documentElement.setAttribute('data-theme', 'light');
    expect(await autoGround()).toBe(await groundOf('light'));

    document.documentElement.removeAttribute('data-theme');
    document.documentElement.classList.add('light');
    expect(await autoGround()).toBe(await groundOf('light'));
  });
});
