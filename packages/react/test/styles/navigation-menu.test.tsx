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

const frame = () => new Promise<number>((resolve) => requestAnimationFrame(resolve));

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

/**
 * Presses Product, then Company, and reads the popup's size every frame for
 * about half a second after the second press, which is more than the
 * transition takes.
 *
 * Company is pressed once Product has settled, which is when Base UI hands the
 * popup `auto` again, so the samples are of one resize rather than two.
 */
async function sampleTheSwitch() {
  press('Product');
  await expect.poll(() => link('/a')?.checkVisibility()).toBe(true);
  await expect.poll(() => popup().style.getPropertyValue('--popup-width')).toBe('auto');
  await expect.poll(() => heightOff('/a')).toBe(0);

  const start = popupSize();

  press('Company');

  const samples: Array<{ width: number; height: number }> = [];

  for (let index = 0; index < 30; index += 1) {
    await frame();
    samples.push(popupSize());
  }

  return { start, samples, end: samples[samples.length - 1] };
}

describe('a PlNavigationMenu moving between panels', () => {
  it('eases the sheet to the size of the next panel rather than jumping to it', async () => {
    await render(wideNav());

    const { start, samples, end } = await sampleTheSwitch();

    expect(end.width).toBeGreaterThan(start.width);
    expect(end.height).toBeGreaterThan(start.height);
    // Not there on the first frame, and somewhere between the two on the way.
    expect(samples[0]).not.toEqual(end);
    expect(samples.some((size) => size.width > start.width && size.width < end.width)).toBe(true);
    expect(samples.some((size) => size.height > start.height && size.height < end.height)).toBe(
      true
    );
    // And it lands on the size of the panel, not on a size it was held at.
    expect(heightOff('/about')).toBe(0);
  });

  it('eases it as well when the page holds the value and takes the change', async () => {
    await render(<ControlledNav />);

    const { start, samples, end } = await sampleTheSwitch();

    expect(link('/about')?.checkVisibility()).toBe(true);
    expect(samples[0]).not.toEqual(end);
    expect(samples.some((size) => size.height > start.height && size.height < end.height)).toBe(
      true
    );
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
