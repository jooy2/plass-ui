/**
 * Whether a kept-mounted `PlNavigationMenu` panel stays out of sight, which
 * only the stylesheet can answer.
 *
 * Every panel is rendered on the server and kept in the document, and a closed
 * one carries `hidden`. The panel lays its links out with `grid`, though, and a
 * `display` utility outranks the browser's own `display: none` for `hidden` —
 * so without the stylesheet in the room a test would see a hidden panel, and
 * with it a reader could see every panel at once. Loaded the way
 * `back-top.test.tsx` loads it.
 *
 * The same goes for the sheet moving from one panel to the next: the root
 * measures the panels and writes their size, and only the stylesheet decides
 * whether the sheet reads it, eases towards it and keeps its lines meanwhile.
 */
import * as React from 'react';
import { act } from 'react';
import { hydrateRoot } from 'react-dom/client';
import { renderToString } from 'react-dom/server';
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { commands, page } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlNavigationMenu, PlNavigationMenuItem, PlNavigationMenuLink } from 'plass-ui';
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

function nav(value?: string | null) {
  return (
    <PlNavigationMenu value={value}>
      <PlNavigationMenuItem label="Product" value="product">
        <PlNavigationMenuLink href="/a" title="Analytics" />
      </PlNavigationMenuItem>
      <PlNavigationMenuItem label="Company" value="company">
        <PlNavigationMenuLink href="/about" title="About" />
      </PlNavigationMenuItem>
    </PlNavigationMenu>
  );
}

const link = (href: string) => document.querySelector<HTMLAnchorElement>(`a[href="${href}"]`);

describe('a PlNavigationMenu panel', () => {
  it('is out of sight in the server HTML, before and after hydration', async () => {
    const host = document.createElement('div');
    host.innerHTML = renderToString(nav());
    document.body.append(host);

    try {
      // The HTML as the server sent it, before a line of script has run: the
      // panels sit inside the row there, where a visible one would be drawn.
      expect(link('/a')).not.toBeNull();
      expect(link('/a')!.checkVisibility()).toBe(false);
      expect(link('/about')!.checkVisibility()).toBe(false);

      const root = await act(async () => hydrateRoot(host, nav()));

      try {
        await expect.poll(() => link('/a')?.checkVisibility()).toBe(false);
        expect(link('/about')?.checkVisibility()).toBe(false);
      } finally {
        await act(async () => root.unmount());
      }
    } finally {
      host.remove();
    }
  });

  it('shows the open one and nothing of the others', async () => {
    await render(nav('product'));

    await expect.poll(() => link('/a')?.checkVisibility()).toBe(true);
    expect(link('/about')).not.toBeNull();
    expect(link('/about')!.checkVisibility()).toBe(false);
  });
});

/**
 * A row with room between its two panels, so the sheet has somewhere to move:
 * one short link under Product, and five in two columns under Company.
 */
function Row({ more = false }: { more?: boolean }) {
  return (
    <>
      <PlNavigationMenuItem label="Product" value="product">
        <PlNavigationMenuLink href="/a" title="Analytics" />
        {more ? <PlNavigationMenuLink href="/b" title="Billing, and a longer name" /> : null}
      </PlNavigationMenuItem>
      <PlNavigationMenuItem label="Pricing" href="/pricing" />
      <PlNavigationMenuItem label="Changelog" href="/changelog" />
      <PlNavigationMenuItem label="Company" value="company" columns={2}>
        <PlNavigationMenuLink href="/about" title="About the company" description="Who we are" />
        <PlNavigationMenuLink href="/jobs" title="Jobs" description="Work with us" />
        <PlNavigationMenuLink href="/press" title="Press" description="News" />
        <PlNavigationMenuLink href="/contact" title="Contact" description="Say hello" />
        <PlNavigationMenuLink href="/blog" title="Blog" description="Notes" />
      </PlNavigationMenuItem>
    </>
  );
}

function wideNav(value?: string | null, more = false) {
  return (
    <PlNavigationMenu value={value}>
      <Row more={more} />
    </PlNavigationMenu>
  );
}

