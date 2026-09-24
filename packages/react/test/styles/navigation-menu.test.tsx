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

/** The popup's width and height transitions, once a change has started them. */
function sizeTransitions(): CSSTransition[] {
  return popup()
    .getAnimations()
    .filter(
      (animation): animation is CSSTransition =>
        animation instanceof CSSTransition &&
        (animation.transitionProperty === 'width' || animation.transitionProperty === 'height')
    );
}

/**
 * Presses Product, then Company, and measures the popup halfway through the
 * resize.
 *
 * Company is pressed once Product has settled, which is when Base UI hands the
 * popup `auto` again, so the resize is one rather than two. The transitions
 * are caught rather than sampled: paused at half their duration, measured,
 * then finished. A sample taken every frame on a loaded machine can miss the
 * middle of a 150ms transition altogether, and this cannot.
 */
async function catchTheSwitch() {
  press('Product');
  await expect.poll(() => link('/a')?.checkVisibility()).toBe(true);
  await expect.poll(() => popup().style.getPropertyValue('--popup-width')).toBe('auto');
  await expect.poll(() => heightOff('/a')).toBe(0);

  const start = popupSize();

  press('Company');

  // Width and height are eased together; wait until both are under way.
  await expect
    .poll(() => new Set(sizeTransitions().map((transition) => transition.transitionProperty)).size)
    .toBe(2);

  const transitions = sizeTransitions();

  for (const transition of transitions) {
    transition.pause();
    transition.currentTime = Number(transition.effect!.getTiming().duration) / 2;
  }

  const middle = popupSize();

  for (const transition of transitions) {
    transition.finish();
  }

  await expect.poll(() => heightOff('/about')).toBe(0);

  return { start, middle, end: popupSize() };
}

describe('a PlNavigationMenu moving between panels', () => {
  it('eases the sheet to the size of the next panel rather than jumping to it', async () => {
    await render(wideNav());

    const { start, middle, end } = await catchTheSwitch();

    expect(end.width).toBeGreaterThan(start.width);
    expect(end.height).toBeGreaterThan(start.height);
    // Halfway through, somewhere between the two, in both directions.
    expect(middle.width).toBeGreaterThan(start.width);
    expect(middle.width).toBeLessThan(end.width);
    expect(middle.height).toBeGreaterThan(start.height);
    expect(middle.height).toBeLessThan(end.height);
  });

  it('eases it as well when the page holds the value and takes the change', async () => {
    await render(<ControlledNav />);

    const { start, middle, end } = await catchTheSwitch();

    expect(link('/about')?.checkVisibility()).toBe(true);
    expect(middle.height).toBeGreaterThan(start.height);
    expect(middle.height).toBeLessThan(end.height);
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
