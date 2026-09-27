/**
 * Where a `PlHeader`'s actions land in the bar, which only the stylesheet can
 * answer.
 *
 * The actions are meant to sit at the bar's far end whatever else is in it. A
 * middle takes the rest of the row and so leaves them there; a bar with no
 * middle has to put them there some other way, and without the real CSS loaded
 * no slot has a width and nothing is anywhere. Loaded the way
 * `back-top.test.tsx` loads it, and read from the boxes.
 */
import type { ReactNode } from 'react';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlHeader, type PlassAlign } from 'plass-ui';
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

type Dir = 'ltr' | 'rtl';

async function renderBar({
  align,
  dir,
  brand = <span>Acme</span>,
  children
}: {
  align: PlassAlign;
  dir: Dir;
  brand?: ReactNode;
  children?: ReactNode;
}) {
  await render(
    <div dir={dir} style={{ width: 640 }}>
      <PlHeader
        position="static"
        align={align}
        brand={brand}
        actions={<button type="button">Sign in</button>}
      >
        {children}
      </PlHeader>
    </div>
  );

  const row = document.querySelector('header')!.firstElementChild as HTMLElement;
  const style = getComputedStyle(row);
  const box = row.getBoundingClientRect();

  return {
    row,
    // The row's own edges, inside its gutter.
    start:
      dir === 'ltr'
        ? box.left + parseFloat(style.paddingLeft)
        : box.right - parseFloat(style.paddingRight),
    end:
      dir === 'ltr'
        ? box.right - parseFloat(style.paddingRight)
        : box.left + parseFloat(style.paddingLeft),
    gap: parseFloat(style.columnGap)
  };
}

/** A box's leading and trailing edges, in the direction the row reads. */
function edges(element: Element, dir: Dir) {
  const box = element.getBoundingClientRect();

  return dir === 'ltr' ? { start: box.left, end: box.right } : { start: box.right, end: box.left };
}

const packed: { align: PlassAlign; dir: Dir }[] = [
  { align: 'start', dir: 'ltr' },
  { align: 'start', dir: 'rtl' },
  { align: 'end', dir: 'ltr' },
  { align: 'end', dir: 'rtl' }
];

describe('a PlHeader with no middle', () => {
  it.each(packed)('puts the actions at the far end at $align, $dir', async ({ align, dir }) => {
    const bar = await renderBar({ align, dir });
    const [brand, actions] = bar.row.children;

    expect(bar.row.children).toHaveLength(2);
    expect(edges(brand!, dir).start).toBeCloseTo(bar.start, 0);
    expect(edges(actions!, dir).end).toBeCloseTo(bar.end, 0);
  });

  it('puts the actions at the far end with no brand either', async () => {
    const bar = await renderBar({ align: 'start', dir: 'ltr', brand: null });

    expect(bar.row.children).toHaveLength(1);
    expect(edges(bar.row.children[0]!, 'ltr').end).toBeCloseTo(bar.end, 0);
  });
});

describe('a PlHeader with a middle', () => {
  it.each(packed)(
    'fills the room between the ends with the middle at $align, $dir',
    async ({ align, dir }) => {
      const bar = await renderBar({ align, dir, children: <span>Docs</span> });
      const [brand, middle, actions] = bar.row.children;

      expect(edges(brand!, dir).start).toBeCloseTo(bar.start, 0);
      expect(edges(actions!, dir).end).toBeCloseTo(bar.end, 0);

      const sign = dir === 'ltr' ? 1 : -1;

      expect(edges(middle!, dir).start).toBeCloseTo(edges(brand!, dir).end + sign * bar.gap, 0);
      expect(edges(middle!, dir).end).toBeCloseTo(edges(actions!, dir).start - sign * bar.gap, 0);
    }
  );
});
