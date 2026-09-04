/**
 * That the library still runs the other way.
 *
 * A test of a *contract* rather than of a component, which is why it is here
 * rather than under `test/components/`: RTL is not a feature any one component
 * has, it is a rule every one of them follows — **`start`/`end`, never
 * `left`/`right`** — and the way that rule breaks is one component at a time,
 * quietly, in a class name nobody looked at twice.
 *
 * So there are two halves. The first drives a real `dir="rtl"` document, which
 * is the only way to check the handful of places that read the direction in
 * JavaScript. The second reads every component's source and fails on a physical
 * direction utility that is not on the list below — that is the half that
 * catches the *next* component, and it is the reason a component test would not
 * have done.
 */
import type * as React from 'react';
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnimateMarquee, PlPane, PlPanes, PlassProvider, PlSlider } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';

afterEach(() => {
  document.documentElement.removeAttribute('dir');
});

/** The whole document, because `direction` is inherited and read off the root. */
function setDirection(dir: 'ltr' | 'rtl') {
  document.documentElement.setAttribute('dir', dir);
}

function bases(): string[] {
  return Array.from(
    document.querySelectorAll<HTMLElement>('.split-under-test > div:not([role="separator"])')
  ).map((element) => element.style.flex);
}

function handle(): HTMLElement {
  return document.querySelector<HTMLElement>('[role="separator"]')!;
}

function Split({ children }: { children: React.ReactNode }) {
  return (
    <div style={{ width: '400px', height: '200px' }}>
      <PlPanes className="split-under-test">{children}</PlPanes>
    </div>
  );
}

async function press(key: string): Promise<void> {
  (document.activeElement as HTMLElement | null)?.dispatchEvent(
    new KeyboardEvent('keydown', { key, bubbles: true, cancelable: true })
  );

  await new Promise((resolve) => setTimeout(resolve, 0));
}

describe('a document that runs the other way', () => {
  it('is what the browser reports', async () => {
    setDirection('rtl');

    await render(<span />);

    // If this ever stops being true the rest of the file is asserting nothing:
    // every JavaScript read of the direction goes through `getComputedStyle`.
    expect(getComputedStyle(document.documentElement).direction).toBe('rtl');
  });

  it("moves a PlPanes handle the way the reader's arrow key points", async () => {
    setDirection('ltr');

    const first = await render(
      <Split>
        <PlPane>One</PlPane>
        <PlPane>Two</PlPane>
      </Split>
    );

    handle().focus();
    await press('ArrowRight');

    const ltr = bases()[0];

    await first.unmount();
    setDirection('rtl');

    await render(
      <Split>
        <PlPane>One</PlPane>
        <PlPane>Two</PlPane>
      </Split>
    );

    handle().focus();
    await press('ArrowRight');

    // The same key, the opposite result. A handle that moved the same way in
    // both would be moving away from the arrow half the time.
    expect(bases()[0]).not.toBe(ltr);
  });
});

/* ---------------------------------------------------------------------------
 * The half CSS cannot do
 *
 * Base UI reads the direction from a React context and from nowhere else — with
 * no provider its `useDirection()` answers `ltr` however the document is
 * written. That decides a slider's arrow keys, the way a composite walks under
 * ←/→ and how a popup's logical `align` resolves, so a page that set `dir` and
 * stopped would *look* right and *behave* the other way round. `PlassProvider`
 * is the wire, and these are the tests that it is connected.
 * ------------------------------------------------------------------------- */

async function slide(dir: 'ltr' | 'rtl', provider: boolean): Promise<string | null> {
  setDirection(dir);

  const slider = <PlSlider label="Volume" defaultValue={40} step={5} />;
  const screen = await render(provider ? <PlassProvider>{slider}</PlassProvider> : slider);
  const thumb = screen.getByRole('slider').element() as HTMLElement;

  thumb.focus();
  await expect.poll(() => document.activeElement).toBe(thumb);
  thumb.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true }));
  await expect.poll(() => thumb.getAttribute('aria-valuenow')).not.toBe('40');

  const value = thumb.getAttribute('aria-valuenow');

  await screen.unmount();

  return value;
}

describe('a PlassProvider carries the direction to the behaviour', () => {
  it("turns a PlSlider's arrow keys over", async () => {
    expect(await slide('ltr', true)).toBe('45');

    // The same key, back down the range: under RTL the right-hand end of the
    // run is the minimum, so an arrow pointing at it counts down.
    expect(await slide('rtl', true)).toBe('35');
  });

  it('says so where a subtree runs the other way from the page', async () => {
    setDirection('ltr');

    const screen = await render(
      <PlassProvider direction="rtl">
        <PlSlider label="Volume" defaultValue={40} step={5} />
      </PlassProvider>
    );
    const thumb = screen.getByRole('slider').element() as HTMLElement;

    thumb.focus();
    await expect.poll(() => document.activeElement).toBe(thumb);
    thumb.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true }));

    // The prop wins over the document, which is the only reason to have it: a
    // panel of Arabic inside an English page is a subtree, not a page.
    await expect.poll(() => thumb.getAttribute('aria-valuenow')).toBe('35');
  });

  it('keeps what a nested provider did not say', async () => {
    setDirection('ltr');

    const screen = await render(
      <PlassProvider direction="rtl">
        <PlassProvider size="sm">
          <PlSlider label="Volume" defaultValue={40} step={5} />
        </PlassProvider>
      </PlassProvider>
    );
    const thumb = screen.getByRole('slider').element() as HTMLElement;

    thumb.focus();
    await expect.poll(() => document.activeElement).toBe(thumb);
    thumb.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true }));

    await expect.poll(() => thumb.getAttribute('aria-valuenow')).toBe('35');
  });
});