/**
 * Two panels of one link each, the same size. At 600px they are too wide to
 * hang centred under either trigger, so both are held against the same edge,
 * and moving from one to the other changes neither the sheet's size nor its
 * place; narrower, each hangs under its own trigger and only the place
 * changes. In a box that scrolls, which moves the row under a sheet that stays
 * where it is, as a row stuck to the top of a scrolling page does.
 */
function twinNav(width = 600) {
  return (
    <div data-scroller style={{ height: 300, overflow: 'auto' }}>
      <div style={{ height: 900, paddingTop: 100 }}>
        <PlNavigationMenu>
          <PlNavigationMenuItem label="Guides" value="guides">
            <PlNavigationMenuLink href="/guides" title="Read" style={{ width }} />
          </PlNavigationMenuItem>
          <PlNavigationMenuItem label="Tools" value="tools">
            <PlNavigationMenuLink href="/tools" title="Read" style={{ width }} />
          </PlNavigationMenuItem>
        </PlNavigationMenu>
      </div>
    </div>
  );
}

/**
 * The same items down a rail wider than its words, clear of the top of the
 * page, where the sheet would be held off the edge by its collision padding.
 */
function railNav() {
  return (
    <div style={{ width: 240, paddingTop: 40 }}>
      <PlNavigationMenu orientation="vertical">
        <Row />
      </PlNavigationMenu>
    </div>
  );
}

/** A menu whose page holds the value and takes every change a trigger asks for. */
function ControlledNav() {
  const [value, setValue] = React.useState<string | null>(null);

  return (
    <PlNavigationMenu value={value} onValueChange={setValue}>
      <Row />
    </PlNavigationMenu>
  );
}

const positioner = () => document.querySelector<HTMLElement>('.plass-portal')!;
const popup = () => document.querySelector<HTMLElement>('.plass-portal > nav')!;
const panel = (href: string) => link(href)!.closest<HTMLElement>('.grid')!;

/** A box's width and height, rounded to the pixel. */
function sizeOf(element: Element): [number, number] {
  const box = element.getBoundingClientRect();

  return [Math.round(box.width), Math.round(box.height)];
}

/** How far apart the middles of two boxes are across the page, to the pixel. */
function apart(one: Element, other: Element): number {
  const [a, b] = [one, other].map((element) => element.getBoundingClientRect());

  return Math.round(Math.abs(a.left + a.width / 2 - (b.left + b.width / 2)));
}

/**
 * How far the sheet is from the size of the panel holding `href` with the
 * sheet's two 1px edges round it: `[0, 0]` once it fits.
 */
function offBy(href: string): [number, number] {
  const [sheetWidth, sheetHeight] = sizeOf(popup());
  const [width, height] = sizeOf(panel(href));

  return [sheetWidth - width - 2, sheetHeight - height - 2];
}

/** The size and place transitions still running on the sheet and its box. */
function easing(): CSSTransition[] {
  return [positioner(), popup()].flatMap((element) =>
    element
      .getAnimations()
      .filter(
        (animation): animation is CSSTransition =>
          animation instanceof CSSTransition &&
          animation.transitionProperty !== 'opacity' &&
          animation.playState !== 'finished'
      )
  );
}

/**
 * Waits until the panel holding `href` is showing and the sheet has come to
 * rest round it: past the frame it opened in, when Base UI holds every
 * transition off, and with nothing left easing.
 */
async function settleOn(href: string) {
  await expect.poll(() => link(href)?.checkVisibility()).toBe(true);
  await expect.poll(() => popup().hasAttribute('data-starting-style')).toBe(false);
  await expect.poll(() => easing().length).toBe(0);
  // Polled rather than read once: on CI's Ubuntu WebKit the sheet was a few
  // pixels short of the panel in the frame its transitions stopped being
  // listed, and what the sheet owes is to land on the panel, not to land there
  // in that frame.
  await expect.poll(() => offBy(href)).toEqual([0, 0]);
}

