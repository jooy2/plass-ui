/**
 * What a chart's picture is called, what the table under it is called, and
 * what describes the picture.
 *
 * A caller's `aria-label`, `aria-labelledby` and `aria-describedby` were
 * handed on to the box with the rest of the props, and the box is a `<div>`
 * with no role, so they named and described nothing: the picture went on being
 * called by `label`, by the default word, or by nothing at all. They now reach
 * the picture, a reference first, then the words, then `label`, and the box
 * carries none of them. The table is named by the same three in the same
 * order, and was captioned by `label` alone.
 *
 * Every chart is asked, because each one draws its own picture and its own
 * table.
 */
import * as React from 'react';
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlAreaChart,
  PlBarChart,
  PlGaugeChart,
  PlHeatmapChart,
  PlLineChart,
  PlPieChart,
  PlScatterChart,
  PlSparkline,
  PlTimelineChart
} from 'plass-ui';

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr'];
const SALES = [{ name: 'Europe', data: [42, 45, 51, 49] }];
const at = (day: number) => new Date(2026, 0, day);

/**
 * The three ways a caller names a chart, the way they describe it, and the
 * class its box is found by.
 */
interface Naming {
  label?: string;
  'aria-label'?: string;
  'aria-labelledby'?: string;
  'aria-describedby'?: string;
  className: string;
}

interface Case {
  name: string;
  chart: (naming: Naming) => React.ReactElement;
  /**
   * What the picture is called when `words` name it, by `label` or an
   * `aria-label`, or when an `aria-labelledby` points at an element holding
   * them. A dial reads its value after the name.
   */
  called: (words: string, referenced: boolean) => string;
  /** What it is called with none of the three, or `null` when it is then no picture. */
  unnamed: string | null;
  /** Whether it draws a table under the picture. A dial and a strip do not. */
  tabled: boolean;
  /** Whether the picture is described by words of its own as well. */
  described: boolean;
}

const plain = (words: string) => words;

const cases: Case[] = [
  {
    name: 'PlLineChart',
    chart: (naming) => <PlLineChart {...naming} categories={MONTHS} series={SALES} />,
    called: plain,
    unnamed: 'Chart',
    tabled: true,
    described: true
  },
  {
    name: 'PlAreaChart',
    chart: (naming) => <PlAreaChart {...naming} categories={MONTHS} series={SALES} />,
    called: plain,
    unnamed: 'Chart',
    tabled: true,
    described: true
  },
  {
    name: 'PlBarChart',
    chart: (naming) => <PlBarChart {...naming} categories={MONTHS} series={SALES} />,
    called: plain,
    unnamed: 'Chart',
    tabled: true,
    described: true
  },
  {
    name: 'PlScatterChart',
    chart: (naming) => (
      <PlScatterChart
        {...naming}
        series={[
          {
            name: 'Q1',
            data: [
              { x: 10, y: 22 },
              { x: 20, y: 31 }
            ]
          }
        ]}
      />
    ),
    called: plain,
    unnamed: 'Chart',
    tabled: true,
    described: true
  },
  {
    name: 'PlTimelineChart',
    chart: (naming) => (
      <PlTimelineChart
        {...naming}
        series={[{ name: 'Design', data: [{ start: at(1), end: at(9) }] }]}
      />
    ),
    called: plain,
    unnamed: 'Chart',
    tabled: true,
    described: true
  },
  {
    name: 'PlPieChart',
    chart: (naming) => <PlPieChart {...naming} categories={MONTHS} data={[40, 25, 20, 15]} />,
    called: plain,
    unnamed: 'Chart',
    tabled: true,
    described: true
  },
  {
    name: 'PlHeatmapChart',
    chart: (naming) => (
      <PlHeatmapChart
        {...naming}
        categories={MONTHS}
        series={[
          { name: 'Mon', data: [2, 9, 6, 1] },
          { name: 'Tue', data: [3, 11, 8, 2] }
        ]}
      />
    ),
    called: plain,
    unnamed: 'Chart',
    tabled: true,
    described: true
  },
  {
    name: 'PlHeatmapChart as a treemap',
    chart: (naming) => (
      <PlHeatmapChart
        {...naming}
        shape="treemap"
        categories={MONTHS}
        series={[
          { name: 'Mon', data: [2, 9, 6, 1] },
          { name: 'Tue', data: [3, 11, 8, 2] }
        ]}
      />
    ),
    called: plain,
    unnamed: 'Chart',
    tabled: true,
    described: true
  },
  {
    name: 'PlGaugeChart',
    chart: (naming) => <PlGaugeChart {...naming} value={68} caption="of the quota" />,
    called: (words, referenced) => (referenced ? `${words} 68 / 100` : `${words}: 68 / 100`),
    unnamed: null,
    tabled: false,
    described: true
  },
  {
    name: 'PlSparkline',
    chart: (naming) => <PlSparkline {...naming} data={[12, 19, 15, 22]} width={200} />,
    called: plain,
    unnamed: null,
    tabled: false,
    described: false
  }
];

/** The box around the chart, which the other props land on. */
function box(): Element {
  const element = document.querySelector('.chart-under-test');

  expect(element).not.toBeNull();

  return element as Element;
}

