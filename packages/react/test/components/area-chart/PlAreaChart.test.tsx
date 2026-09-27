import { commands } from 'vitest/browser';
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAreaChart } from 'plass-ui';

const MONTHS = ['Jan', 'Feb', 'Mar'];

/**
 * The series' marks on a plot in the order they are painted: the bands, the
 * lines and the gaps between the bands, the markers, and the value labels,
 * which are the only text written at 600. What a mask holds is not painted.
 */
function painted(plot: Element): Element[] {
  return [...plot.querySelectorAll('path, circle, text[font-weight="600"]')].filter(
    (mark) => mark.closest('defs') === null
  );
}

describe('PlAreaChart', () => {
  describe('rendering', () => {
    it('fills under each series as well as drawing it', async () => {
      const screen = await render(
        <PlAreaChart
          label="Storage"
          categories={MONTHS}
          series={[{ name: 'Hot', data: [10, 20, 30] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Storage' });

      await expect.element(plot).toBeInTheDocument();
      // One filled path and one stroked one — the wash and the edge.
      expect(plot.element().querySelectorAll('path[fill^="url("]').length).toBe(1);
      expect(plot.element().querySelectorAll('path[stroke]:not([stroke="none"])').length).toBe(1);
    });

    it('writes its data into a table', async () => {
      const screen = await render(
        <PlAreaChart
          label="Storage by tier"
          categories={MONTHS}
          series={[{ name: 'Hot', data: [10, 20, 30] }]}
        />
      );

      await expect
        .element(screen.getByRole('table', { name: 'Storage by tier' }))
        .toBeInTheDocument();
      await expect.element(screen.getByRole('cell', { name: '20' })).toBeInTheDocument();
    });

    it('is described by what its empty state says', async () => {
      // The words are drawn inside the picture, where nothing is read, so the
      // description is the one way to them.
      const screen = await render(
        <PlAreaChart label="Storage by tier" series={[]} empty={<em>Nothing yet</em>} />
      );

      await expect
        .element(screen.getByRole('img', { name: 'Storage by tier' }))
        .toHaveAccessibleDescription('Nothing yet');
    });

    it('reflects a changed curve on re-render', async () => {
      const screen = await render(
        <PlAreaChart
          label="Storage"
          categories={MONTHS}
          series={[{ name: 'Hot', data: [1, 2, 3] }]}
        />
      );

      const before = screen
        .getByRole('img', { name: 'Storage' })
        .element()
        .querySelector('path[fill^="url("]')
        ?.getAttribute('d');

      await screen.rerender(
        <PlAreaChart
          label="Storage"
          curve="smooth"
          categories={MONTHS}
          series={[{ name: 'Hot', data: [1, 2, 3] }]}
        />
      );

      const after = screen
        .getByRole('img', { name: 'Storage' })
        .element()
        .querySelector('path[fill^="url("]')
        ?.getAttribute('d');

      expect(after).not.toBe(before);
      expect(after).toContain('C');
    });
  });

  describe('stacked', () => {
    it('swaps the wash for a flat tint and separates the bands', async () => {
      const screen = await render(
        <PlAreaChart
          label="Storage"
          stacked
          categories={MONTHS}
          series={[
            { name: 'Hot', data: [10, 20, 30] },
            { name: 'Archive', data: [40, 50, 60] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Storage' });

      await expect.element(plot).toBeInTheDocument();
      // No gradient fills once stacked, and one surface-coloured rule between
      // the two bands.
      expect(plot.element().querySelectorAll('path[fill^="url("]').length).toBe(0);
      expect(plot.element().querySelectorAll('path[stroke="var(--plass-chart-gap)"]').length).toBe(
        1
      );
    });

    it('draws every band’s markers and value labels after every band', async () => {
      const screen = await render(
        <PlAreaChart
          label="Storage"
          stacked
          markers="all"
          valueLabels="all"
          categories={MONTHS}
          series={[
            { name: 'Hot', data: [10, 20, 30] },
            { name: 'Warm', data: [40, 50, 60] },
            { name: 'Archive', data: [20, 20, 20] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Storage' });

      await expect.poll(() => painted(plot.element()).length).toBeGreaterThan(0);

      // In the order they are painted: the three bands and the two gaps
      // between them, then the nine markers, then the nine labels, so the band
      // above a lower one lies under its markers and its labels rather than
      // over them.
      expect(painted(plot.element()).map((mark) => mark.tagName)).toEqual([
        ...Array(5).fill('path'),
        ...Array(9).fill('circle'),
        ...Array(9).fill('text')
      ]);
    });

    it('fades a band’s markers and labels with it, cut out of its band', async () => {
      // The pointer is still wherever the previous file left it, and resting on
      // the legend it would fade a band before the test points at one.
      await commands.parkPointer();

      const screen = await render(
        <PlAreaChart
          label="Storage"
          stacked
          markers="all"
          valueLabels="all"
          categories={MONTHS}
          series={[
            { name: 'Hot', color: '#c03030', data: [10, 20, 30] },
            { name: 'Archive', color: '#3030c0', data: [40, 50, 60] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Storage' });

      await expect.poll(() => painted(plot.element()).length).toBeGreaterThan(0);
      expect(plot.element().querySelector('mask')).toBeNull();

      // Pointing the legend at Archive fades Hot.
      screen.getByRole('button', { name: 'Archive' }).element().focus();

      const hot = () => [...plot.element().querySelectorAll('circle[fill="#c03030"]')];

      await expect
        .poll(() => hot().map((marker) => marker.closest('g')?.getAttribute('opacity')))
        .toEqual(['0.28', '0.28', '0.28']);

      const archive = [...plot.element().querySelectorAll('circle[fill="#3030c0"]')];
      const labels = [...plot.element().querySelectorAll('svg text[font-weight="600"]')];

      expect(archive.map((marker) => marker.closest('g')?.getAttribute('opacity'))).toEqual([
        '1',
        '1',
        '1'
      ]);
      expect(labels.map((label) => label.closest('g')?.getAttribute('opacity'))).toEqual([
        ...Array(3).fill('0.28'),
        ...Array(3).fill('1')
      ]);

      // Hot's own band is cut away under each of its markers, out to the edge
      // of the ring, so it does not show through them; Archive's is whole.
      const bands = [...plot.element().querySelectorAll('path[fill^="color-mix"]')].map((band) =>
        band.closest('g')!
      );
      const cut = bands[0].getAttribute('mask')?.match(/^url\(#(.+)\)$/)?.[1];
      const holes = [...plot.element().querySelectorAll(`mask[id="${cut}"] circle`)];

      expect(bands[1].hasAttribute('mask')).toBe(false);
      expect(holes.map((hole) => [hole.getAttribute('cx'), hole.getAttribute('cy')])).toEqual(
        hot().map((marker) => [marker.getAttribute('cx'), marker.getAttribute('cy')])
      );
      expect(holes.map((hole) => Number(hole.getAttribute('r')))).toEqual(
        hot().map((marker) => Number(marker.getAttribute('r')) + 1)
      );

      (document.activeElement as HTMLElement).blur();

      await expect.poll(() => plot.element().querySelector('mask')).toBeNull();
    });

    it('turns the value axis into a percentage with full', async () => {
      const screen = await render(
        <PlAreaChart
          label="Mix"
          stacked="full"
          categories={['Jan']}
          series={[
            { name: 'New', data: [40] },
            { name: 'Renewed', data: [160] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Mix' });

      await expect.element(plot).toBeInTheDocument();

      const ticks = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(ticks).toContain('100%');
      expect(ticks).toContain('0%');
    });

    it('keeps the caller’s own numbers in the table when stacking to full', async () => {
      const screen = await render(
        <PlAreaChart
          label="Mix"
          stacked="full"
          categories={['Jan']}
          series={[
            { name: 'New', data: [40] },
            { name: 'Renewed', data: [160] }
          ]}
        />
      );

      const table = screen.getByRole('table', { name: 'Mix' });

      await expect.element(table).toBeInTheDocument();

      const cells = [...table.element().querySelectorAll('tbody td')].map((cell) =>
        cell.textContent?.trim()
      );

      expect(cells).toEqual(['40', '160']);
    });

    it('writes those numbers in the caller’s format when stacking to full', async () => {
      const screen = await render(
        <PlAreaChart
          label="Mix"
          stacked="full"
          format={{ style: 'currency', currency: 'USD', maximumFractionDigits: 0 }}
          locale="en-US"
          categories={['Jan']}
          series={[
            { name: 'New', data: [4000] },
            { name: 'Renewed', data: [16000] }
          ]}
        />
      );

      const table = screen.getByRole('table', { name: 'Mix' });

      await expect.element(table).toBeInTheDocument();
      expect(
        [...table.element().querySelectorAll('tbody td')].map((cell) => cell.textContent?.trim())
      ).toEqual(['$4,000', '$16,000']);
    });
  });
});
