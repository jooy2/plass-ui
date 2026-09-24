import * as React from 'react';
import { describe, expect, it } from 'vitest';
import { PlScatterChart } from 'plass-ui';
import { render } from 'vitest-browser-react';
import { committed } from '../../support/timing';

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

/**
 * Resolves once `element` has been reported to a `ResizeObserver`. Observers
 * report in the order they were made, so one made after the chart's own reports
 * after the chart's has.
 */
function reported(element: Element): Promise<void> {
  return new Promise((resolve) => {
    const observer = new ResizeObserver(() => {
      observer.disconnect();
      resolve();
    });

    observer.observe(element);
  });
}

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

    it('writes an element its x tickFormat returns as the words in it', async () => {
      const screen = await render(
        <PlScatterChart
          label="Spend"
          xAxis={{ tickFormat: (value) => <i>{`x${String(value)}`}</i> }}
          series={SPEND}
        />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent ?? '');

      // A value-scaled category axis writes its own ticks rather than the
      // points' labels, through the same reading as a column's name.
      expect(texts.some((text) => /^x\d+$/.test(text))).toBe(true);
      expect(texts.join(' ')).not.toContain('[object Object]');
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

    it('ticks an axis of dates like a calendar, and hands tickFormat a date', async () => {
      const day = (date: number) => new Date(2026, 2, date);
      const seen: unknown[] = [];
      const screen = await render(
        <PlScatterChart
          label="Deploys"
          locale="en-US"
          xAxis={{
            tickFormat: (value) => {
              seen.push(value);

              return String(value instanceof Date ? value.getDate() : value);
            }
          }}
          series={[
            {
              name: 'Web',
              data: [
                { x: day(1), y: 3 },
                { x: day(9), y: 5 },
                { x: day(20), y: 4 }
              ]
            }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Deploys' });

      await expect.element(plot).toBeInTheDocument();
      await expect.poll(() => seen.length).toBeGreaterThan(0);
      expect(seen.every((value) => value instanceof Date)).toBe(true);

      await screen.rerender(
        <PlScatterChart
          label="Deploys"
          locale="en-US"
          series={[
            {
              name: 'Web',
              data: [
                { x: day(1), y: 3 },
                { x: day(9), y: 5 },
                { x: day(20), y: 4 }
              ]
            }
          ]}
        />
      );

      const texts = () =>
        [...plot.element().querySelectorAll('text')].map((one) => one.textContent ?? '');

      await expect.poll(() => texts().some((text) => text.includes('Mar'))).toBe(true);
      expect(texts().some((text) => /\d{6,}|T$/.test(text))).toBe(false);
    });
  });

  describe('the pointer', () => {
    it('renders again only when the nearest mark changes', async () => {
      let commits = 0;

      const screen = await render(
        <React.Profiler id="chart" onRender={() => (commits += 1)}>
          <PlScatterChart label="Spend" series={SPEND} />
        </React.Profiler>
      );

      const host = screen.getByRole('img', { name: 'Spend' }).element() as HTMLElement;
      const box = host.getBoundingClientRect();
      const move = (x: number, y: number) =>
        host.dispatchEvent(
          new PointerEvent('pointermove', {
            bubbles: true,
            clientX: box.left + x,
            clientY: box.top + y
          })
        );

      // React can still render a component once for a state update that changes
      // nothing when it lands soon after a render, and it renders in a task of
      // its own. Here that update is the chart's first size report or its first
      // move, whichever comes first, and a count taken a frame later can be
      // taken on either side of that render. So it is taken once the size has
      // been reported and the first move answered, with every render either of
      // them asked for committed.
      await committed(async () => {
        await reported(host);
        // The top-left corner of the plot is far from every point, so no mark is
        // near the pointer at any of these pixels.
        move(2, 2);
      });

      const settled = commits;

      await committed(() => {
        for (let pixel = 3; pixel < 13; pixel += 1) {
          move(pixel, pixel);
        }
      });

      expect(commits).toBe(settled);
    });

    /**
     * An entry that is switched off has no marks on the plot to be highlighted,
     * so pointing at it must leave the marks that are drawn where they are.
     */
    it('leaves the drawn marks alone while a hidden entry is pointed at', async () => {
      const screen = await render(
        <PlScatterChart label="Spend" series={[SPEND[0], { ...SPEND[1], hidden: true }]} />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });

      await expect.element(plot).toBeInTheDocument();

      const entry = screen.getByRole('button', { name: 'Q2' });

      await expect.element(entry).toHaveAttribute('aria-pressed', 'false');
      await entry.hover();

      expect(marks(plot.element()).map((one) => one.getAttribute('opacity'))).toEqual([
        '1',
        '1',
        '1'
      ]);
    });
  });

  describe('the keyboard', () => {
    it('walks the marks one at a time, and Home and End go to either end', async () => {
      const screen = await render(<PlScatterChart label="Spend" series={SPEND} />);
      const plot = screen.getByRole('img', { name: 'Spend' });
      const status = () => screen.getByRole('status').element().textContent;

      await expect.element(plot).toBeInTheDocument();

      // Series by series, each point's own x and then its series and y.
      for (const [key, reading] of [
        ['ArrowRight', '10, Q1: 22'],
        ['ArrowRight', '20, Q1: 31'],
        ['ArrowRight', '30, Q1: 28'],
        ['ArrowRight', '12, Q2: 40'],
        ['ArrowRight', '26, Q2: 35'],
        ['ArrowRight', '26, Q2: 35'],
        ['Home', '10, Q1: 22'],
        ['End', '26, Q2: 35'],
        ['ArrowLeft', '12, Q2: 40']
      ] as const) {
        plot
          .element()
          .dispatchEvent(new KeyboardEvent('keydown', { key, bubbles: true, cancelable: true }));
        await expect.poll(status).toBe(reading);
      }
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

    it('writes y and z as every chart writes a value, and x as the card heads a point', async () => {
      const cellsOf = (element: Element) =>
        [...element.querySelectorAll('tbody td')].map((one) => one.textContent?.trim());
      const series = [{ name: 'Q1', data: [{ x: 12345, y: 1234.5, z: 1500000 }] }];

      const screen = await render(<PlScatterChart label="Spend" series={series} />);
      const table = screen.getByRole('table', { name: 'Spend' });

      await expect.element(table).toBeInTheDocument();
      expect(cellsOf(table.element())).toEqual(['12345', '1,234.5', '1.5M']);

      // With a `format`, both are written in it, as the card writes the y.
      await screen.rerender(
        <PlScatterChart label="Spend" series={series} format={{ maximumFractionDigits: 0 }} />
      );

      await expect.poll(() => cellsOf(table.element())).toEqual(['12345', '1,235', '1,500,000']);
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

    it('writes a z after the y in brackets, on the card and in the live region', async () => {
      const screen = await render(
        <PlScatterChart
          label="Spend"
          series={[
            {
              name: 'Q1',
              data: [
                { x: 1, y: 1234.5, z: 1500000 },
                { x: 2, y: 2, z: 5, label: 'Two' },
                { x: 3, y: 3 }
              ]
            }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Spend' });
      const status = () => screen.getByRole('status').element().textContent;
      // What the card writes beside its swatch and its series.
      const shown = () =>
        screen.container.querySelector('[data-plass-tooltip] li > span:last-child')?.textContent;

      await expect.element(plot).toBeInTheDocument();

      // Through the chart's number writer, as the y is. A point's own label
      // stands in for its y alone, so the z still follows it; a dot has none.
      for (const [reading, value] of [
        ['1, Q1: 1,234.5 (1.5M)', '1,234.5 (1.5M)'],
        ['2, Q1: Two (5)', 'Two (5)'],
        ['3, Q1: 3', '3']
      ] as const) {
        plot
          .element()
          .dispatchEvent(
            new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true, cancelable: true })
          );

        await expect.poll(status).toBe(reading);
        expect(shown()).toBe(value);
      }
    });
  });
});
