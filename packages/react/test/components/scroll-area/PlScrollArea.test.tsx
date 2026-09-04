/**
 * The stylesheet is loaded here, which most component tests do not do. What is
 * under test is a box that overflows, and whether it overflows is a question
 * about laid-out pixels: with no CSS a `height` is still honoured but the
 * viewport has no size to overflow, so nothing would ever scroll and every
 * assertion below would pass for the wrong reason.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlScrollArea } from 'plass-ui';
import standaloneCss from '../../../src/standalone.css?inline';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

function root(): HTMLElement {
  return document.querySelector<HTMLElement>('.area-under-test')!;
}

/** Base UI's viewport: the scrolling element, and the one that takes the keys. */
function viewport(): HTMLElement {
  return root().querySelector<HTMLElement>('[data-testid="viewport"], .area-viewport')!;
}

/**
 * The lanes that were drawn at all.
 *
 * Direct children only: a thumb carries `data-orientation` too, and it is the
 * lane's own child.
 */
function lanes(): HTMLElement[] {
  return Array.from(root().querySelectorAll<HTMLElement>(':scope > [data-orientation]'));
}

/** Tall content, so there is always something to scroll. */
function Tall() {
  return <div style={{ height: '900px', width: '900px' }}>Long</div>;
}

describe('PlScrollArea', () => {
  describe('the box', () => {
    it('takes a height as a number of pixels', async () => {
      await render(
        <PlScrollArea className="area-under-test" height={200}>
          <Tall />
        </PlScrollArea>
      );

      expect(root().style.height).toBe('200px');
    });

    it('takes any CSS length too', async () => {
      await render(
        <PlScrollArea className="area-under-test" height="12rem" maxWidth="30ch">
          <Tall />
        </PlScrollArea>
      );

      expect(root().style.height).toBe('12rem');
      expect(root().style.maxWidth).toBe('30ch');
    });

    it('scrolls what it was given', async () => {
      await render(
        <PlScrollArea
          className="area-under-test"
          classNames={{ viewport: 'area-viewport' }}
          height={200}
        >
          <Tall />
        </PlScrollArea>
      );

      await expect.poll(() => viewport().scrollHeight > viewport().clientHeight).toBe(true);

      viewport().scrollTop = 120;

      expect(viewport().scrollTop).toBe(120);
    });
  });

  describe('orientation', () => {
    it('draws one lane down the side by default', async () => {
      await render(
        <PlScrollArea className="area-under-test" height={200}>
          <Tall />
        </PlScrollArea>
      );

      await expect.poll(() => lanes().length).toBe(1);
      expect(lanes()[0].dataset.orientation).toBe('vertical');
    });

    it('draws one along the bottom when it was told to', async () => {
      await render(
        <PlScrollArea className="area-under-test" orientation="horizontal" width={200}>
          <Tall />
        </PlScrollArea>
      );

      await expect.poll(() => lanes().length).toBe(1);
      expect(lanes()[0].dataset.orientation).toBe('horizontal');
    });

    it('draws both, and the corner where they meet', async () => {
      await render(
        <PlScrollArea className="area-under-test" orientation="both" height={200} width={200}>
          <Tall />
        </PlScrollArea>
      );

      await expect.poll(() => lanes().length).toBe(2);
      expect(lanes().map((lane) => lane.dataset.orientation)).toEqual(['vertical', 'horizontal']);
    });
  });

  describe('scrollbars', () => {
    it('keeps the lane out of the way until something happens', async () => {
      await render(
        <PlScrollArea className="area-under-test" height={200}>
          <Tall />
        </PlScrollArea>
      );

      await expect.poll(() => lanes().length).toBe(1);

      // The classes rather than the computed opacity: whether the pointer is
      // over the box is the browser's answer, and where it happens to be left
      // by the file that ran before this one is not something a test may
      // depend on. The lane is there and transparent, and hovering or
      // scrolling is what brings it up.
      expect(lanes()[0].className).toContain('opacity-0');
      expect(lanes()[0].className).toContain('data-[hovering]:opacity-100');
      expect(lanes()[0].className).toContain('data-[scrolling]:opacity-100');
    });

    it('holds it open when it was asked to', async () => {
      await render(
        <PlScrollArea className="area-under-test" height={200} scrollbars="always">
          <Tall />
        </PlScrollArea>
      );

      await expect.poll(() => lanes().length).toBe(1);
      expect(getComputedStyle(lanes()[0]).opacity).toBe('1');
    });

    it('overlays the lane rather than taking width from the content', async () => {
      await render(
        <PlScrollArea
          className="area-under-test"
          classNames={{ viewport: 'area-viewport' }}
          height={200}
          width={300}
          scrollbars="always"
        >
          <Tall />
        </PlScrollArea>
      );

      await expect.poll(() => viewport().clientWidth).toBe(300);
    });
  });

  describe('accessibility', () => {
    it('is a tab stop while there is something to scroll', async () => {
      await render(
        <PlScrollArea
          className="area-under-test"
          classNames={{ viewport: 'area-viewport' }}
          height={200}
        >
          <Tall />
        </PlScrollArea>
      );

      // A keyboard reader has to be able to scroll it, and nothing inside is
      // focusable — so the box itself has to be reachable.
      await expect.poll(() => viewport().tabIndex).toBe(0);
    });

    it('is not one when everything already fits', async () => {
      await render(
        <PlScrollArea
          className="area-under-test"
          classNames={{ viewport: 'area-viewport' }}
          height={200}
        >
          <div style={{ height: '20px' }}>Short</div>
        </PlScrollArea>
      );

      await expect.poll(() => viewport().tabIndex).toBe(-1);
    });

    it('becomes a named region when it is given a name', async () => {
      await render(
        <PlScrollArea
          className="area-under-test"
          classNames={{ viewport: 'area-viewport' }}
          height={200}
          label="Release notes"
        >
          <Tall />
        </PlScrollArea>
      );

      expect(viewport().getAttribute('role')).toBe('region');
      expect(viewport().getAttribute('aria-label')).toBe('Release notes');
    });

    it('claims no landmark without one', async () => {
      await render(
        <PlScrollArea
          className="area-under-test"
          classNames={{ viewport: 'area-viewport' }}
          height={200}
        >
          <Tall />
        </PlScrollArea>
      );

      // An unnamed region is a landmark a screen reader lists as "region" and
      // nothing else, which is worse than no landmark at all.
      expect(viewport().getAttribute('role')).toBeNull();
    });
  });
});
