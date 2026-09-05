import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAreaChart } from 'plass-ui';

const MONTHS = ['Jan', 'Feb', 'Mar'];

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
  });
});
