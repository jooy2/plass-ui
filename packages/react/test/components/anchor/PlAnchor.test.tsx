/**
 * The tracking is a measurement of where each heading sits against the top of
 * the window, so nothing here is stubbed — and nothing scrolls the window
 * either. The page is *moved* under a fixed viewport with a negative margin,
 * which puts the headings exactly where a scroll would and leaves the runner's
 * own document where it found it.
 *
 * One rule is deliberately **not** covered here: that the last row is lit once
 * the page is scrolled to its bottom. It is the only part of the tracking that
 * asks about the window's position rather than a heading's, and asserting it
 * means scrolling the runner's own document — which leaves the browser session
 * unstable for the files that run after this one. The Dart suite scrolls a
 * `ScrollController` inside its own test surface and covers it there. A panel
 * given as `target` is scrolled for real, bottom included, because scrolling
 * an element of its own leaves the runner's document alone.
 */
import * as React from 'react';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnchor, type PlAnchorItem } from 'plass-ui';

const items: PlAnchorItem[] = [
  { href: '#one', label: 'One' },
  { href: '#two', label: 'Two', depth: 1 },
  { href: '#three', label: 'Three' }
];

/**
 * A page tall enough to scroll, with the three headings in it.
 *
 * `past` is how far the reader has got, as a negative margin: the headings end
 * up where scrolling that far would put them, and `window.scrollY` never moves.
 */
function Page({
  offset = 0,
  active,
  past = 0,
  extra = []
}: {
  offset?: number;
  active?: string;
  past?: number;
  extra?: PlAnchorItem[];
}) {
  return (
    <div style={{ marginTop: `${-past}px` }}>
      <PlAnchor
        className="anchor-under-test"
        items={[...extra, ...items]}
        offset={offset}
        active={active}
      />
      <div style={{ height: '400px' }} />
      <h2 id="one">One</h2>
      <div style={{ height: '1200px' }} />
      <h2 id="two">Two</h2>
      <div style={{ height: '1200px' }} />
      <h2 id="three">Three</h2>
      <div style={{ height: '1200px' }} />
    </div>
  );
}

const panelItems: PlAnchorItem[] = [
  { href: '#panel-one', label: 'One' },
  { href: '#panel-two', label: 'Two' },
  { href: '#panel-three', label: 'Three' }
];

/**
 * An app shell's `<main>`: a box that scrolls on its own, halfway down the
 * screen, with the headings inside it. The window never moves. The last section
 * is short, so the box's bottom comes before its heading reaches the line.
 */
function Panel({ offset = 0 }: { offset?: number }) {
  const panel = React.useRef<HTMLDivElement>(null);

  return (
    <div>
      <PlAnchor className="anchor-under-test" items={panelItems} target={panel} offset={offset} />
      <div style={{ height: '200px' }} />
      <div ref={panel} className="panel-under-test" style={{ height: '300px', overflowY: 'auto' }}>
        <div style={{ height: '400px' }} />
        <h2 id="panel-one" style={{ margin: 0 }}>
          One
        </h2>
        <div style={{ height: '1200px' }} />
        <h2 id="panel-two" style={{ margin: 0 }}>
          Two
        </h2>
        <div style={{ height: '1200px' }} />
        <h2 id="panel-three" style={{ margin: 0 }}>
          Three
        </h2>
        <div style={{ height: '100px' }} />
      </div>
    </div>
  );
}

/** Scrolls the panel under test to `top`. */
function scrollPanel(top: number) {
  document.querySelector<HTMLElement>('.panel-under-test')!.scrollTop = top;
}

/** The list under test. */
function anchor(): HTMLElement {
  return document.querySelector<HTMLElement>('.anchor-under-test')!;
}

function rows(): HTMLAnchorElement[] {
  return Array.from(anchor().querySelectorAll<HTMLAnchorElement>('a'));
}

/** Which row is lit, by its text. */
function lit(): string | undefined {
  return (
    rows().find((row) => row.getAttribute('aria-current') === 'location')?.textContent ?? undefined
  );
}