describe('a chart name', () => {
  for (const { name, chart, called, unnamed, described } of cases) {
    describe(name, () => {
      it("is an `aria-label` in `label`'s place", async () => {
        const screen = await render(
          chart({
            label: 'Sales',
            'aria-label': 'Sales this quarter',
            className: 'chart-under-test'
          })
        );

        await expect
          .element(
            screen.getByRole('img', { name: called('Sales this quarter', false), exact: true })
          )
          .toBeInTheDocument();
      });

      it('is an `aria-label` given alone', async () => {
        const screen = await render(
          chart({ 'aria-label': 'Sales this quarter', className: 'chart-under-test' })
        );

        await expect
          .element(
            screen.getByRole('img', { name: called('Sales this quarter', false), exact: true })
          )
          .toBeInTheDocument();
      });

      it("points the picture at the caller's element with an `aria-labelledby`, over `label` and an `aria-label`", async () => {
        const screen = await render(
          <>
            <span id="chart-heading">Quarterly sales</span>
            {chart({
              label: 'Sales',
              'aria-label': 'Sales this quarter',
              'aria-labelledby': 'chart-heading',
              className: 'chart-under-test'
            })}
          </>
        );

        const picture = screen.getByRole('img', {
          name: called('Quarterly sales', true),
          exact: true
        });

        await expect.element(picture).toBeInTheDocument();
        expect(picture.element().getAttribute('aria-labelledby')).toMatch(/^chart-heading( |$)/);
      });

      it('is an `aria-labelledby` given alone', async () => {
        const screen = await render(
          <>
            <span id="chart-heading">Quarterly sales</span>
            {chart({ 'aria-labelledby': 'chart-heading', className: 'chart-under-test' })}
          </>
        );

        await expect
          .element(screen.getByRole('img', { name: called('Quarterly sales', true), exact: true }))
          .toBeInTheDocument();
      });

      it('is still `label` with neither', async () => {
        const screen = await render(chart({ label: 'Sales', className: 'chart-under-test' }));

        await expect
          .element(screen.getByRole('img', { name: called('Sales', false), exact: true }))
          .toBeInTheDocument();
      });

      it('is what it was with none of the three', async () => {
        const screen = await render(chart({ className: 'chart-under-test' }));

        if (unnamed !== null) {
          await expect
            .element(screen.getByRole('img', { name: unnamed, exact: true }))
            .toBeInTheDocument();
        } else {
          // Drawn first, so the absence is not just a picture still to come.
          await expect.poll(() => box().querySelector('svg')).not.toBeNull();
          expect(screen.getByRole('img').query()).toBeNull();
        }
      });

      it('leaves both off the box around the picture', async () => {
        const screen = await render(
          <>
            <span id="chart-heading">Quarterly sales</span>
            {chart({
              'aria-label': 'Sales this quarter',
              'aria-labelledby': 'chart-heading',
              className: 'chart-under-test'
            })}
          </>
        );

        await expect.element(screen.getByRole('img')).toBeInTheDocument();
        expect(box().hasAttribute('aria-label')).toBe(false);
        expect(box().hasAttribute('aria-labelledby')).toBe(false);
        expect(screen.getByRole('img').element()).not.toBe(box());
      });

      it("is described by the caller's `aria-describedby` ahead of its own words, and the box is not", async () => {
        const screen = await render(
          <>
            <span id="chart-note">Figures are provisional</span>
            {chart({
              label: 'Sales',
              'aria-describedby': 'chart-note',
              className: 'chart-under-test'
            })}
          </>
        );

        const picture = screen.getByRole('img', { name: called('Sales', false), exact: true });

        await expect
          .element(picture)
          .toHaveAccessibleDescription(
            described ? /^Figures are provisional \S/ : 'Figures are provisional'
          );
        expect(picture.element().getAttribute('aria-describedby')).toMatch(/^chart-note( |$)/);
        expect(box().hasAttribute('aria-describedby')).toBe(false);
      });
    });
  }
});

describe('the name of the table under a chart', () => {
  for (const { name, chart } of cases.filter((one) => one.tabled)) {
    describe(name, () => {
      it("points the table at the caller's element with an `aria-labelledby`, over `label` and an `aria-label`, and leaves it no caption", async () => {
        const screen = await render(
          <>
            <span id="chart-heading">Quarterly sales</span>
            {chart({
              label: 'Sales',
              'aria-label': 'Sales this quarter',
              'aria-labelledby': 'chart-heading',
              className: 'chart-under-test'
            })}
          </>
        );

        const table = screen.getByRole('table', { name: 'Quarterly sales', exact: true });

        await expect.element(table).toBeInTheDocument();
        expect(table.element().getAttribute('aria-labelledby')).toBe('chart-heading');
        expect(table.element().querySelector('caption')).toBeNull();
      });

      it("is captioned by an `aria-label` in `label`'s place", async () => {
        const screen = await render(
          chart({
            label: 'Sales',
            'aria-label': 'Sales this quarter',
            className: 'chart-under-test'
          })
        );

        const table = screen.getByRole('table', { name: 'Sales this quarter', exact: true });

        await expect.element(table).toBeInTheDocument();
        expect(table.element().hasAttribute('aria-labelledby')).toBe(false);
      });

      it('is still captioned by `label` with neither', async () => {
        const screen = await render(chart({ label: 'Sales', className: 'chart-under-test' }));

        await expect
          .element(screen.getByRole('table', { name: 'Sales', exact: true }))
          .toBeInTheDocument();
      });

      it('is still unnamed with none of the three', async () => {
        const screen = await render(chart({ className: 'chart-under-test' }));

        const table = screen.getByRole('table');

        await expect.element(table).toBeInTheDocument();
        expect(table.element().querySelector('caption')).toBeNull();
        expect(table.element().hasAttribute('aria-labelledby')).toBe(false);
      });
    });
  }
});
