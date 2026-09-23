/**
 * Whether a page can keep its end clear of a fixed bottom bar, which only the
 * stylesheet can answer.
 *
 * A `fixed` `PlBottomNavigation` publishes its height as
 * `--plass-bottom-navigation-height`, and the docs tell a page to reserve it
 * with two declarations. This checks the two declarations do what the docs say
 * with real heights under them: the last of the page scrolls clear of the bar,
 * and a link reached with Tab stops above it rather than underneath. Loaded the
 * way `back-top.test.tsx` loads the stylesheet.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlBottomNavigation, PlBottomNavigationItem } from 'plass-ui';
import type { PlassSize } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent =
    standaloneCss +
    // The two declarations the docs give, word for word.
    '.page-under-test { padding-bottom: var(--plass-bottom-navigation-height); }' +
    'html { scroll-padding-bottom: var(--plass-bottom-navigation-height); }';
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
  window.scrollTo(0, 0);
});

function Page({ size }: { size?: PlassSize }) {
  return (
    <>
      <main className="page-under-test">
        <div style={{ height: '200vh' }} />
        <a href="#end">The last link</a>
      </main>
      <PlBottomNavigation className="bar-under-test" size={size}>
        <PlBottomNavigationItem value="home">Home</PlBottomNavigationItem>
        <PlBottomNavigationItem value="search">Search</PlBottomNavigationItem>
      </PlBottomNavigation>
    </>
  );
}

const bar = () => document.querySelector<HTMLElement>('.bar-under-test')!;
const link = () => document.querySelector<HTMLAnchorElement>('a[href="#end"]')!;

describe('a page under a fixed PlBottomNavigation', () => {
  it('scrolls its last line clear of the bar', async () => {
    await render(<Page />);

    window.scrollTo(0, document.documentElement.scrollHeight);

    await expect
      .poll(() => link().getBoundingClientRect().bottom)
      .toBeLessThanOrEqual(bar().getBoundingClientRect().top);
  });

  it('stops a link reached with the keyboard above the bar', async () => {
    await render(<Page />);

    window.scrollTo(0, 0);
    link().focus();

    await expect
      .poll(() => link().getBoundingClientRect().bottom)
      .toBeLessThanOrEqual(bar().getBoundingClientRect().top);
  });

  it('reserves as much as the bar takes when it changes size', async () => {
    const screen = await render(<Page size="sm" />);
    const small = bar().getBoundingClientRect().height;

    await screen.rerender(<Page size="xl" />);

    const large = bar().getBoundingClientRect().height;

    expect(large).toBeGreaterThan(small);
    await expect
      .poll(() =>
        document.documentElement.style.getPropertyValue('--plass-bottom-navigation-height')
      )
      .toBe(`${large}px`);
  });
});
