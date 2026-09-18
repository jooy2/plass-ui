/**
 * What a screen reader is handed in place of the drawing.
 *
 * A chart is a `role="img"` tab stop with an `aria-describedby`, and that
 * attribute is flattened into one string by the reader — so pointing it at the
 * data table meant every value on every focus, ahead of anything else, and the
 * same table is a sibling in the reading order, so it was heard twice.
 *
 * The description is a summary now. The table has not moved: these assert both
 * halves, because a summary that replaced the table would have taken the values
 * away rather than got out of their way.
 */
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlHeatmapChart, PlLineChart, PlPieChart } from 'plass-ui';

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr'];

/** The element a chart's `aria-describedby` points at, and its text. */
async function description(chart: HTMLElement): Promise<string> {
  const id = chart.getAttribute('aria-describedby');

  expect(id).not.toBeNull();

  const element = document.getElementById(id as string);

  expect(element).not.toBeNull();

  return (element as HTMLElement).textContent?.trim() ?? '';
}

describe('a chart description', () => {
  it('is a summary of the series rather than the table', async () => {
    const screen = await render(
      <PlLineChart
        label="Sessions by month"
        categories={MONTHS}
        series={[
          { name: 'Web', data: [10, 20, 30, 40] },
          { name: 'App', data: [5, 6, 7, 8] }
        ]}
      />
    );
    const chart = screen.getByRole('img', { name: 'Sessions by month' }).element() as HTMLElement;

    await expect.element(screen.getByRole('table')).toBeInTheDocument();

    const said = await description(chart);

    expect(said).toBe('Web 40, App 8');
    // The table is still there and still a sibling, so every value is one step
    // away — it is simply no longer also the description.
    expect(chart.getAttribute('aria-describedby')).not.toBe(screen.getByRole('table').element().id);
    expect(screen.getByRole('table').element().textContent).toContain('20');
  });

  it('leaves a series the reader switched off out of it', async () => {
    const screen = await render(
      <PlLineChart
        label="Sessions by month"
        categories={MONTHS}
        series={[
          { name: 'Web', data: [10, 20, 30, 40] },
          { name: 'App', data: [5, 6, 7, 8], hidden: true }
        ]}
      />
    );
    const chart = screen.getByRole('img', { name: 'Sessions by month' }).element() as HTMLElement;

    await expect.element(screen.getByRole('table')).toBeInTheDocument();
    expect(await description(chart)).toBe('Web 40');
  });

  it('names a series whose values are all gaps without a number', async () => {
    const screen = await render(
      <PlLineChart
        label="Sessions by month"
        categories={MONTHS}
        series={[
          { name: 'Web', data: [10, 20, 30, 40] },
          { name: 'App', data: [null, null, null, null] }
        ]}
      />
    );
    const chart = screen.getByRole('img', { name: 'Sessions by month' }).element() as HTMLElement;

    await expect.element(screen.getByRole('table')).toBeInTheDocument();
    expect(await description(chart)).toBe('Web 40, App');
  });

  it('is every slice and its share on a pie', async () => {
    const screen = await render(
      <PlPieChart label="Traffic" categories={['Web', 'App']} data={[75, 25]} />
    );
    const chart = screen.getByRole('img', { name: 'Traffic' }).element() as HTMLElement;

    await expect.element(screen.getByRole('table')).toBeInTheDocument();
    expect(await description(chart)).toBe('Web 75 · 75%, App 25 · 25%');
  });

  it('is each row and the span its cells cover on a heatmap', async () => {
    const screen = await render(
      <PlHeatmapChart
        label="Visits"
        categories={['Mon', 'Tue', 'Wed']}
        series={[
          { name: 'Morning', data: [1, 5, 3] },
          { name: 'Evening', data: [8, 8, 8] }
        ]}
      />
    );
    const chart = screen.getByRole('img', { name: 'Visits' }).element() as HTMLElement;

    await expect.element(screen.getByRole('table')).toBeInTheDocument();
    // A row whose cells are all one number says it once rather than twice.
    expect(await description(chart)).toBe('Morning 1–5, Evening 8');
  });
});
