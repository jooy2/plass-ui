/**
 * What a chart's picture is called.
 *
 * A caller's `aria-label` and `aria-labelledby` were handed on to the box with
 * the rest of the props, and the box is a `<div>` with no role, so they named
 * nothing: the picture went on being called by `label`, by the default word, or
 * by nothing at all. They now name the picture, a reference first, then the
 * words, then `label`, and the box carries neither.
 *
 * Every chart is asked, because each one draws its own picture.
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

/** The three ways a caller names a chart, and the class its box is found by. */
interface Naming {
  label?: string;
  'aria-label'?: string;
  'aria-labelledby'?: string;
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
}

const plain = (words: string) => words;

const cases: Case[] = [
  {
    name: 'PlLineChart',
    chart: (naming) => <PlLineChart {...naming} categories={MONTHS} series={SALES} />,
    called: plain,
    unnamed: 'Chart'
  },
  {
    name: 'PlAreaChart',
    chart: (naming) => <PlAreaChart {...naming} categories={MONTHS} series={SALES} />,
    called: plain,
    unnamed: 'Chart'
  },
  {
    name: 'PlBarChart',
    chart: (naming) => <PlBarChart {...naming} categories={MONTHS} series={SALES} />,
    called: plain,
    unnamed: 'Chart'
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
    unnamed: 'Chart'
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
    unnamed: 'Chart'
  },
  {
    name: 'PlPieChart',
    chart: (naming) => <PlPieChart {...naming} categories={MONTHS} data={[40, 25, 20, 15]} />,
    called: plain,
    unnamed: 'Chart'
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
    unnamed: 'Chart'
  },
  {
    name: 'PlGaugeChart',
    chart: (naming) => <PlGaugeChart {...naming} value={68} />,
    called: (words, referenced) => (referenced ? `${words} 68 / 100` : `${words}: 68 / 100`),
    unnamed: null
  },
  {
    name: 'PlSparkline',
    chart: (naming) => <PlSparkline {...naming} data={[12, 19, 15, 22]} width={200} />,
    called: plain,
    unnamed: null
  }
];

/** The box around the chart, which the other props land on. */
function box(): Element {
  const element = document.querySelector('.chart-under-test');

  expect(element).not.toBeNull();

  return element as Element;
}

describe('a chart name', () => {
  for (const { name, chart, called, unnamed } of cases) {
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
    });
  }
});
