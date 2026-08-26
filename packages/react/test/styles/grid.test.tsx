/**
 * The grid's arithmetic, which lives in the stylesheet rather than in the
 * component.
 *
 * Every other file under `test/components/` runs with no CSS at all, and that
 * is right: what a component decides is which classes and which inline slots it
 * writes, and `PlGrid.test.tsx` asserts exactly that. But a column width is
 * `(100% + gap) * span / columns - gap` at four breakpoints, and none of it is
 * expressible in a class name — so the thing under test here really is a
 * stylesheet, the same way `standalone.test.tsx`'s is.
 *
 * The stylesheet is loaded the same way that file loads it: `src/standalone.css`
 * through Vite and the repository's own PostCSS config, so it is the same input
 * and the same compiler without a build having to have run first.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlGrid, PlGridItem } from 'plass-ui';
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

/** The laid-out box of the one item a test is measuring. */
function item(): DOMRect {
  return document.querySelector('.item-under-test')!.getBoundingClientRect();
}

describe('the grid stylesheet', () => {
  it('divides the row by the column count', async () => {
    await render(
      <div style={{ width: '480px' }}>
        <PlGrid spacing={0}>
          <PlGridItem className="item-under-test" span={6} />
          <PlGridItem span={6} />
        </PlGrid>
      </div>
    );

    expect(item().width).toBe(240);
  });

  it('reads a span against whatever the column count is', async () => {
    await render(
      <div style={{ width: '480px' }}>
        <PlGrid columns={24} spacing={0}>
          <PlGridItem className="item-under-test" span={6} />
        </PlGrid>
      </div>
    );

    expect(item().width).toBe(120);
  });

  it('fills the row when it is given no span at all', async () => {
    await render(
      <div style={{ width: '480px' }}>
        <PlGrid spacing={0}>
          <PlGridItem className="item-under-test" />
        </PlGrid>
      </div>
    );

    expect(item().width).toBe(480);
  });

  it('clamps a span wider than the row rather than overflowing', async () => {
    await render(
      <div style={{ width: '480px' }}>
        <PlGrid spacing={0}>
          <PlGridItem className="item-under-test" span={99} />
        </PlGrid>
      </div>
    );

    expect(item().width).toBe(480);
  });

  it('takes the gutter out of the item and not out of the row', async () => {
    await render(
      <div style={{ width: '480px' }}>
        <PlGrid spacing={4}>
          <PlGridItem className="item-under-test" span={6} />
          <PlGridItem span={6} />
        </PlGrid>
      </div>
    );

    // (480 + 16) / 12 × 6 − 16. Two halves plus one gutter is the whole row,
    // which is the property the arithmetic exists to hold.
    expect(item().width).toBe(232);
  });

  it('pushes an item along by its offset', async () => {
    await render(
      <div style={{ width: '480px' }}>
        <PlGrid spacing={0}>
          <PlGridItem className="item-under-test" span={4} offset={4} />
        </PlGrid>
      </div>
    );

    const grid = document.querySelector('.plass-grid')!.getBoundingClientRect();

    // A third of 480, to the pixel the browser actually rounds a percentage
    // margin to.
    expect(item().left - grid.left).toBeCloseTo(160, 1);
  });

  it('leaves the item at its own size with nothing above it', async () => {
    // No `PlGrid`, so the column count is the CSS fallback of twelve rather
    // than a division by an undefined custom property.
    await render(
      <div style={{ width: '480px' }}>
        <PlGridItem className="item-under-test" span={6} />
      </div>
    );

    expect(item().width).toBe(240);
  });
});
