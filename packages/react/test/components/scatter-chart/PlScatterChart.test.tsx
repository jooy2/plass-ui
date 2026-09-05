import { describe, expect, it } from 'vitest';
import { PlScatterChart } from 'plass-ui';
import { render } from 'vitest-browser-react';

const SPEND = [
  {
    name: 'Q1',
    data: [
      { x: 10, y: 22 },
      { x: 20, y: 31 },
      { x: 30, y: 28 }
    ]
  },
  {
    name: 'Q2',
    data: [
      { x: 12, y: 40 },
      { x: 26, y: 35 }
    ]
  }
];

/** Every mark drawn, in paint order. */
function marks(plot: Element): SVGPathElement[] {
  return [...plot.querySelectorAll<SVGPathElement>('svg path[fill]:not([fill="none"])')];
}

describe('PlScatterChart', () => {
  describe('rendering', () => {
    it('draws one mark per point', async () => {
      const screen = await render(<PlScatterChart label="Spend" series={SPEND} />);

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();
      expect(marks(plot.element()).length).toBe(5);
    });

    it('draws nothing for a point with no value', async () => {
      const screen = await render(
        <PlScatterChart
          label="Spend"
          series={[
            {
              name: 'Q1',
              data: [
                { x: 1, y: 2 },
                { x: 2, y: null },
                { x: 3, y: 4 }
              ]
            }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();
      expect(marks(plot.element()).length).toBe(2);
    });

    it('puts numbers on the category axis rather than indices', async () => {
      const screen = await render(<PlScatterChart label="Spend" series={SPEND} />);

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();

      const ticks = [...plot.element().querySelectorAll('text')].map((one) => one.textContent);

      // A band axis would print 0, 1, 2 — one per column. A value axis prints
      // the range the data is actually in.
      expect(ticks).toContain('30');
      expect(ticks).not.toContain('Q1');
    });
  });

  describe('the table', () => {
    it('writes a row per point rather than a grid', async () => {
      const screen = await render(<PlScatterChart label="Spend" series={SPEND} />);
      const table = screen.getByRole('table', { name: 'Spend' });

      await expect.element(table).toBeInTheDocument();
      expect(table.element().querySelectorAll('tbody tr').length).toBe(5);
    });

    it('names the columns from the axis labels when there are any', async () => {
      const screen = await render(
        <PlScatterChart
          label="Spend"
          series={SPEND}
          xAxis={{ label: 'Budget' }}
          yAxis={{ label: 'Revenue' }}
        />
      );

      await expect
        .element(screen.getByRole('columnheader', { name: 'Budget' }))
        .toBeInTheDocument();
      await expect
        .element(screen.getByRole('columnheader', { name: 'Revenue' }))
        .toBeInTheDocument();
    });

    it('falls back to the names the data model uses', async () => {
      const screen = await render(<PlScatterChart label="Spend" series={SPEND} />);

      await expect.element(screen.getByRole('columnheader', { name: 'x' })).toBeInTheDocument();
      await expect.element(screen.getByRole('columnheader', { name: 'y' })).toBeInTheDocument();
      expect(screen.getByRole('columnheader', { name: 'z' }).query()).toBeNull();
    });

    it('adds a z column only when a point carries one', async () => {
      const screen = await render(
        <PlScatterChart label="Spend" series={[{ name: 'Q1', data: [{ x: 1, y: 2, z: 9 }] }]} />
      );

      await expect.element(screen.getByRole('columnheader', { name: 'z' })).toBeInTheDocument();
    });

    it('leaves a gap as an empty cell rather than a zero', async () => {
      const screen = await render(
        <PlScatterChart
          label="Spend"
          // A point beside the gap, because a chart made entirely of gaps has
          // no extent and draws its empty state rather than a table.
          series={[
            {
              name: 'Q1',
              data: [
                { x: 1, y: null },
                { x: 2, y: 5 }
              ]
            }
          ]}
        />
      );

      const table = screen.getByRole('table', { name: 'Spend' });

      await expect.element(table).toBeInTheDocument();

      const cells = [...table.element().querySelectorAll('tbody td')].map((one) =>
        one.textContent?.trim()
      );

      expect(cells).toEqual(['1', '', '2', '5']);
    });
  });

  describe('shape', () => {
    /**
     * A circle's path is four arcs and every other shape's is straight lines,
     * so the command letters are what say which shape was drawn.
     */
    const commands = (path: SVGPathElement) =>
      (path.getAttribute('d') ?? '').replace(/[-\d. ]/g, '');

    it('keeps every mark a circle while colour can carry identity', async () => {
      const screen = await render(<PlScatterChart label="Spend" series={SPEND} />);

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();
      expect(new Set(marks(plot.element()).map(commands)).size).toBe(1);
    });

    it('gives each series its own shape past the third', async () => {
      const four = [1, 2, 3, 4].map((n) => ({ name: `S${n}`, data: [{ x: n, y: n }] }));
      const screen = await render(<PlScatterChart label="Spend" series={four} />);

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();
      expect(new Set(marks(plot.element()).map(commands)).size).toBe(4);
    });

    it('does not count a series that brought its own colour', async () => {
      const four = [1, 2, 3, 4].map((n) => ({
        name: `S${n}`,
        color: '#123456',
        data: [{ x: n, y: n }]
      }));
      const screen = await render(<PlScatterChart label="Spend" series={four} />);

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();
      expect(new Set(marks(plot.element()).map(commands)).size).toBe(1);
    });

    it('varies the shapes on request even with one series', async () => {
      const screen = await render(
        <PlScatterChart label="Spend" shape="varied" series={[SPEND[0], SPEND[1]]} />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();
      expect(new Set(marks(plot.element()).map(commands)).size).toBe(2);
    });

    it('takes a single named shape for every mark', async () => {
      const screen = await render(<PlScatterChart label="Spend" shape="diamond" series={SPEND} />);

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();

      const drawn = new Set(marks(plot.element()).map(commands));

      expect(drawn.size).toBe(1);
      // A diamond is four line segments and a close; a circle would be arcs.
      expect([...drawn][0]).not.toContain('A');
    });
  });

  describe('bubbles', () => {
    it('scales a z by area rather than by radius', async () => {
      const screen = await render(
        <PlScatterChart
          label="Spend"
          series={[
            {
              name: 'Q1',
              data: [
                { x: 1, y: 1, z: 100 },
                { x: 2, y: 2, z: 25 }
              ]
            }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();

      // Circles, so the path's first horizontal move is the diameter. Four
      // times the z is twice the radius, never four times it.
      const widths = marks(plot.element())
        .map((path) => Number(/a([\d.]+)/.exec(path.getAttribute('d') ?? '')?.[1]))
        .sort((a, b) => b - a);

      expect(widths[0] / widths[1]).toBeCloseTo(2, 1);
    });
  });
});
