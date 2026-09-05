import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlGallery, type PlGalleryItem } from 'plass-ui';

const items: PlGalleryItem[] = [
  { src: '/a.jpg', alt: 'A harbour', title: 'Harbour', description: 'Busan' },
  { src: '/b.jpg', alt: 'A bridge', ratio: 1.5 },
  { src: '/c.jpg', alt: 'A hillside', ratio: 0.75 },
  { src: '/d.jpg', alt: 'A market' }
];

const tiles = () => Array.from(document.querySelectorAll<HTMLElement>('.plass-gallery li'));

/** Each picture's box, as the aspect ratio it was laid out at. */
const shapes = () =>
  Array.from(document.querySelectorAll<HTMLElement>('.plass-gallery li span')).flatMap((node) =>
    node.style.aspectRatio ? [node.style.aspectRatio] : []
  );

const pictures = () =>
  Array.from(document.querySelectorAll<HTMLImageElement>('.plass-gallery img')).map(
    (node) => node.alt
  );

describe('PlGallery', () => {
  describe('rendering', () => {
    it('is a named list of pictures', async () => {
      const screen = await render(<PlGallery items={items} />);

      await expect.element(screen.getByRole('list', { name: 'Gallery' })).toBeInTheDocument();
      expect(pictures()).toEqual(['A harbour', 'A bridge', 'A hillside', 'A market']);
    });

    it('takes a name of its own', async () => {
      const screen = await render(<PlGallery items={items} label="Trip photos" />);

      await expect.element(screen.getByRole('list', { name: 'Trip photos' })).toBeInTheDocument();
    });

    it('draws nothing at all for an empty set', async () => {
      await render(<PlGallery items={[]} />);

      expect(tiles()).toHaveLength(0);
    });

    it('draws what it was given instead, when there is one', async () => {
      const screen = await render(<PlGallery items={[]} empty={<p>No pictures yet</p>} />);

      await expect.element(screen.getByText('No pictures yet')).toBeInTheDocument();
      expect(document.querySelector('.plass-gallery')).toBeNull();
    });

    it('reflects a changed set on re-render', async () => {
      const screen = await render(<PlGallery items={items.slice(0, 2)} />);

      expect(pictures()).toHaveLength(2);

      await screen.rerender(<PlGallery items={items} />);

      expect(pictures()).toHaveLength(4);
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      await render(<PlGallery items={items} className="my-own-class" />);

      expect(document.querySelector('.plass-gallery')).toHaveClass('my-own-class');
    });

    it('reaches the parts a className does not', async () => {
      await render(
        <PlGallery
          items={items}
          caption="below"
          classNames={{ item: 'my-item', caption: 'my-caption', title: 'my-title' }}
        />
      );

      expect(document.querySelector('.my-item')).not.toBeNull();
      expect(document.querySelector('.my-caption')).not.toBeNull();
      expect(document.querySelector('.my-title')).not.toBeNull();
    });
  });

  describe('the layouts', () => {
    it('grids by default', async () => {
      await render(<PlGallery items={items} />);

      const list = document.querySelector('.plass-gallery')!;

      expect(list).toHaveClass('plass-gallery-grid');
      expect(tiles()).toHaveLength(4);
    });

    it('gives every grid tile the gallery own ratio, whatever shape the file is', async () => {
      await render(<PlGallery items={items} ratio={1.5} />);

      // The second and third items declare 1.5 and 0.75 of their own; a contact
      // sheet is a contact sheet and takes neither.
      expect(shapes()).toEqual(['1.5 / 1', '1.5 / 1', '1.5 / 1', '1.5 / 1']);
    });

    it('keeps each picture own shape in a masonry', async () => {
      await render(<PlGallery items={items} layout="masonry" ratio={1} columns={1} />);

      expect(shapes()).toEqual(['1 / 1', '1.5 / 1', '0.75 / 1', '1 / 1']);
    });

    it('deals a masonry into lanes rather than into tiles', async () => {
      await render(<PlGallery items={items} layout="masonry" columns={2} />);

      // Two lanes, each an `<li>` holding a `<ul>` of its own tiles.
      const lanes = Array.from(document.querySelectorAll('.plass-gallery > li'));

      expect(lanes).toHaveLength(2);
      expect(lanes.every((lane) => lane.querySelector('ul') !== null)).toBe(true);
      expect(pictures()).toHaveLength(4);
    });

    it('grows a justified tile in proportion to its own picture', async () => {
      await render(<PlGallery items={items} layout="justified" rowHeight={200} />);

      const second = tiles()[1];

      expect(second.style.flexGrow).toBe('1.5');
      expect(second.style.flexBasis).toBe('300px');
    });

    it('spans a quilted tile over the cells it asked for', async () => {
      await render(
        <PlGallery
          items={[{ src: '/a.jpg', alt: 'A harbour', cols: 2, rows: 2 }, items[1]]}
          layout="quilted"
        />
      );

      expect(tiles()[0].style.gridColumn).toBe('span 2');
      expect(tiles()[0].style.gridRow).toBe('span 2');
      expect(tiles()[1].style.gridColumn).toBe('span 1');
    });

    it('writes the column count into the cascade', async () => {
      await render(<PlGallery items={items} columns={{ xs: 1, md: 3 }} />);

      const list = document.querySelector('.plass-gallery') as HTMLElement;

      expect(list.style.getPropertyValue('--p-cols-xs')).toBe('1');
      expect(list.style.getPropertyValue('--p-cols-md')).toBe('3');
    });

    it('takes the gap as a step, a number or a length', async () => {
      const screen = await render(<PlGallery items={items} gap="lg" />);

      expect((document.querySelector('.plass-gallery') as HTMLElement).style.gap).toBe('0.75rem');

      await screen.rerender(<PlGallery items={items} gap={20} />);
      expect((document.querySelector('.plass-gallery') as HTMLElement).style.gap).toBe('20px');

      await screen.rerender(<PlGallery items={items} gap="2ch" />);
      expect((document.querySelector('.plass-gallery') as HTMLElement).style.gap).toBe('2ch');
    });
  });

  describe('captions', () => {
    // Exact, every time. None of these `src` values resolves, so each tile
    // eventually falls back to its own alt text — and a loose `Harbour` matches
    // `A harbour` as well, which makes the query a race against the image.
    it('says nothing by default', async () => {
      const screen = await render(<PlGallery items={items} />);

      expect(screen.getByText('Harbour', { exact: true }).query()).toBeNull();
    });

    it('writes the two lines under the picture', async () => {
      const screen = await render(<PlGallery items={items} caption="below" />);

      await expect.element(screen.getByText('Harbour', { exact: true })).toBeInTheDocument();
      await expect.element(screen.getByText('Busan', { exact: true })).toBeInTheDocument();
    });

    it('writes them across the foot of it instead', async () => {
      const screen = await render(<PlGallery items={items} caption="overlay" />);

      await expect.element(screen.getByText('Harbour', { exact: true })).toBeInTheDocument();
    });

    it('leaves the caption out of a tile that has no words', async () => {
      await render(<PlGallery items={items} caption="below" />);

      // Only the first item has a title or a description.
      expect(document.querySelectorAll('.plass-gallery li > div').length).toBe(1);
    });
  });

  describe('choosing', () => {
    it('is not a button unless something happens when it is pressed', async () => {
      const screen = await render(<PlGallery items={items} />);

      expect(screen.getByRole('button').query()).toBeNull();
    });

    it('reports the tile that was chosen', async () => {
      const onItemSelect = vi.fn();
      const screen = await render(<PlGallery items={items} onItemSelect={onItemSelect} />);

      await screen.getByRole('button', { name: /A bridge/ }).click();

      expect(onItemSelect).toHaveBeenCalledWith(items[1], 1);
    });

    it('names a tile by its picture and its place in the set', async () => {
      const screen = await render(<PlGallery items={items} onItemSelect={() => {}} />);

      await expect
        .element(screen.getByRole('button', { name: 'A harbour — 1 of 4' }))
        .toBeInTheDocument();
    });

    it('takes its own way of saying where in the set a tile is', async () => {
      const screen = await render(
        <PlGallery
          items={items}
          onItemSelect={() => {}}
          itemLabel={(index, total) => `${index}번째 / 전체 ${total}`}
        />
      );

      await expect
        .element(screen.getByRole('button', { name: 'A harbour — 1번째 / 전체 4' }))
        .toBeInTheDocument();
    });
  });

  describe('the viewer', () => {
    it('is not there until a tile is pressed', async () => {
      const screen = await render(<PlGallery items={items} preview />);

      expect(screen.getByRole('dialog').query()).toBeNull();
    });

    it('opens the picture that was chosen', async () => {
      const screen = await render(<PlGallery items={items} preview />);

      await screen.getByRole('button', { name: /A bridge/ }).click();

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
      await expect
        .poll(() => document.querySelector('[role="dialog"] img')?.getAttribute('alt'))
        .toBe('A bridge');
    });

    it('prefers the larger file when there is one', async () => {
      const screen = await render(
        <PlGallery items={[{ src: '/small.jpg', full: '/big.jpg', alt: 'A harbour' }]} preview />
      );

      await screen.getByRole('button', { name: /A harbour/ }).click();

      await expect
        .poll(() => document.querySelector('[role="dialog"] img')?.getAttribute('src'))
        .toBe('/big.jpg');
    });

    it('walks the set with the arrow keys', async () => {
      const screen = await render(<PlGallery items={items} preview />);

      await screen.getByRole('button', { name: /A harbour/ }).click();
      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();

      const dialog = document.querySelector('[role="dialog"]')!;

      dialog.dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true, cancelable: true })
      );

      await expect
        .poll(() => document.querySelector('[role="dialog"] img')?.getAttribute('alt'))
        .toBe('A bridge');

      dialog.dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowLeft', bubbles: true, cancelable: true })
      );

      await expect
        .poll(() => document.querySelector('[role="dialog"] img')?.getAttribute('alt'))
        .toBe('A harbour');
    });

    it('stops at the ends rather than wrapping', async () => {
      const screen = await render(<PlGallery items={items} preview />);

      await screen.getByRole('button', { name: /A harbour/ }).click();
      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();

      await expect.element(screen.getByRole('button', { name: 'Previous' })).toBeDisabled();
      await expect.element(screen.getByRole('button', { name: 'Next' })).toBeEnabled();
    });

    it('says where in the set it is', async () => {
      const screen = await render(<PlGallery items={items} preview />);

      await screen.getByRole('button', { name: /A hillside/ }).click();

      await expect.element(screen.getByText('3 of 4')).toBeInTheDocument();
    });

    it('offers no arrows for a set of one', async () => {
      const screen = await render(
        <PlGallery items={[{ src: '/a.jpg', alt: 'A harbour' }]} preview />
      );

      await screen.getByRole('button', { name: /A harbour/ }).click();
      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();

      expect(screen.getByRole('button', { name: 'Next' }).query()).toBeNull();
    });
  });
});
