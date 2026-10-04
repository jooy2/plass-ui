/**
 * Whether a resizable `PlSidebar` inside a scaled ancestor resizes from the
 * width it is laid out at, which only the stylesheet can answer: without it the
 * sidebar has no width of its own to start from.
 *
 * The sidebar is drawn at half its size by a `transform` on the box around it,
 * as a sidebar inside a scaled `PlMockup` is, with `src/standalone.css` loaded
 * the way `panes.test.tsx` loads it.
 */
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import { PlSidebar } from 'plass-ui';
import { render } from 'vitest-browser-react';
import standaloneCss from '../../src/standalone.css?inline';
import { moveMouseOntoPage } from '../support/pointer';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

describe('PlSidebar', () => {
  describe('inside a scaled ancestor', () => {
    /** A sidebar laid out 200 wide and drawn 100 wide. */
    const scaled = (onResizeEnd: (width: number) => void, dir?: 'rtl') => (
      <div dir={dir} style={{ transform: 'scale(0.5)', transformOrigin: '0 0' }}>
        <div style={{ display: 'flex', height: '300px' }}>
          <PlSidebar
            className="sidebar-under-test"
            collapseBelow="none"
            resizable
            width={200}
            minWidth={100}
            maxWidth={400}
            onResizeEnd={onResizeEnd}
          >
            Links
          </PlSidebar>
        </div>
      </div>
    );

    /** The sidebar, and the width it is laid out at. */
    function sidebar(): { element: HTMLElement; width: () => number } {
      const element = document.querySelector<HTMLElement>('.sidebar-under-test')!;

      return { element, width: () => parseFloat(getComputedStyle(element).width) };
    }

    it('moves the edge as far as the key says', async () => {
      const onResizeEnd = vi.fn();

      await render(scaled(onResizeEnd));

      const { width } = sidebar();
      const handle = document.querySelector<HTMLElement>('[role="separator"]')!;

      expect(width()).toBe(200);

      handle.dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true, cancelable: true })
      );

      // One press is 16 of the sidebar's own pixels, which is 8 on the screen.
      expect(width()).toBe(216);
      expect(onResizeEnd).toHaveBeenLastCalledWith(216);
      expect(handle).toHaveAttribute('aria-valuenow', '216');
    });

    it.each([
      ['ltr', undefined, 1],
      ['rtl', 'rtl' as const, -1]
    ])('keeps the edge under the pointer dragging it, %s', async (_, dir, outwards) => {
      const onResizeEnd = vi.fn();

      await render(scaled(onResizeEnd, dir));

      const { element, width } = sidebar();
      const handle = document.querySelector<HTMLElement>('[role="separator"]')!;
      const pointerId = await moveMouseOntoPage();
      const start = handle.getBoundingClientRect();
      const edge = () => {
        const box = element.getBoundingClientRect();

        return dir === 'rtl' ? box.left : box.right;
      };
      const before = edge();
      const at = (x: number) => ({
        bubbles: true,
        pointerType: 'mouse',
        pointerId,
        button: 0,
        buttons: 1,
        clientX: x,
        clientY: start.top + start.height / 2
      });
      const x = start.left + start.width / 2;

      handle.dispatchEvent(new PointerEvent('pointerdown', at(x)));

      // Pressed and not yet moved, it is the width it was.
      expect(width()).toBe(200);

      handle.dispatchEvent(new PointerEvent('pointermove', at(x + 40 * outwards)));

      // The edge went as far on the screen as the pointer did, which is twice
      // as far in the sidebar's own pixels.
      expect(Math.abs(edge() - before - 40 * outwards)).toBeLessThanOrEqual(0.5);
      expect(width()).toBe(280);

      handle.dispatchEvent(new PointerEvent('pointerup', at(x + 40 * outwards)));

      expect(onResizeEnd).toHaveBeenLastCalledWith(280);
    });
  });
});