describe('PlAnchor', () => {
  describe('the list', () => {
    it('draws one link per heading, in document order', async () => {
      await render(<Page />);

      expect(rows().map((row) => row.textContent)).toEqual(['One', 'Two', 'Three']);
      expect(rows().map((row) => row.getAttribute('href'))).toEqual(['#one', '#two', '#three']);
    });

    it('indents by depth rather than nesting', async () => {
      await render(<Page />);

      // Real documents skip levels, so a nesting built from a flat list is a
      // guess at a shape nobody wrote.
      expect(anchor().querySelectorAll('ul').length).toBe(1);
      expect(rows()[0].style.paddingInlineStart).toBe('calc(0.5rem)');
      expect(rows()[1].style.paddingInlineStart).toBe('calc(1.25rem)');
    });

    it('names the region so it is not one more unnamed navigation', async () => {
      await render(<Page />);

      expect(anchor().getAttribute('aria-label')).toBe('On this page');
    });
  });

  describe('the tracking', () => {
    it('lights nothing above the first heading', async () => {
      await render(<Page />);

      // The reader has not reached a section yet.
      await expect.poll(() => lit()).toBeUndefined();
    });

    it('lights a heading once its top has passed the line', async () => {
      await render(<Page past={600} />);

      await expect.poll(() => lit()).toBe('One');
    });

    it('moves on at the next one', async () => {
      await render(<Page past={1900} />);

      await expect.poll(() => lit()).toBe('Two');
    });

    it('lights the one above while the next is still on screen', async () => {
      // Two headings visible at once. The one being read is the higher of them,
      // which is already above the reader.
      await render(<Page past={1500} />);

      await expect.poll(() => lit()).toBe('One');
    });

    it('has not reached a heading that is still under the top of the window', async () => {
      await render(<Page past={400} />);

      await expect.poll(() => lit()).toBeUndefined();
    });

    it('has reached the same one under a 300px bar', async () => {
      // The heading has already slid out of sight behind the bar, and a list
      // that still called it "next" would sit a section behind the reader for
      // the height of it.
      await render(<Page past={400} offset={300} />);

      await expect.poll(() => lit()).toBe('One');
    });

    it('skips an item whose heading is not there rather than throwing', async () => {
      await render(<Page past={600} extra={[{ href: '#missing', label: 'Missing' }]} />);

      await expect.poll(() => lit()).toBe('One');
    });

    it('leaves a page that fits on the screen to the measurement', async () => {
      await render(
        <div>
          <PlAnchor className="anchor-under-test" items={items} />
          <h2 id="short-one">One</h2>
        </div>
      );

      // A document with nothing to scroll is always at its own bottom, and
      // lighting the last row there would say the reader had reached the end
      // before they had read anything.
      await expect.poll(() => lit()).toBeUndefined();
    });
  });

  describe('a panel as the target', () => {
    it('lights a heading once it has passed the top of the panel', async () => {
      await render(<Panel />);

      scrollPanel(600);

      await expect.poll(() => lit()).toBe('One');
    });

    it('moves on at the next one as the panel scrolls', async () => {
      await render(<Panel />);

      scrollPanel(1700);

      await expect.poll(() => lit()).toBe('Two');
    });

    it('measures the offset from the top of the panel, not of the window', async () => {
      // The heading is 100px under the panel's top, and the panel is well
      // over 150px down the screen: only the panel's line has passed it.
      await render(<Panel offset={150} />);

      scrollPanel(300);

      await expect.poll(() => lit()).toBe('One');
    });

    it('lights the last row once the panel is at its bottom', async () => {
      await render(<Panel />);

      // The short last section never reaches the line.
      scrollPanel(100_000);

      await expect.poll(() => lit()).toBe('Three');
    });
  });

  describe('taking it over', () => {
    it('lights what it was told to and stops measuring', async () => {
      // The measurement would say "One" at this position.
      await render(<Page active="#three" past={600} />);

      await expect.poll(() => lit()).toBe('Three');
    });

    it('reports a click before the browser moves', async () => {
      const onSelect = vi.fn();

      await render(<PlAnchor className="anchor-under-test" items={items} onSelect={onSelect} />);

      rows()[1].click();

      expect(onSelect).toHaveBeenCalledWith(
        expect.objectContaining({ href: '#two' }),
        expect.anything()
      );
    });
  });
});
