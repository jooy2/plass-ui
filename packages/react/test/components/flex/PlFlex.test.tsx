/**
 * A flex box writes two things: the classes that never change with the width,
 * and the `--p-*` slots the stylesheet resolves at one. The first half of this
 * file asserts the slots the way `PlGrid.test.tsx` does, with no CSS at all.
 *
 * The second half loads `src/standalone.css` and resizes the viewport, because
 * the claim worth checking is not that a slot was written — it is that the axis
 * actually changes at the rung it was named for, and only the browser can say
 * so. `PlShow.test.tsx` loads the sheet for the same reason.
 */
import { page } from 'vitest/browser';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlFlex } from 'plass-ui';
import standaloneCss from '../../../src/standalone.css?inline';

let sheet: HTMLStyleElement;
let initial: [number, number];

beforeAll(() => {
  initial = [window.innerWidth, window.innerHeight];
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(async () => {
  sheet.remove();
  await page.viewport(...initial);
});

/** The inline slots a box wrote, as a plain object. */
function slots(): Record<string, string> {
  const element = document.querySelector<HTMLElement>('.flex-under-test');
  const written: Record<string, string> = {};

  for (const name of Array.from(element?.style ?? [])) {
    if (name.startsWith('--p-')) written[name] = element!.style.getPropertyValue(name).trim();
  }

  return written;
}

function box(): HTMLElement {
  return document.querySelector<HTMLElement>('.flex-under-test')!;
}

/** Which way the box runs right now, once the width has settled. */
async function directionAt(width: number): Promise<string> {
  await page.viewport(width, 600);

  await expect.poll(() => getComputedStyle(box()).flexDirection).not.toBe('');

  return getComputedStyle(box()).flexDirection;
}

describe('PlFlex', () => {
  describe('direction', () => {
    it('is a row unless it is told otherwise', async () => {
      await render(<PlFlex className="flex-under-test" />);

      expect(slots()['--p-dir-xs']).toBe('row');
    });

    it('takes the axis it was given', async () => {
      await render(<PlFlex className="flex-under-test" direction="vertical" />);

      expect(slots()['--p-dir-xs']).toBe('column');
    });

    it('folds `reverse` into the same slot', async () => {
      await render(<PlFlex className="flex-under-test" direction="vertical" reverse />);

      // One slot rather than two, so a breakpoint changes the axis without
      // having to restate which end it starts from.
      expect(slots()['--p-dir-xs']).toBe('column-reverse');
    });

    it('writes only the breakpoints it was named, plus the baseline', async () => {
      await render(<PlFlex className="flex-under-test" direction={{ md: 'vertical' }} />);

      const written = slots();

      expect(written['--p-dir-md']).toBe('column');
      // The `xs` entry is the documented default rather than the CSS fallback:
      // naming one breakpoint must not silently drop the ones below it.
      expect(written['--p-dir-xs']).toBe('row');
      expect(written['--p-dir-lg']).toBeUndefined();
    });

    it('reverses every rung of a responsive axis', async () => {
      await render(
        <PlFlex
          className="flex-under-test"
          direction={{ xs: 'vertical', md: 'horizontal' }}
          reverse
        />
      );

      const written = slots();

      expect(written['--p-dir-xs']).toBe('column-reverse');
      expect(written['--p-dir-md']).toBe('row-reverse');
    });

    it('leaves the DOM order alone when it reverses', async () => {
      await render(
        <PlFlex className="flex-under-test" reverse>
          <span>one</span>
          <span>two</span>
        </PlFlex>
      );

      // `reverse` is a painting order. What a screen reader reads and what the
      // Tab key walks is this, and it has not moved.
      expect(Array.from(box().children).map((child) => child.textContent)).toEqual(['one', 'two']);
    });
  });

  describe('spacing', () => {
    it('is two steps of the spacing scale by default', async () => {
      await render(<PlFlex className="flex-under-test" />);

      const written = slots();

      expect(written['--p-gap-x-xs']).toBe('0.5rem');
      expect(written['--p-gap-y-xs']).toBe('0.5rem');
    });

    it('takes fractions of a step', async () => {
      await render(<PlFlex className="flex-under-test" spacing={1.5} />);

      expect(slots()['--p-gap-x-xs']).toBe('0.375rem');
    });

    it('lets one axis be named on its own', async () => {
      await render(<PlFlex className="flex-under-test" spacing={4} rowSpacing={0} />);

      const written = slots();

      expect(written['--p-gap-x-xs']).toBe('1rem');
      expect(written['--p-gap-y-xs']).toBe('0rem');
    });
  });

  describe('the box', () => {
    it('does not wrap unless it was asked to', async () => {
      await render(<PlFlex className="flex-under-test" />);

      expect(box().classList.contains('flex-nowrap')).toBe(true);
    });

    it('wraps when it was', async () => {
      await render(<PlFlex className="flex-under-test" wrap />);

      expect(box().classList.contains('flex-wrap')).toBe(true);
    });

    it('lays out as a block, or inline when it was told to', async () => {
      await render(<PlFlex className="flex-under-test" />);

      expect(getComputedStyle(box()).display).toBe('flex');

      await render(<PlFlex className="flex-under-test inline-under-test" inline />);

      expect(
        getComputedStyle(document.querySelector<HTMLElement>('.inline-under-test')!).display
      ).toBe('inline-flex');
    });

    it('carries the distribution and the alignment as classes', async () => {
      await render(
        <PlFlex
          className="flex-under-test"
          justify="space-between"
          alignItems="center"
          alignContent="end"
        />
      );

      const written = Array.from(box().classList);

      expect(written).toContain('justify-between');
      expect(written).toContain('items-center');
      expect(written).toContain('content-end');
    });

    it('renders something other than a `<div>` when it is handed one', async () => {
      await render(<PlFlex className="flex-under-test" render={<ul />} />);

      expect(box().tagName).toBe('UL');
    });
  });

  describe('the stylesheet', () => {
    it('runs the way the bare prop says at every width', async () => {
      await render(<PlFlex className="flex-under-test" direction="vertical" />);

      expect(await directionAt(500)).toBe('column');
      expect(await directionAt(1000)).toBe('column');
    });

    it('turns at the rung the map named, and not before it', async () => {
      await render(
        <PlFlex className="flex-under-test" direction={{ xs: 'vertical', md: 'horizontal' }} />
      );

      expect(await directionAt(500)).toBe('column');
      // 768px is 48rem, the floor of `md` — the rung it is named for.
      expect(await directionAt(768)).toBe('row');
      expect(await directionAt(1400)).toBe('row');
    });

    it('holds a rung it was not given from the one below it', async () => {
      await render(
        <PlFlex className="flex-under-test" direction={{ xs: 'horizontal', lg: 'vertical' }} />
      );

      // Nothing was said about `md`, so `md` is still what `xs` said.
      expect(await directionAt(800)).toBe('row');
      expect(await directionAt(1100)).toBe('column');
    });

    it('resolves a gutter the same way', async () => {
      await render(<PlFlex className="flex-under-test" spacing={{ xs: 0, md: 4 }} />);

      await page.viewport(500, 600);
      await expect.poll(() => getComputedStyle(box()).columnGap).toBe('0px');

      await page.viewport(900, 600);
      await expect.poll(() => getComputedStyle(box()).columnGap).toBe('16px');
    });
  });
});
