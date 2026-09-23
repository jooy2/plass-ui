/**
 * That `dashed` on a series draws a dashed line.
 *
 * The prop was documented on the Flutter side and listed in its props table,
 * and neither painter read it — a caller marking a forecast got a solid line
 * and nothing to say it was a forecast. It is drawn in both builds now, so this
 * covers `PlLineChart` and `PlAreaChart` over the one renderer they share, and
 * the legend's key for such a line.
 */
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAreaChart, PlLineChart } from 'plass-ui';

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr'];
const DATA = [12, 19, 15, 22];

/** The `stroke-dasharray` of every stroked line on the plot, in draw order. */
function dashes(container: Element): (string | null)[] {
  return [...container.querySelectorAll<SVGPathElement>('path[stroke-width]')]
    .filter((path) => path.getAttribute('fill') === 'none')
    .map((path) => path.getAttribute('stroke-dasharray'));
}

describe('a dashed series', () => {
  it('leaves a series that did not ask solid', async () => {
    const screen = await render(
      <PlLineChart label="Sessions" categories={MONTHS} series={[{ name: 'Web', data: DATA }]} />
    );

    await expect.element(screen.getByRole('img', { name: 'Sessions' })).toBeInTheDocument();
    await expect.poll(() => dashes(screen.container)).toEqual([null]);
  });

  it('dashes the line of the one that did', async () => {
    const screen = await render(
      <PlLineChart
        label="Sessions"
        categories={MONTHS}
        series={[{ name: 'Forecast', data: DATA, dashed: true }]}
      />
    );

    await expect.element(screen.getByRole('img', { name: 'Sessions' })).toBeInTheDocument();
    await expect.poll(() => dashes(screen.container)).toEqual(['6 4']);
  });

  it('dashes only that one where a chart has several', async () => {
    const screen = await render(
      <PlLineChart
        label="Sessions"
        categories={MONTHS}
        series={[
          { name: 'Actual', data: DATA },
          { name: 'Forecast', data: DATA, dashed: true }
        ]}
      />
    );

    await expect.element(screen.getByRole('img', { name: 'Sessions' })).toBeInTheDocument();
    await expect.poll(() => dashes(screen.container)).toEqual([null, '6 4']);
  });

  it('dashes the line an area chart draws over its wash', async () => {
    const screen = await render(
      <PlAreaChart
        label="Sessions"
        categories={MONTHS}
        series={[{ name: 'Forecast', data: DATA, dashed: true }]}
      />
    );

    await expect.element(screen.getByRole('img', { name: 'Sessions' })).toBeInTheDocument();
    await expect.poll(() => dashes(screen.container)).toEqual(['6 4']);
  });
});

describe("a dashed series' legend entry", () => {
  /** The dash pattern the legend entry named `name` draws, or `null` for a square. */
  function keyOf(container: Element, name: string): string | null {
    const entry = [...container.querySelectorAll('button[aria-pressed]')].find(
      (button) => button.textContent === name
    );

    return entry?.querySelector('line')?.getAttribute('stroke-dasharray') ?? null;
  }

  it('is a dashed rule where the plot draws a dashed line, and a square beside it', async () => {
    const screen = await render(
      <PlLineChart
        label="Sessions"
        categories={MONTHS}
        series={[
          { name: 'Actual', data: DATA },
          { name: 'Forecast', data: DATA, dashed: true }
        ]}
      />
    );

    await expect.element(screen.getByRole('button', { name: 'Forecast' })).toBeInTheDocument();
    expect(keyOf(screen.container, 'Forecast')).toBe('6 4');
    expect(keyOf(screen.container, 'Actual')).toBeNull();
  });

  it('is a dashed rule on an area chart that is not stacked', async () => {
    const screen = await render(
      <PlAreaChart
        label="Sessions"
        categories={MONTHS}
        series={[
          { name: 'Actual', data: DATA },
          { name: 'Forecast', data: DATA, dashed: true }
        ]}
      />
    );

    await expect.element(screen.getByRole('button', { name: 'Forecast' })).toBeInTheDocument();
    expect(keyOf(screen.container, 'Forecast')).toBe('6 4');
  });

  it('stays a square where the plot draws no line to dash', async () => {
    const screen = await render(
      <PlAreaChart
        label="Sessions"
        categories={MONTHS}
        stacked
        series={[
          { name: 'Actual', data: DATA },
          { name: 'Forecast', data: DATA, dashed: true }
        ]}
      />
    );

    await expect.element(screen.getByRole('button', { name: 'Forecast' })).toBeInTheDocument();
    expect(keyOf(screen.container, 'Forecast')).toBeNull();
  });
});
