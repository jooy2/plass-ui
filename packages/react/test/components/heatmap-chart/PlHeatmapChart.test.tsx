import { commands } from 'vitest/browser';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { PlHeatmapChart } from 'plass-ui';
import type { PlassChartSeries } from 'plass-ui';
import { render } from 'vitest-browser-react';

const HOURS = ['09', '12', '15', '18'];

const WEEK = [
  { name: 'Mon', data: [2, 9, 6, 1] },
  { name: 'Tue', data: [3, 11, 8, 2] },
  { name: 'Wed', data: [1, 7, 12, 4] }
];

/** Every cell drawn. */
function cells(plot: Element): SVGRectElement[] {
  return [...plot.querySelectorAll<SVGRectElement>('svg rect')];
}

describe('PlHeatmapChart', () => {
  describe('rendering', () => {
    it('draws a cell per row and column', async () => {
      const screen = await render(
        <PlHeatmapChart label="Traffic" series={WEEK} categories={HOURS} />
      );

      const plot = screen.getByRole('img', { name: 'Traffic' });

      await expect.element(plot).toBeInTheDocument();
      expect(cells(plot.element()).length).toBe(12);
    });

    it('leaves a gap as surface rather than as the bottom of the scale', async () => {
      const screen = await render(
        <PlHeatmapChart
          label="Traffic"
          series={[{ name: 'Mon', data: [2, null, 6, 1] }]}
          categories={HOURS}
        />
      );

      const plot = screen.getByRole('img', { name: 'Traffic' });

      await expect.element(plot).toBeInTheDocument();
      expect(cells(plot.element()).length).toBe(3);
    });

    it('says there is nothing to draw when every cell is a gap', async () => {
      const screen = await render(
        <PlHeatmapChart label="Traffic" series={[{ name: 'Mon', data: [null, null] }]} />
      );

      await expect.element(screen.getByText('Nothing here')).toBeInTheDocument();
    });

    it('is described by what its empty state says', async () => {
      // The words are drawn inside the picture, where nothing is read, so the
      // description is the one way to them.
      const screen = await render(
        <PlHeatmapChart
          label="Traffic"
          series={[{ name: 'Mon', data: [null, null] }]}
          empty={<em>Nothing yet</em>}
        />
      );

      await expect
        .element(screen.getByRole('img', { name: 'Traffic' }))
        .toHaveAccessibleDescription('Nothing yet');
    });

    it('writes both axes down the side and along the bottom', async () => {
      const screen = await render(
        <PlHeatmapChart label="Traffic" series={WEEK} categories={HOURS} />
      );

      const plot = screen.getByRole('img', { name: 'Traffic' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((one) => one.textContent);

      expect(texts).toContain('Mon');
      expect(texts).toContain('Wed');
      expect(texts).toContain('09');
    });

    it('thins the column names by one stride, taken from the widest of them', async () => {
      // Twelve columns in a narrow box, and one name far wider than a column.
      const names = [
        'All night long',
        ...['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11']
      ];

      const screen = await render(
        <div style={{ width: 400 }}>
          <PlHeatmapChart
            label="Traffic"
            series={[{ name: 'Mon', data: names.map((_, at) => at + 1) }]}
            categories={names}
          />
        </div>
      );

      const plot = screen.getByRole('img', { name: 'Traffic' });

      await expect.element(plot).toBeInTheDocument();

      const drawn = () =>
        [...plot.element().querySelectorAll('text')]
          .map((one) => names.indexOf(one.textContent ?? ''))
          .filter((at) => at !== -1);

      await expect.poll(() => drawn().length).toBeGreaterThan(1);

      // Worked out per name, a two-digit name has a stride of one, so the names
      // beside the long one were written over it.
      expect(drawn()[0]).toBe(0);
      expect(drawn()).not.toContain(1);
      expect(drawn().every((at, place) => at === place * drawn()[1])).toBe(true);
    });

    it('packs the box as a treemap when asked, and drops the axes with it', async () => {
      const screen = await render(
        <PlHeatmapChart label="Traffic" shape="treemap" series={WEEK} categories={HOURS} />
      );

      const plot = screen.getByRole('img', { name: 'Traffic' });

      await expect.element(plot).toBeInTheDocument();
      expect(cells(plot.element()).length).toBe(12);

      // A treemap names its tiles on their own faces, so there is no column of
      // row names beside the drawing.
      const texts = [...plot.element().querySelectorAll('text')].map((one) => one.textContent);

      expect(texts).not.toContain('Mon');
    });

    it('reads a treemap out a tile at a time, under its own group', async () => {
      const screen = await render(
        <PlHeatmapChart
          label="Spend"
          shape="treemap"
          series={[
            {
              name: 'Compute',
              data: [
                { x: 'Servers', y: 1200 },
                { x: 'Functions', y: 300 }
              ]
            },
            { name: 'Tooling', data: [{ x: 'CI', y: 400 }] }
          ]}
        />
      );

      const table = screen.getByRole('table', { name: 'Spend' });

      await expect.element(table).toBeInTheDocument();

      const rows = [...table.element().querySelectorAll('tr')].map((row) =>
        [...row.children].map((cell) => cell.textContent)
      );

      expect(rows).toEqual([
        ['Compute'],
        ['Servers', '1,200'],
        ['Functions', '300'],
        ['Tooling'],
        ['CI', '400']
      ]);
      await expect.element(screen.getByRole('rowheader', { name: 'CI' })).toBeInTheDocument();
    });
  });

  describe('the scale', () => {
    /** The ramp step a cell landed on, read off its fill. */
    const step = (rect: SVGRectElement) =>
      /--plass-chart-(seq|div)-(\d)/.exec(rect.getAttribute('fill') ?? '')?.[2];

    it('runs one ladder over the whole grid rather than one per row', async () => {
      const screen = await render(
        <PlHeatmapChart
          label="Traffic"
          series={[
            { name: 'Low', data: [1, 2] },
            { name: 'High', data: [99, 100] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Traffic' });

      await expect.element(plot).toBeInTheDocument();

      const drawn = cells(plot.element()).map(step);

      // Per-row ladders would put both rows at both ends. One ladder puts the
      // low row at the bottom of the scale and the high row at the top.
      expect(drawn[0]).toBe('1');
      expect(drawn[3]).toBe('5');
    });

    it('colours from the middle out on a diverging scale', async () => {
      const screen = await render(
        <PlHeatmapChart
          label="Change"
          scale="diverging"
          series={[{ name: 'Δ', data: [-10, 0, 10] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Change' });

      await expect.element(plot).toBeInTheDocument();

      const drawn = cells(plot.element()).map(step);

      expect(drawn).toEqual(['1', '3', '5']);
      expect(cells(plot.element())[0].getAttribute('fill')).toContain('div');
    });

    it('takes its own min and max over the data', async () => {
      const screen = await render(
        <PlHeatmapChart label="Traffic" min={0} max={1000} series={[{ name: 'Mon', data: [5] }]} />
      );

      const plot = screen.getByRole('img', { name: 'Traffic' });

      await expect.element(plot).toBeInTheDocument();
      // Against a range that big, five is the palest step and not the deepest.
      expect(step(cells(plot.element())[0])).toBe('1');
    });
  });

  describe('the legend', () => {
    // A cell under the resting pointer opens the tooltip, and the tooltip's own
    // text is spans outside the table — which is exactly what `ladder` collects.
    // The pointer outlives the file that last moved it, so park it first.
    beforeEach(async () => {
      await commands.parkPointer();
    });

    /**
     * What the scale legend says, and only it. The same numbers are in the
     * hidden table under the chart, which is what makes a plain text query
     * ambiguous here rather than wrong.
     */
    const ladder = (container: Element) =>
      [...container.querySelectorAll('span')]
        .filter(
          (one) =>
            one.closest('table') === null &&
            one.children.length === 0 &&
            // The summary a screen reader is handed is a clipped span of rows
            // and their spans, and it sits beside the legend rather than in the
            // table. It is read, not drawn, so it is not part of the ladder.
            !one.classList.contains('absolute')
        )
        .map((one) => one.textContent)
        .filter(Boolean);

    it('names the two ends of the scale', async () => {
      const screen = await render(
        <PlHeatmapChart label="Traffic" series={[{ name: 'Mon', data: [4, 40] }]} />
      );

      await expect.element(screen.getByRole('img', { name: 'Traffic' })).toBeInTheDocument();
      await expect.poll(() => ladder(screen.container)).toEqual(['4', '40']);
    });

    it('names the middle too when the scale diverges', async () => {
      const screen = await render(
        <PlHeatmapChart
          label="Change"
          scale="diverging"
          midpoint={50}
          series={[{ name: 'Δ', data: [20, 80] }]}
        />
      );

      await expect.element(screen.getByRole('img', { name: 'Change' })).toBeInTheDocument();

      // Both arms reach as far as the further one, so the ends are symmetric
      // about the middle rather than being the data's own two values.
      await expect.poll(() => ladder(screen.container)).toEqual(['20', '80', '50']);
    });
  });

  describe('the table', () => {
    it('writes the grid out with both sets of names', async () => {
      const screen = await render(
        <PlHeatmapChart label="Traffic" series={WEEK} categories={HOURS} />
      );

      await expect.element(screen.getByRole('table', { name: 'Traffic' })).toBeInTheDocument();
      await expect.element(screen.getByRole('rowheader', { name: 'Tue' })).toBeInTheDocument();
      await expect.element(screen.getByRole('columnheader', { name: '12' })).toBeInTheDocument();
    });

    it('leaves a gap as an empty cell rather than a zero', async () => {
      const screen = await render(
        <PlHeatmapChart
          label="Traffic"
          series={[{ name: 'Mon', data: [null, 6] }]}
          categories={['09', '12']}
        />
      );

      const table = screen.getByRole('table', { name: 'Traffic' });

      await expect.element(table).toBeInTheDocument();

      const row = [...table.element().querySelectorAll('tbody td')].map((one) =>
        one.textContent?.trim()
      );

      expect(row).toEqual(['', '6']);
    });
  });

  describe('valueLabels', () => {
    it('writes nothing on a grid by default', async () => {
      const screen = await render(
        <PlHeatmapChart label="Traffic" series={[{ name: 'Mon', data: [42] }]} />
      );

      const plot = screen.getByRole('img', { name: 'Traffic' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((one) => one.textContent);

      expect(texts).not.toContain('42');
    });

    it('writes the value on every cell with all', async () => {
      const screen = await render(
        <PlHeatmapChart
          label="Traffic"
          valueLabels="all"
          height={200}
          series={[{ name: 'Mon', data: [42] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Traffic' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((one) => one.textContent);

      expect(texts).toContain('42');
    });
  });

  describe('the keyboard', () => {
    it('walks the cells and says which one it is on', async () => {
      const screen = await render(
        <PlHeatmapChart label="Traffic" series={WEEK} categories={HOURS} />
      );

      const plot = screen.getByRole('img', { name: 'Traffic' });

      await expect.element(plot).toBeInTheDocument();

      const status = screen.container.querySelector('[role="status"]') as HTMLElement;

      arrow(plot.element(), 'ArrowRight');
      await expect.poll(() => status.textContent).toContain('Mon');

      arrow(plot.element(), 'Escape');
      await expect.poll(() => status.textContent).toBe('');
    });

    it('keeps an Escape that clears a reading from what it sits in, and lets it through otherwise', async () => {
      // Both ways a sheet hears the key: a handler on an element around the
      // chart, and a listener on the document, which is where Base UI's
      // dismissal listens.
      const around = vi.fn();
      const onDocument = vi.fn();
      const listener = (event: KeyboardEvent) => {
        if (event.key === 'Escape') {
          onDocument();
        }
      };

      document.addEventListener('keydown', listener);

      try {
        const screen = await render(
          <div
            onKeyDown={(event) => {
              if (event.key === 'Escape') {
                around();
              }
            }}
          >
            <PlHeatmapChart label="Traffic" series={WEEK} categories={HOURS} />
          </div>
        );

        const plot = screen.getByRole('img', { name: 'Traffic' });

        await expect.element(plot).toBeInTheDocument();

        const status = screen.container.querySelector('[role="status"]') as HTMLElement;

        arrow(plot.element(), 'ArrowRight');
        await expect.poll(() => status.textContent).toContain('Mon');

        arrow(plot.element(), 'Escape');

        await expect.poll(() => status.textContent).toBe('');
        expect(around).not.toHaveBeenCalled();
        expect(onDocument).not.toHaveBeenCalled();

        const escape = new KeyboardEvent('keydown', {
          key: 'Escape',
          bubbles: true,
          cancelable: true
        });

        plot.element().dispatchEvent(escape);

        expect(escape.defaultPrevented).toBe(false);
        expect(around).toHaveBeenCalledTimes(1);
        expect(onDocument).toHaveBeenCalledTimes(1);
      } finally {
        document.removeEventListener('keydown', listener);
      }
    });

    describe('up and down in a grid', () => {
      // A cell under the resting pointer takes the readout from the keyboard.
      beforeEach(async () => {
        await commands.parkPointer();
      });

      it('moves to the same column in the row below or above', async () => {
        const screen = await render(
          <PlHeatmapChart label="Traffic" series={WEEK} categories={HOURS} />
        );

        const plot = screen.getByRole('img', { name: 'Traffic' });

        await expect.element(plot).toBeInTheDocument();

        const status = screen.container.querySelector('[role="status"]') as HTMLElement;

        // One key at a time: the handler reads the cell the last render left.
        arrow(plot.element(), 'ArrowRight');
        await expect.poll(() => status.textContent).toContain('Mon · 09');
        arrow(plot.element(), 'ArrowRight');
        await expect.poll(() => status.textContent).toContain('Mon · 12');

        arrow(plot.element(), 'ArrowDown');
        await expect.poll(() => status.textContent).toContain('Tue · 12');
        arrow(plot.element(), 'ArrowDown');
        await expect.poll(() => status.textContent).toContain('Wed · 12');

        arrow(plot.element(), 'ArrowUp');
        await expect.poll(() => status.textContent).toContain('Tue · 12');
      });

      it('steps over a gap in that column to the next row with a cell in it', async () => {
        const screen = await render(
          <PlHeatmapChart
            label="Traffic"
            series={[WEEK[0], { name: 'Tue', data: [3, null, 8, 2] }, WEEK[2]]}
            categories={HOURS}
          />
        );

        const plot = screen.getByRole('img', { name: 'Traffic' });

        await expect.element(plot).toBeInTheDocument();

        const status = screen.container.querySelector('[role="status"]') as HTMLElement;

        arrow(plot.element(), 'ArrowRight');
        await expect.poll(() => status.textContent).toContain('Mon · 09');
        arrow(plot.element(), 'ArrowRight');
        await expect.poll(() => status.textContent).toContain('Mon · 12');

        arrow(plot.element(), 'ArrowDown');
        await expect.poll(() => status.textContent).toContain('Wed · 12');
      });
    });

    describe('rendered again', () => {
      // A cell under the resting pointer takes the readout from the keyboard.
      beforeEach(async () => {
        await commands.parkPointer();
      });

      const SQUARE: PlassChartSeries[] = [
        { name: 'Mon', data: [2, 9] },
        { name: 'Tue', data: [3, 11] }
      ];

      /**
       * Renders a chart over `SQUARE` in `shape` and reads its 'Tue · 12' cell
       * by key: the last cell of the grid, and the largest, so the first, tile
       * of the treemap.
       */
      async function reading(shape: 'grid' | 'treemap') {
        const chart = (series: PlassChartSeries[]) => (
          <PlHeatmapChart label="Traffic" series={series} categories={HOURS} shape={shape} />
        );
        const screen = await render(chart(SQUARE));
        const plot = screen.getByRole('img', { name: 'Traffic' });

        await expect.element(plot).toBeInTheDocument();
        await expect.poll(() => cells(plot.element()).length).toBe(4);

        const status = screen.container.querySelector('[role="status"]') as HTMLElement;

        // One key at a time: the handler reads the cell the last render left.
        for (const heading of shape === 'grid'
          ? ['Mon · 09', 'Mon · 12', 'Tue · 09', 'Tue · 12']
          : ['Tue · 12']) {
          arrow(plot.element(), 'ArrowRight');
          await expect.poll(() => status.textContent).toContain(heading);
        }

        expect(opacities(plot.element())).toContain('1');

        return { screen, plot: plot.element(), status, chart };
      }

      /** `SQUARE` with its 'Tue · 12' cell turned to `gone`. */
      function without(gone: number | null): PlassChartSeries[] {
        return [SQUARE[0], { name: 'Tue', data: [3, gone] }];
      }

      /** The opacity every cell is drawn at. */
      function opacities(plot: Element): (string | null)[] {
        return cells(plot).map((cell) => cell.getAttribute('opacity'));
      }

      // A gap on either shape, and a value with no area to be a tile.
      it.each([
        ['grid', null],
        ['treemap', null],
        ['treemap', 0]
      ] as const)(
        'lets go of a %s cell that turns %s and is no longer drawn, and for good',
        async (shape, gone) => {
          const { screen, plot, status, chart } = await reading(shape);

          await screen.rerender(chart(without(gone)));

          expect(cells(plot).length).toBe(3);
          expect(status.textContent).toBe('');
          expect(screen.container.querySelector('[data-plass-tooltip]')).toBeNull();
          expect(opacities(plot)).not.toContain('1');

          // The data bringing the cell back does not bring the reading back
          // with it.
          await screen.rerender(chart(SQUARE));

          expect(cells(plot).length).toBe(4);
          expect(status.textContent).toBe('');
          expect(screen.container.querySelector('[data-plass-tooltip]')).toBeNull();
          expect(opacities(plot)).not.toContain('1');
        }
      );

      it.each(['grid', 'treemap'] as const)(
        'lets Escape through once the cell it was reading on a %s is gone',
        async (shape) => {
          const { screen, plot, chart } = await reading(shape);

          await screen.rerender(chart(without(null)));

          // Nothing is being read, so the key goes on to what the chart sits in
          // rather than clearing a reading nobody can see.
          const escape = new KeyboardEvent('keydown', {
            key: 'Escape',
            bubbles: true,
            cancelable: true
          });

          plot.dispatchEvent(escape);

          expect(escape.defaultPrevented).toBe(false);
        }
      );

      it.each(['grid', 'treemap'] as const)(
        'keeps reading a cell that is still there on a %s',
        async (shape) => {
          const { screen, plot, status, chart } = await reading(shape);

          // Another cell goes, and every one left moves on the treemap.
          await screen.rerender(chart([{ name: 'Mon', data: [null, 9] }, SQUARE[1]]));

          expect(cells(plot).length).toBe(3);
          expect(status.textContent).toContain('Tue · 12');
          expect(screen.container.querySelector('[data-plass-tooltip]')).not.toBeNull();
          expect(opacities(plot).filter((opacity) => opacity === '1').length).toBe(1);
        }
      );
    });
  });
});

/**
 * The plot is a `role="img"` rather than a control, and nothing in the test run
 * loads the CSS that gives it a size — so Playwright has no box to click and
 * focus before pressing a key. The component listens for `keydown`.
 */
function arrow(element: Element, key: string): void {
  element.dispatchEvent(new KeyboardEvent('keydown', { key, bubbles: true, cancelable: true }));
}