/** A pixel length out of a keyframe, `'111.5px'` → `111.5`. */
const px = (value: unknown) => Number.parseFloat(String(value));

/**
 * Records every size and place transition the sheet and its box start, as the
 * two lengths each one eases between.
 *
 * Read off `transitionrun`, which fires as a transition is created, so a
 * transition that runs its whole length between two polls on a loaded machine
 * is still seen, and nothing here samples frames.
 */
function watchTheSheet() {
  const eased: Array<{ on: string; property: string; from: number; to: number }> = [];

  const listener = (event: TransitionEvent) => {
    const on =
      event.target === popup() ? 'sheet' : event.target === positioner() ? 'box' : undefined;
    const property = event.propertyName;

    if (!on || property === 'opacity') {
      return;
    }

    const transition = (event.target as Element)
      .getAnimations()
      .find(
        (animation): animation is CSSTransition =>
          animation instanceof CSSTransition && animation.transitionProperty === property
      );
    const effect = transition?.effect;
    const frames = effect instanceof KeyframeEffect ? effect.getKeyframes() : [];

    if (frames.length > 1) {
      eased.push({
        on,
        property,
        from: px(frames[0][property]),
        to: px(frames[frames.length - 1][property])
      });
    }
  };

  document.addEventListener('transitionrun', listener, true);

  return {
    eased,
    /** Which of the two eased which lengths, as `sheet:width` and so on. */
    kinds: () => [...new Set(eased.map((run) => `${run.on}:${run.property}`))].sort(),
    stop: () => document.removeEventListener('transitionrun', listener, true)
  };
}

const trigger = (label: string) =>
  [...document.querySelectorAll('button')].find((button) => button.textContent === label)!;

/**
 * Presses a trigger. A DOM click rather than the runner's, which moves a
 * pointer across the frame first, and a pointer over the row opens panels of
 * its own.
 */
function press(label: string) {
  trigger(label).click();
}