/* ---------------------------------------------------------------------------
 * The half a class name cannot carry
 *
 * There is no logical `translate`, so the one animation that travels along the
 * inline axis flips its sign in the stylesheet. That makes it the one RTL rule
 * in the library a component test cannot see, because no component test loads
 * CSS — so this one loads the shipped sheet.
 * ------------------------------------------------------------------------- */

describe('the stylesheet turns the marquee round', () => {
  let sheet: HTMLStyleElement;

  beforeAll(() => {
    sheet = document.createElement('style');
    sheet.textContent = standaloneCss;
    document.head.append(sheet);
  });

  afterAll(() => sheet.remove());

  async function along(dir: 'ltr' | 'rtl'): Promise<string> {
    setDirection(dir);

    await render(
      <PlAnimateMarquee>
        <span>Now boarding</span>
      </PlAnimateMarquee>
    );

    const track = document.querySelector('.plass-marquee-track')!;

    return getComputedStyle(track).getPropertyValue('--p-anim-along').trim();
  }

  it('leaves a left-to-right strip travelling left', async () => {
    // Unset, and that is the default the keyframe multiplies by.
    expect(await along('ltr')).toBe('');
  });

  it('sends a right-to-left strip the other way', async () => {
    expect(await along('rtl')).toBe('-1');
  });
});

/* ---------------------------------------------------------------------------
 * The half that catches the next component
 * ------------------------------------------------------------------------- */

const sources = import.meta.glob('../../src/{components/*,internal}/*.{ts,tsx}', {
  query: '?raw',
  import: 'default',
  eager: true
});

const name = (path: string) => path.replace(/^.*\/src\//, 'src/');

/** Comments out. Half of this repository's prose is about left and right. */
const code = (source: string) =>
  source.replace(/\/\*[\s\S]*?\*\//g, '').replace(/(^|[^:])\/\/.*$/gm, '$1');

/**
 * Tailwind's physical direction utilities — the ones with a logical twin that
 * flips.
 *
 * Two families are deliberately absent. `top-`, `bottom-` and `inset-y-` have
 * no logical twin worth having: a tooltip above a button is above it in every
 * writing direction. And the **symmetric** ones — `inset-x-`, `px-`, `mx-` —
 * name both sides at once, so there is nothing for a direction to swap.
 */
const PHYSICAL = /\b(?:rounded-[lr]-|border-[lr]-|text-left|text-right|[pm][lr]-|left-|right-)/;

/**
 * The files that reach for a physical property on purpose, and what each one
 * buys by it. Short, and every entry is a place where the *thing being measured*
 * is physical too — pairing a logical property with `offsetLeft` is what would
 * actually break the direction.
 */
const deliberate: Record<string, string> = {
  'src/components/tabs/PlTabs.tsx':
    'the moving indicator is placed from `offsetLeft`, which is a distance from the left edge in both directions',
  'src/components/segmented-button/PlSegmentedButton.tsx':
    'the gradient tile is placed from `offsetLeft`, as above',
  'src/components/floating-bottom-navigation/PlFloatingBottomNavigation.tsx':
    'the disc is placed from `offsetLeft`, as above',
  'src/components/drawer/PlDrawer.tsx':
    "a drawer's `side` is physical — `PlassSide` is — so the corners it rounds are too",
  'src/components/tooltip/PlTooltip.tsx':
    "the arrow is placed against Base UI's own physical `data-side`",
  'src/components/popover/PlPopover.tsx':
    "the arrow is placed against Base UI's `data-side`, as above",
  'src/components/hover-card/PlHoverCard.tsx':
    "the arrow is placed against Base UI's `data-side`, as above"
};

describe('every component uses logical properties', () => {
  it.each(Object.entries(sources))('%s', (path, source) => {
    const file = name(path);
    const offenders = (code(source as string).match(new RegExp(PHYSICAL, 'g')) ?? []).filter(
      () => !(file in deliberate)
    );

    expect({ file, offenders }).toEqual({ file, offenders: [] });
  });

  it.each(Object.entries(deliberate))('%s is physical on purpose', (file, why) => {
    const entry = Object.entries(sources).find(([path]) => name(path) === file);

    expect(entry, `${file} is listed as deliberate and is not a source module`).toBeDefined();

    // And it still is: an entry that has been cleaned up should leave the list
    // rather than sitting here excusing nothing.
    expect({ file, why, physical: PHYSICAL.test(code(entry![1] as string)) }).toEqual({
      file,
      why,
      physical: true
    });
  });
});
