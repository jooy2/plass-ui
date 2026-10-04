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
import { act } from 'react';
import { hydrateRoot } from 'react-dom/client';
import { renderToString } from 'react-dom/server';
import { afterAll, afterEach, beforeAll, describe, expect, it, vi } from 'vitest';
import { page } from 'vitest/browser';
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

describe('a masonry a server rendered', () => {
  /*
   * The default columns are two, three from `sm` and four from `lg`, and the
   * lane count is what the stylesheet chooses rather than what a script
   * measures, so the markup a server sends is already laid out in the lanes of
   * the window it lands in, and hydrating it moves nothing.
   */
  const set: PlGalleryItem[] = Array.from({ length: 8 }, (_, index) => ({
    src: `/${index}.jpg`,
    alt: `Picture ${index + 1}`,
    ratio: [1, 0.75, 1.5, 1][index % 4]
  }));

  let initial: [number, number];
  const hosts: HTMLElement[] = [];

  beforeAll(() => {
    initial = [window.innerWidth, window.innerHeight];
  });

  afterEach(async () => {
    hosts.splice(0).forEach((host) => host.remove());
    await page.viewport(...initial);
  });

  function serve() {
    const host = document.createElement('div');

    host.innerHTML = renderToString(<PlGallery items={set} layout="masonry" />);
    document.body.append(host);
    hosts.push(host);

    return host;
  }

  const lanes = () => new Set(boxes().map((box) => box.x)).size;

  it('has the lanes of a wide window before it hydrates, and keeps them', async () => {
    await page.viewport(1100, 800);

    const host = serve();
    const before = boxes();
    const onRecoverableError = vi.fn();

    expect(lanes()).toBe(4);

    const root = await act(async () =>
      hydrateRoot(host, <PlGallery items={set} layout="masonry" />, { onRecoverableError })
    );

    try {
      expect(onRecoverableError).not.toHaveBeenCalled();
      expect(boxes()).toEqual(before);
    } finally {
      await act(async () => root.unmount());
    }
  });

  it('has the lanes of a narrow window from the same markup', async () => {
    await page.viewport(500, 800);
    serve();

    expect(lanes()).toBe(2);

    // The same markup, wider: the stylesheet switches to the deal for three
    // lanes without a script running.
    await page.viewport(800, 800);

    expect(lanes()).toBe(3);
  });
});
