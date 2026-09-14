/**
 * A masonry's lanes, as the browser lays them out.
 *
 * `PlGallery.test.tsx` asserts which column and which row lines each tile is
 * given. Whether those lines draw a masonry is up to CSS Grid: the rows are
 * shares in `fr` that only come out one column width long in a grid whose
 * height is its content, and every tile is a subgrid of the rows it spans. So
 * the thing under test here is the layout, with `src/standalone.css` loaded
 * the way `grid.test.tsx` loads it.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlGallery, type PlGalleryItem } from 'plass-ui';
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

// One picture twice as tall as it is wide, and two squares. In two lanes the
// tall one fills the first and the squares stack in the second.
const items: PlGalleryItem[] = [
  { src: '/a.jpg', alt: 'A tower', ratio: 0.5 },
  { src: '/b.jpg', alt: 'A square', ratio: 1, title: 'Square' },
  { src: '/c.jpg', alt: 'A courtyard', ratio: 1 }
];

/** Each tile's box, relative to the gallery's. */
function boxes(): Array<{ x: number; y: number; width: number; height: number }> {
  const list = document.querySelector('.plass-gallery')!.getBoundingClientRect();

  return Array.from(document.querySelectorAll('.plass-gallery > li')).map((tile) => {
    const box = tile.getBoundingClientRect();

    return { x: box.x - list.x, y: box.y - list.y, width: box.width, height: box.height };
  });
}

/** The height of the picture box inside a tile. */
function picture(alt: string): number {
  return document.querySelector(`img[alt="${alt}"]`)!.parentElement!.getBoundingClientRect().height;
}

describe('the masonry layout', () => {
  it('stacks each lane with one gap between its tiles', async () => {
    await render(
      <div style={{ width: '408px' }}>
        <PlGallery items={items} layout="masonry" columns={2} gap={8} />
      </div>
    );

    // Two lanes of (408 - 8) / 2 = 200 pixels.
    const [tower, square, courtyard] = boxes();

    expect(tower).toMatchObject({ x: 0, y: 0, width: 200 });
    expect(square).toMatchObject({ x: 208, y: 0, width: 200, height: 200 });
    expect(courtyard).toMatchObject({ x: 208, y: 208, width: 200, height: 200 });
    // The tower runs past the end of the square, so it spans the gap under it
    // too: two column widths and one gap.
    expect(tower.height).toBe(408);
  });

  it('gives a caption below its own row rather than stretching the pictures', async () => {
    await render(
      <div style={{ width: '408px' }}>
        <PlGallery items={items} layout="masonry" columns={2} gap={8} caption="below" />
      </div>
    );

    const [tower, square, courtyard] = boxes();
    const words = square.height - 200;

    expect(words).toBeGreaterThan(0);
    // The square's picture keeps its shape, and the courtyard starts one gap
    // under the square's caption.
    expect(picture('A square')).toBe(200);
    expect(picture('A courtyard')).toBe(200);
    expect(courtyard.y).toBe(square.height + 8);
    // The courtyard has no caption and the edge it ends on has no other, so
    // its caption row is empty.
    expect(courtyard.height).toBe(200);
    expect(tower.height).toBe(408 + words);
  });
});
