/**
 * What a chart being read does when it is rendered again with less to read.
 *
 * A line, bar or area chart read by a key or the pointer holds the column it is
 * on, and a scatter, a timeline or a chart in `nearest` mode holds the mark.
 * Rendered again with fewer categories or marks, a column past the end used to
 * be kept, with its crosshair drawn past the plot, and read again once the data
 * grew back; a mark was held by its place in the list of marks, so the reading
 * moved onto whichever mark took that place, and then by its series' place, so
 * a series leaving ahead of it moved the reading onto another series. These let
 * go of a column or a mark that is no longer there, as the Flutter charts do,
 * while one that is still there goes on being read, a mark by the key of its
 * series or its timeline row.
 *
 * A test of the frame the five charts share rather than of one of them, which
 * is why it is here rather than under `test/components/`.
 */
import * as React from 'react';
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAreaChart, PlBarChart, PlLineChart, PlScatterChart, PlTimelineChart } from 'plass-ui';
import { press } from '../support/keys';

const revenue = (count: number) => [
  { name: 'Revenue', data: Array.from({ length: count }, (_, index) => 10 + index) }
];

const months = (count: number) => Array.from({ length: count }, (_, index) => `M${index + 1}`);

const day = (at: number) => new Date(2026, 0, at);

/** Each chart over the frame, rendered with `count` categories or marks. */
const charts: Record<string, (count: number) => React.ReactElement> = {
  'a line': (count) => (
    <PlLineChart label="Chart" series={revenue(count)} categories={months(count)} />
  ),
  'a bar': (count) => (
    <PlBarChart label="Chart" series={revenue(count)} categories={months(count)} />
  ),
  'a horizontal bar': (count) => (
    <PlBarChart
      label="Chart"
      series={revenue(count)}
      categories={months(count)}
      orientation="horizontal"
    />
  ),
  'an area': (count) => (
    <PlAreaChart label="Chart" series={revenue(count)} categories={months(count)} />
  ),
  'a nearest line': (count) => (
    <PlLineChart
      label="Chart"
      series={revenue(count)}
      categories={months(count)}
      tooltip={{ mode: 'nearest' }}
    />
  ),
  'a scatter': (count) => (
    <PlScatterChart
      label="Chart"
      series={[
        {
          name: 'Spend',
          data: Array.from({ length: count }, (_, index) => ({
            x: 10 * (index + 1),
            y: 20 + index
          }))
        }
      ]}
    />
  ),
  'a timeline': (count) => (
    <PlTimelineChart
      label="Chart"
      series={[
        {
          name: 'Design',
          data: Array.from({ length: count }, (_, index) => ({
            start: day(1 + index * 3),
            end: day(3 + index * 3),
            label: `Step ${index + 1}`
          }))
        }
      ]}
    />
  )
};

/** What the live region is saying. */
function said(container: HTMLElement): string {
  return container.querySelector('[role="status"]')?.textContent ?? '';
}

/** Whether a tooltip card or a crosshair is drawn. */
function reading(container: HTMLElement): boolean {
  return (
    container.querySelector('[data-plass-tooltip]') !== null ||
    container.querySelector('svg > line[stroke="var(--plass-chart-baseline)"]') !== null
  );
}

describe.each(Object.entries(charts))('%s chart', (_, chart) => {
  /** Renders the chart with five categories or marks and gives its plot the focus. */
  async function focused() {
    const screen = await render(chart(5));
    const plot = screen.getByRole('img', { name: 'Chart' });

    await expect.element(plot).toBeInTheDocument();
    await expect.poll(() => plot.element().querySelector('svg')).not.toBeNull();
    (plot.element() as HTMLElement).focus();

    return { screen, plot: plot.element() };
  }

  it.each([2, 0])('lets go of the last when it is rendered again with %i', async (fewer) => {
    const { screen, plot } = await focused();

    // The last, which the next render does not have.
    press(plot, 'End');
    await expect.poll(() => said(screen.container)).not.toBe('');
    expect(reading(screen.container)).toBe(true);

    await screen.rerender(chart(fewer));

    expect(said(screen.container)).toBe('');
    expect(reading(screen.container)).toBe(false);

    // Let go rather than held, so the data bringing it back does not bring the
    // reading back with it.
    await screen.rerender(chart(5));

    expect(said(screen.container)).toBe('');
    expect(reading(screen.container)).toBe(false);
  });

  it('keeps reading the first when it is rendered again with fewer', async () => {
    const { screen, plot } = await focused();

    press(plot, 'Home');
    await expect.poll(() => said(screen.container)).not.toBe('');

    const first = said(screen.container);

    await screen.rerender(chart(2));

    expect(said(screen.container)).toBe(first);
    expect(reading(screen.container)).toBe(true);

    // And the walk goes on from it, over what is there now.
    press(plot, 'End');
    await expect.poll(() => said(screen.container)).not.toBe(first);
  });
});

