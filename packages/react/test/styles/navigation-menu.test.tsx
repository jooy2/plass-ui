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
 * The same goes for the sheet easing from one panel's size to the next: Base UI
 * sets the sizes, and only the stylesheet decides whether the popup reads them.
 */
import * as React from 'react';
import { act } from 'react';
import { hydrateRoot } from 'react-dom/client';
import { renderToString } from 'react-dom/server';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlNavigationMenu, PlNavigationMenuItem, PlNavigationMenuLink } from 'plass-ui';
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

/** Two panels of different sizes: one short link, and five in two columns. */
function wideNav(value?: string | null) {
  return (
    <PlNavigationMenu value={value}>
      <PlNavigationMenuItem label="Product" value="product">
        <PlNavigationMenuLink href="/a" title="Analytics" />
      </PlNavigationMenuItem>
      <PlNavigationMenuItem label="Company" value="company" columns={2}>
        <PlNavigationMenuLink href="/about" title="About the company" description="Who we are" />
        <PlNavigationMenuLink href="/jobs" title="Jobs" description="Work with us" />
        <PlNavigationMenuLink href="/press" title="Press" description="News" />
        <PlNavigationMenuLink href="/contact" title="Contact" description="Say hello" />
        <PlNavigationMenuLink href="/blog" title="Blog" description="Notes" />
      </PlNavigationMenuItem>
    </PlNavigationMenu>
  );
}

const popup = () => document.querySelector<HTMLElement>('.plass-portal > nav')!;

/** The popup's size, rounded to the pixel. */
function popupSize(): { width: number; height: number } {
  const box = popup().getBoundingClientRect();

  return { width: Math.round(box.width), height: Math.round(box.height) };
}

/**
 * How far the popup is from the height of the panel holding `href`, with the
 * popup's two 1px edges round it: `0` once the sheet fits what it holds.
 */
function heightOff(href: string): number {
  const panel = link(href)!.closest<HTMLElement>('.grid')!;

  return Math.round(
    popup().getBoundingClientRect().height - panel.getBoundingClientRect().height - 2
  );
}

/**
 * Presses a trigger. A DOM click rather than the runner's, which moves a
 * pointer across the frame first and lets frames go by before the press lands.
 */
function press(label: string) {
  [...document.querySelectorAll('button')].find((button) => button.textContent === label)!.click();
}

/** A menu whose page holds the value and takes every change a trigger asks for. */
function ControlledNav() {
  const [value, setValue] = React.useState<string | null>(null);

  return (
    <PlNavigationMenu value={value} onValueChange={setValue}>
      {wideNav().props.children}
    </PlNavigationMenu>
  );
}

/** A pixel length out of a keyframe, `'111.5px'` → `111.5`. */
const px = (value: unknown) => Number.parseFloat(String(value));

/**
 * Records every width and height transition the popup starts, as the two
 * lengths it eases between.
 *
 * Read off `transitionrun`, which fires as a transition is created, so a
 * transition that runs its whole 150ms between two polls on a loaded machine is
 * still seen. What is recorded is the transition's own two ends rather than
 * sizes sampled on the way: the width it eases towards is the one Base UI
 * measured, and the sheet can settle a few pixels from it once Base UI hands
 * it `auto` again.
 */
function watchTheResize() {
  const eased = new Map<string, [number, number]>();

  const listener = (event: TransitionEvent) => {
    const property = event.propertyName;

    if (event.target !== popup() || (property !== 'width' && property !== 'height')) {
      return;
    }

    const transition = popup()
      .getAnimations()
      .find(
        (animation): animation is CSSTransition =>
          animation instanceof CSSTransition && animation.transitionProperty === property
      );
    const effect = transition?.effect;
    const frames = effect instanceof KeyframeEffect ? effect.getKeyframes() : [];

    if (frames.length > 1) {
      eased.set(property, [px(frames[0][property]), px(frames[frames.length - 1][property])]);
    }
  };

  document.addEventListener('transitionrun', listener, true);

  return { eased, stop: () => document.removeEventListener('transitionrun', listener, true) };
}

/**
 * Presses Product, then Company once Product has settled, which is when Base
 * UI hands the popup `auto` again, so what follows is one resize rather than
 * two.
 */
async function switchPanels() {
  press('Product');
  await expect.poll(() => link('/a')?.checkVisibility()).toBe(true);
  await expect.poll(() => popup().style.getPropertyValue('--popup-width')).toBe('auto');
  await expect.poll(() => heightOff('/a')).toBe(0);

  const watch = watchTheResize();

  press('Company');
  await expect.poll(() => link('/about')?.checkVisibility()).toBe(true);
  await expect.poll(() => heightOff('/about')).toBe(0);
  watch.stop();

  return watch.eased;
}

describe('a PlNavigationMenu moving between panels', () => {
  it('eases the sheet to the size of the next panel rather than jumping to it', async () => {
    await render(wideNav());

    const eased = await switchPanels();

    // Both lengths were transitions, each from the smaller panel's towards the
    // larger one's, rather than a jump.
    expect([...eased.keys()].sort()).toEqual(['height', 'width']);

    for (const [from, to] of eased.values()) {
      expect(to).toBeGreaterThan(from);
    }
  });

  it('lands on the size of the next panel when the page holds the value and takes the change', async () => {
    await render(<ControlledNav />);

    // Whether this one eases depends on whether the page's re-render lands
    // inside the frame Base UI measures in; either way the sheet has to end at
    // the size of what it holds rather than at the size of the panel before.
    await switchPanels();

    expect(link('/about')?.checkVisibility()).toBe(true);
    expect(heightOff('/about')).toBe(0);
  });

  it('fits the next panel at once when the page changes the value itself', async () => {
    const screen = await render(wideNav('product'));

    await expect.poll(() => link('/a')?.checkVisibility()).toBe(true);

    // What Base UI leaves on the popup when a change it did not start cancels
    // the second of its two steps: the size of the panel that was open.
    const { width, height } = popupSize();

    popup().style.setProperty('--popup-width', `${width}px`);
    popup().style.setProperty('--popup-height', `${height}px`);

    await screen.rerender(wideNav('company'));

    await expect.poll(() => link('/about')?.checkVisibility()).toBe(true);
    expect(heightOff('/about')).toBe(0);
  });
});
