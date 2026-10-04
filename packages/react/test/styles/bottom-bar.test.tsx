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
import * as React from 'react';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlBottomNavigation,
  PlBottomNavigationItem,
  PlFloatingBottomNavigation,
  PlFloatingBottomNavigationItem
} from 'plass-ui';
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

/**
 * A fixed bar inside a `transform`, as a bar inside a scaled `PlMockup` is, is
 * fixed to that box rather than to the window, and covers only what is laid out
 * in it, in the same pixels the bar is laid out in. So what it publishes is the
 * height it is laid out at, which is twice the height it is drawn at here: the
 * same number it publishes with no transform above it.
 */
describe('a fixed bar inside a scaled ancestor', () => {
  const glyph = <svg viewBox="0 0 24 24" />;

  const bars: Record<string, (size: PlassSize) => React.ReactElement> = {
    PlBottomNavigation: (size) => (
      <PlBottomNavigation className="bar-under-test" size={size}>
        <PlBottomNavigationItem value="home">Home</PlBottomNavigationItem>
        <PlBottomNavigationItem value="search">Search</PlBottomNavigationItem>
      </PlBottomNavigation>
    ),
    PlFloatingBottomNavigation: (size) => (
      <PlFloatingBottomNavigation label="Main" className="bar-under-test" size={size}>
        <PlFloatingBottomNavigationItem value="home" icon={glyph}>
          Home
        </PlFloatingBottomNavigationItem>
        <PlFloatingBottomNavigationItem value="search" icon={glyph}>
          Search
        </PlFloatingBottomNavigationItem>
      </PlFloatingBottomNavigation>
    )
  };

  const published = () =>
    document.documentElement.style.getPropertyValue('--plass-bottom-navigation-height');

  function Scaled({ children }: { children: React.ReactNode }) {
    return <div style={{ transform: 'scale(0.5)', transformOrigin: '0 0' }}>{children}</div>;
  }

  /** What the bar publishes at `size` with nothing scaling it. */
  async function unscaled(of: (size: PlassSize) => React.ReactElement, size: PlassSize) {
    const screen = await render(of(size));
    const height = published();

    await screen.unmount();

    return height;
  }

  it.each(Object.keys(bars))('publishes the height it is laid out at, %s', async (name) => {
    const expected = await unscaled(bars[name], 'md');

    await render(<Scaled>{bars[name]('md')}</Scaled>);

    // The transform reaches the bar: it is drawn at half the height it takes.
    expect(bar().getBoundingClientRect().height * 2).toBeCloseTo(parseFloat(expected), 1);
    expect(published()).toBe(expected);
  });

  it.each(Object.keys(bars))('follows it when it changes size, %s', async (name) => {
    const expected = await unscaled(bars[name], 'xl');
    const screen = await render(<Scaled>{bars[name]('sm')}</Scaled>);

    await screen.rerender(<Scaled>{bars[name]('xl')}</Scaled>);

    await expect.poll(published).toBe(expected);
  });

  it('still publishes the exact box on the screen with nothing scaling it', async () => {
    // A height no browser lays out exactly, which the computed style then
    // writes to fewer decimals than the box on the screen has.
    await render(
      <PlBottomNavigation
        className="bar-under-test"
        style={{ height: '41.17px', paddingBottom: '3.3px', boxSizing: 'content-box' }}
      />
    );

    expect(published()).toBe(`${bar().getBoundingClientRect().height}px`);
  });
});
