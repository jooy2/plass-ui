/**
 * That a chart's marks ease as the reader points at them, which only the
 * stylesheet can answer.
 *
 * Every mark of a line, area, bar, scatter, pie, heatmap and timeline chart
 * carries `markTransitionClasses`, and a test that reads the class list passes
 * whether or not the stylesheet has a rule for it. Pieced together out of three
 * strings, it had none, and every mark snapped. So this file loads
 * `src/standalone.css` the way `fill-fade.test.tsx` does, reads what each mark
 * resolves, and records the fade a legend entry starts.
 *
 * No duration is asserted, only that the marks ease, and that under reduced
 * motion they do not.
 */
import * as React from 'react';
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlAreaChart,
  PlBarChart,
  PlHeatmapChart,
  PlLineChart,
  PlPieChart,
  PlScatterChart,
  PlTimelineChart
} from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { emulateMedia } from '../support/media';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

afterEach(async () => {
  await emulateMedia({ reducedMotion: 'no-preference' });
});

const MONTHS = ['Jan', 'Feb', 'Mar'];

const at = (day: number) => new Date(2026, 0, day);

interface Chart {
  render: () => React.ReactElement;
  /** What the mark grows on under the crosshair, besides fading. */
  grows?: 'r' | 'scale';
  /** A legend entry whose focus dims the other series, where the chart has a legend. */
  entry?: string;
}

const charts: Record<string, Chart> = {
  PlLineChart: {
    render: () => (
      <PlLineChart
        label="Sessions"
        categories={MONTHS}
        series={[
          { name: 'Web', data: [1, 2, 3] },
          { name: 'Mobile', data: [3, 2, 1] }
        ]}
        markers="all"
      />
    ),
    grows: 'r',
    entry: 'Web'
  },
  PlAreaChart: {
    render: () => (
      <PlAreaChart
        label="Sessions"
        categories={MONTHS}
        series={[
          { name: 'Web', data: [1, 2, 3] },
          { name: 'Mobile', data: [3, 2, 1] }
        ]}
      />
    ),
    entry: 'Web'
  },
  PlBarChart: {
    render: () => (
      <PlBarChart
        label="Sessions"
        categories={MONTHS}
        series={[
          { name: 'Web', data: [1, 2, 3] },
          { name: 'Mobile', data: [3, 2, 1] }
        ]}
      />
    ),
    entry: 'Web'
  },
  PlScatterChart: {
    render: () => (
      <PlScatterChart
        label="Sessions"
        series={[
          { name: 'Web', data: [{ x: 1, y: 2 }] },
          { name: 'Mobile', data: [{ x: 2, y: 1 }] }
        ]}
      />
    ),
    grows: 'scale',
    entry: 'Web'
  },
  PlPieChart: {
    render: () => <PlPieChart label="Sessions" categories={['Web', 'Mobile']} data={[60, 40]} />,
    entry: 'Web'
  },
  PlHeatmapChart: {
    render: () => (
      <PlHeatmapChart
        label="Sessions"
        categories={MONTHS}
        series={[
          { name: 'Web', data: [1, 2, 3] },
          { name: 'Mobile', data: [3, 2, 1] }
        ]}
      />
    )
  },
  PlTimelineChart: {
    render: () => (
      <PlTimelineChart
        label="Sessions"
        series={[{ name: 'Design', data: [{ start: at(1), end: at(9) }] }]}
      />
    )
  }
};

/**
 * Every element in the drawing that carries the mark transition, found by the
 * class the component writes. Whether the class does anything is what the
 * tests below read.
 */
function marksOf(plot: Element): Element[] {
  return [...plot.querySelectorAll('svg [class*="transition:opacity"]')];
}

/** Each property the element eases, with the duration it resolves for it. */
function easingsOf(element: Element): Map<string, number> {
  const style = getComputedStyle(element);
  const properties = style.transitionProperty.split(',').map((one) => one.trim());
  const lengths = style.transitionDuration.split(',').map((one) => parseFloat(one));
  const found = new Map<string, number>();

  properties.forEach((property, index) => {
    found.set(property, lengths[index % lengths.length]);
  });

  return found;
}

/** Renders the chart and waits for its marks, which arrive once it is measured. */
async function show(chart: Chart) {
  const screen = await render(chart.render());
  const plot = screen.getByRole('img', { name: 'Sessions' });

  await expect.poll(() => marksOf(plot.element()).length).toBeGreaterThan(0);

  return { screen, marks: marksOf(plot.element()) };
}

describe('a chart’s marks', () => {
  it.each(Object.entries(charts))('%s eases the fade of every mark', async (_, chart) => {
    const { marks } = await show(chart);

    for (const mark of marks) {
      expect(easingsOf(mark).get('opacity') ?? 0).toBeGreaterThan(0);
    }
  });

  it.each(Object.entries(charts).filter(([, chart]) => chart.grows))(
    '%s eases the growth of every mark',
    async (_, chart) => {
      const { marks } = await show(chart);
      const grown = marks.filter((mark) => mark.tagName !== 'g');

      expect(grown.length).toBeGreaterThan(0);

      for (const mark of grown) {
        expect(easingsOf(mark).get(chart.grows!) ?? 0).toBeGreaterThan(0);
      }
    }
  );

  it.each(Object.entries(charts))('%s eases nothing under reduced motion', async (_, chart) => {
    await emulateMedia({ reducedMotion: 'reduce' });

    const { marks } = await show(chart);

    for (const mark of marks) {
      expect([...easingsOf(mark).values()].every((seconds) => seconds === 0)).toBe(true);
    }
  });

  it.each(Object.entries(charts).filter(([, chart]) => chart.entry))(
    '%s fades the other series down as a legend entry takes the focus',
    async (_, chart) => {
      const { screen, marks } = await show(chart);
      const faded: Element[] = [];

      for (const mark of marks) {
        mark.addEventListener('transitionrun', (raw) => {
          if ((raw as TransitionEvent).propertyName === 'opacity' && raw.target === mark) {
            faded.push(mark);
          }
        });
      }

      screen.getByRole('button', { name: chart.entry }).element().focus();

      await expect.poll(() => faded.length).toBeGreaterThan(0);
    }
  );
});
