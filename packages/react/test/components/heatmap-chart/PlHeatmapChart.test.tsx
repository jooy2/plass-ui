import { describe, expect, it } from 'vitest';
import { PlHeatmapChart } from 'plass-ui';
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
    /**
     * What the scale legend says, and only it. The same numbers are in the
     * hidden table under the chart, which is what makes a plain text query
     * ambiguous here rather than wrong.
     */
    const ladder = (container: Element) =>
      [...container.querySelectorAll('span')]
        .filter((one) => one.closest('table') === null && one.children.length === 0)
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