describe('a PlNavigationMenu moving between panels', () => {
  let viewport: [number, number];

  beforeAll(async () => {
    viewport = [window.innerWidth, window.innerHeight];
    // Wide enough that the two panels hang under their own triggers rather
    // than both being pushed against the left edge.
    await page.viewport(1000, 700);
  });

  afterAll(async () => {
    await page.viewport(...viewport);
  });

  beforeEach(async () => {
    // A pointer left over the row by an earlier file would open panels of its
    // own between the presses.
    await commands.parkPointer();
  });

  const ways = [
    ['keeps the value itself', () => render(wideNav())],
    ['has a page that holds the value', () => render(<ControlledNav />)]
  ] as const;

  for (const [way, draw] of ways) {
    it(`eases the sheet from one panel's size to the next when it ${way}`, async () => {
      await draw();

      press('Product');
      await settleOn('/a');

      const before = sizeOf(popup());
      const watch = watchTheSheet();

      press('Company');
      await settleOn('/about');
      watch.stop();

      const after = sizeOf(popup());

      expect(watch.kinds()).toEqual(expect.arrayContaining(['sheet:height', 'sheet:width']));

      for (const [index, property] of (['width', 'height'] as const).entries()) {
        const runs = watch.eased.filter((run) => run.on === 'sheet' && run.property === property);

        // From the panel before to the panel now, rather than a jump.
        expect(Math.round(runs[0].from)).toBe(before[index]);
        expect(Math.round(runs[runs.length - 1].to)).toBe(after[index]);
      }
    });
  }

  it('eases it when the page changes the value itself, and lands on the next panel', async () => {
    const screen = await render(wideNav('product'));

    await settleOn('/a');

    const watch = watchTheSheet();

    await screen.rerender(wideNav('company'));
    await settleOn('/about');
    watch.stop();

    expect(watch.kinds()).toEqual(expect.arrayContaining(['sheet:height', 'sheet:width']));
  });

  it('moves the sheet from under one trigger to under the next', async () => {
    await render(wideNav());

    press('Product');
    await settleOn('/a');

    const from = positioner().getBoundingClientRect().left;
    const watch = watchTheSheet();

    press('Company');
    await settleOn('/about');
    watch.stop();

    const to = positioner().getBoundingClientRect().left;
    const moves = watch.eased.filter((run) => run.on === 'box' && run.property === 'left');

    expect(Math.abs(to - from)).toBeGreaterThan(50);
    expect(moves.length).toBeGreaterThan(0);
    expect(Math.round(moves[0].from)).toBe(Math.round(from));
    expect(Math.round(moves[moves.length - 1].to)).toBe(Math.round(to));

    // And stops easing once it has arrived, so a later move, such as the row
    // scrolling with the page, is followed at once rather than trailed.
    await expect.poll(() => getComputedStyle(positioner()).transitionProperty).toBe('none');
  });

  it('opens a vertical rail s panels beside the rail, level with their items, and moves the sheet down it', async () => {
    await render(railNav());

    // How far the sheet's box stands off the rail's end edge, to the pixel.
    const standoff = () =>
      Math.round(
        positioner().getBoundingClientRect().left -
          trigger('Product').closest('nav')!.getBoundingClientRect().right
      );

    // How far the box's top stands from the top of the item it opened from.
    const drop = (label: string) =>
      Math.round(
        positioner().getBoundingClientRect().top - trigger(label).getBoundingClientRect().top
      );

    press('Product');
    await settleOn('/a');
    expect(standoff()).toBe(8);
    expect(drop('Product')).toBe(0);

    const from = positioner().getBoundingClientRect().top;
    const watch = watchTheSheet();

    press('Company');
    await settleOn('/about');
    // Floating UI places the box beside the next item a few microtasks after
    // the panel changes, which can be after the sheet has come to rest.
    await expect.poll(() => drop('Company')).toBe(0);
    await expect.poll(() => easing().length).toBe(0);
    watch.stop();

    // Against the same edge for a longer word, so the box eases down the rail
    // and never along it, and by as far as the one item is from the other.
    expect(standoff()).toBe(8);
    expect(watch.kinds()).toContain('box:top');
    expect(watch.kinds()).not.toContain('box:left');
    expect(Math.round(positioner().getBoundingClientRect().top - from)).toBe(
      Math.round(
        trigger('Company').getBoundingClientRect().top -
          trigger('Product').getBoundingClientRect().top
      )
    );
  });

  it('moves the sheet under the next item when only its place changes', async () => {
    await render(twinNav(120));

    press('Guides');
    await settleOn('/guides');

    const from = positioner().getBoundingClientRect().left;
    const watch = watchTheSheet();

    press('Tools');
    await settleOn('/tools');
    // Floating UI sends the box under the next item a few microtasks after the
    // panel changes, which can be after a sheet of the same size has come to
    // rest round it.
    await expect.poll(() => apart(positioner(), trigger('Tools'))).toBe(0);
    await expect.poll(() => easing().length).toBe(0);
    watch.stop();

    const to = positioner().getBoundingClientRect().left;
    const moves = watch.eased.filter((run) => run.on === 'box' && run.property === 'left');

    // Nothing but the box's place to ease, which the easing has to wait for.
    expect(watch.kinds()).toEqual(['box:left']);
    expect(Math.abs(to - from)).toBeGreaterThan(20);
    expect(Math.round(moves[0].from)).toBe(Math.round(from));
    expect(Math.round(moves[moves.length - 1].to)).toBe(Math.round(to));
  });

  it('stops easing when the next panel is the same size in the same place', async () => {
    await render(twinNav());

    press('Guides');
    await settleOn('/guides');

    const watch = watchTheSheet();

    press('Tools');
    await settleOn('/tools');

    // Nothing to ease, so no transition to end the easing either.
    await expect.poll(() => getComputedStyle(positioner()).transitionProperty).toBe('none');
    await expect.poll(() => getComputedStyle(popup()).transitionProperty).toBe('opacity');

    // So the row scrolling out from under the sheet is followed at once
    // rather than trailed.
    document.querySelector('[data-scroller]')!.scrollTop = 40;

    const gap = () =>
      Math.round(
        positioner().getBoundingClientRect().top - trigger('Tools').getBoundingClientRect().bottom
      );

    await expect.poll(gap).toBe(8);
    watch.stop();

    expect(watch.kinds()).toEqual([]);
  });

  it('opens at the size and the place of its panel, easing neither', async () => {
    await render(wideNav());

    const watch = watchTheSheet();

    press('Company');
    await settleOn('/about');
    watch.stop();

    expect(watch.kinds()).toEqual([]);
  });

  it('keeps a panel as wide as its links while the sheet around it is narrower', async () => {
    await render(wideNav('company'));
    await settleOn('/about');

    const width = sizeOf(panel('/about'))[0];

    // Where the sheet is while it eases up from a narrower panel.
    popup().style.width = '120px';

    expect(sizeOf(panel('/about'))[0]).toBe(width);
  });

  it('lands on the size of a panel whose links change while it is open', async () => {
    const screen = await render(wideNav('product'));

    await settleOn('/a');
    await screen.rerender(wideNav('product', true));
    await expect.poll(() => offBy('/a')).toEqual([0, 0]);
    await screen.rerender(wideNav('product'));
    await expect.poll(() => offBy('/a')).toEqual([0, 0]);
  });

  it('keeps the size of what it held while it closes', async () => {
    const screen = await render(wideNav('company'));

    await settleOn('/about');

    const size = sizeOf(popup());

    await screen.rerender(wideNav(null));

    // Still fading out, and still the size it was.
    expect(popup().hasAttribute('data-ending-style')).toBe(true);
    expect(sizeOf(popup())).toEqual(size);
  });

  it('never reads the size Base UI leaves on the sheet and its box', async () => {
    const screen = await render(wideNav('product'));

    await settleOn('/a');

    // What Base UI can leave behind when a change lands between its two steps:
    // the size of the panel before.
    const [width, height] = sizeOf(popup());

    for (const element of [popup(), positioner()]) {
      element.style.setProperty('--popup-width', `${width}px`);
      element.style.setProperty('--popup-height', `${height}px`);
      element.style.setProperty('--positioner-width', `${width}px`);
      element.style.setProperty('--positioner-height', `${height}px`);
    }

    await screen.rerender(wideNav('company'));
    await settleOn('/about');
  });

  it('lands without easing under reduced motion', async () => {
    await emulateMedia({ reducedMotion: 'reduce' });

    try {
      await render(wideNav());

      press('Product');
      await settleOn('/a');

      const watch = watchTheSheet();

      press('Company');
      await settleOn('/about');
      watch.stop();

      expect(watch.kinds()).toEqual([]);
    } finally {
      // Back to the context's own default rather than to none at all: `null`
      // hands the question to the runner's system, which answers `reduce` on
      // some CI images and leaves every file after this one without motion.
      await emulateMedia({ reducedMotion: 'no-preference' });
    }
  });
});

describe("a PlNavigationMenu item's chevron", () => {
  beforeEach(async () => {
    // A pointer left over the row by an earlier file would open a panel.
    await commands.parkPointer();
  });

  const angle = (label: string) =>
    getComputedStyle(trigger(label).querySelector<HTMLElement>('[aria-hidden]')!).rotate;

  it('points down on a row, and turns over while its panel is open', async () => {
    await render(wideNav());

    expect(angle('Product')).toBe('none');

    press('Product');
    await settleOn('/a');

    await expect.poll(() => angle('Product')).toBe('180deg');
  });

  it('points at the end of the line on a rail, and stays there while its panel is open', async () => {
    await render(railNav());

    expect(angle('Product')).toBe('-90deg');

    press('Product');
    await settleOn('/a');

    expect(angle('Product')).toBe('-90deg');
  });

  it('points left on a rail on a page that runs right to left', async () => {
    document.documentElement.setAttribute('dir', 'rtl');

    try {
      await render(railNav());

      expect(angle('Product')).toBe('90deg');
    } finally {
      document.documentElement.removeAttribute('dir');
    }
  });
});