describe('a scatter chart of two series', () => {
  const chart = (first: number) => (
    <PlScatterChart
      label="Chart"
      series={[
        {
          name: 'Spend',
          data: Array.from({ length: first }, (_, index) => ({
            x: 10 * (index + 1),
            y: 20 + index
          }))
        },
        {
          name: 'Return',
          data: Array.from({ length: 5 }, (_, index) => ({ x: 12 * (index + 1), y: 60 + index }))
        }
      ]}
    />
  );

  it('keeps reading a mark whose place among the marks moved', async () => {
    const screen = await render(chart(5));
    const plot = screen.getByRole('img', { name: 'Chart' });

    await expect.poll(() => plot.element().querySelector('svg')).not.toBeNull();
    (plot.element() as HTMLElement).focus();

    // The first mark of the second series, which comes after the five of the
    // first. Each key waits for the one before it to be read, because a step
    // is taken from the mark the chart last rendered.
    press(plot.element(), 'Home');
    await expect.poll(() => said(screen.container)).not.toBe('');

    for (let step = 0; step < 5; step += 1) {
      const before = said(screen.container);

      press(plot.element(), 'ArrowRight');
      await expect.poll(() => said(screen.container)).not.toBe(before);
    }

    const read = said(screen.container);

    expect(read).toContain('Return');

    // Three fewer marks ahead of it, so its place is taken by the fourth mark
    // of its own series.
    await screen.rerender(chart(2));

    expect(said(screen.container)).toBe(read);
  });
});

/* Each chart read by mark, rendered with one series or row per name, and the
   key that steps back through its marks. The data follows the name, so a
   series that moves draws what it drew. A timeline runs on its side, so its
   marks are walked up and down. */
const byName: Record<
  string,
  { back: string; chart: (names: readonly string[]) => React.ReactElement }
> = {
  'a scatter': {
    back: 'ArrowLeft',
    chart: (names) => (
      <PlScatterChart
        label="Chart"
        series={names.map((name) => ({
          name,
          data: [0, 1].map((at) => ({ x: 10 * name.length + at, y: 20 * name.length + at }))
        }))}
      />
    )
  },
  'a nearest line': {
    back: 'ArrowLeft',
    chart: (names) => (
      <PlLineChart
        label="Chart"
        categories={['Jan', 'Feb']}
        tooltip={{ mode: 'nearest' }}
        series={names.map((name) => ({ name, data: [name.length, name.length * 2] }))}
      />
    )
  },
  'a timeline': {
    back: 'ArrowUp',
    chart: (names) => (
      <PlTimelineChart
        label="Chart"
        series={names.map((name) => ({
          name,
          data: [0, 1].map((at) => ({
            start: day(1 + at * 10 + name.length),
            end: day(4 + at * 10 + name.length)
          }))
        }))}
      />
    )
  }
};

describe.each(Object.entries(byName))('%s chart read by mark', (_, { back, chart }) => {
  // Names of different lengths, so every series draws marks of its own.
  const names = ['Web', 'Mobile', 'Desktop', 'Tablets..'];

  /** Renders the chart and reads the last mark of its third series by key. */
  async function readThird() {
    const screen = await render(chart(names));
    const plot = screen.getByRole('img', { name: 'Chart' });

    await expect.poll(() => plot.element().querySelector('svg')).not.toBeNull();
    (plot.element() as HTMLElement).focus();

    // The last mark of the fourth, then two back to the last of the third.
    // Each key waits for the one before it to be read, because a step is taken
    // from the mark the chart last rendered.
    press(plot.element(), 'End');
    await expect.poll(() => said(screen.container)).toContain('Tablets..');

    for (let step = 0; step < 2; step += 1) {
      const before = said(screen.container);

      press(plot.element(), back);
      await expect.poll(() => said(screen.container)).not.toBe(before);
    }

    const read = said(screen.container);

    expect(read).toContain('Desktop');

    return { screen, read };
  }

  it('keeps reading a mark of the third series when the first leaves', async () => {
    const { screen, read } = await readThird();

    await screen.rerender(chart(names.slice(1)));

    expect(said(screen.container)).toBe(read);
    expect(reading(screen.container)).toBe(true);
  });

  it('lets go of the mark when its series leaves', async () => {
    const { screen } = await readThird();

    await screen.rerender(chart(names.filter((name) => name !== 'Desktop')));

    expect(said(screen.container)).toBe('');
    expect(reading(screen.container)).toBe(false);
  });
});
