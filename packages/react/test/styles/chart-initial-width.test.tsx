/**
 * That a chart drawn at its `initialWidth` stays inside its box.
 *
 * The width is a guess, and a page laid out narrower than the guess would
 * otherwise have the drawing spill past the box, and past the window on a
 * phone, until the script measures the box. Whether it is cut is up to the
 * stylesheet, so this file loads `src/standalone.css` the way
 * `chart-marks.test.tsx` does and reads how wide the server's HTML lays out.
 */
import * as React from 'react';
import { renderToString } from 'react-dom/server';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
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
import standaloneCss from '../../src/standalone.css?inline';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr'];
const SALES = [{ name: 'Europe', data: [42, 45, 51, 49] }];
const at = (day: number) => new Date(2026, 0, day);

const charts: Record<string, React.ReactElement> = {
  PlLineChart: <PlLineChart initialWidth={640} categories={MONTHS} series={SALES} />,
  PlAreaChart: <PlAreaChart initialWidth={640} categories={MONTHS} series={SALES} />,
  PlBarChart: <PlBarChart initialWidth={640} categories={MONTHS} series={SALES} />,
  PlScatterChart: (
    <PlScatterChart
      initialWidth={640}
      series={[
        {
          name: 'Q1',
          data: [
            { x: 10, y: 22 },
            { x: 30, y: 28 }
          ]
        }
      ]}
    />
  ),
  PlTimelineChart: (
    <PlTimelineChart
      initialWidth={640}
      series={[{ name: 'Design', data: [{ start: at(1), end: at(9) }] }]}
    />
  ),
  PlPieChart: <PlPieChart initialWidth={640} data={[40, 25, 20, 15]} />,
  PlGaugeChart: <PlGaugeChart initialWidth={640} value={68} />,
  PlHeatmapChart: (
    <PlHeatmapChart
      initialWidth={640}
      categories={MONTHS}
      series={[{ name: 'Mon', data: [2, 9, 6, 1] }]}
    />
  ),
  PlSparkline: <PlSparkline initialWidth={640} data={[12, 19, 15, 22]} />
};

describe('a chart drawn at a guess wider than its box', () => {
  for (const [name, chart] of Object.entries(charts)) {
    it(`is cut at the edge of the box on ${name}`, () => {
      const box = document.createElement('div');

      box.style.width = '320px';
      box.innerHTML = renderToString(chart);
      document.body.append(box);

      try {
        expect(box.querySelector('svg[width="640"]')).not.toBeNull();
        expect(box.scrollWidth).toBe(320);
      } finally {
        box.remove();
      }
    });
  }
});
