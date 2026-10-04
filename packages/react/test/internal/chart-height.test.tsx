/**
 * A chart's `height` given as a CSS length.
 *
 * The prop says a string is any CSS length. A chart with two axes laid a
 * string out at no height at all and drew nothing, and the pie, the gauge and
 * the heatmap ignored it and drew at the `size` ladder. The box now takes the
 * length, and the drawing is laid out at the height the box is measured at:
 * the same drawing a number of those pixels gives.
 *
 * A number and the default are known before anything is measured, and are
 * drawn as they always were, on a server too.
 */
import * as React from 'react';
import { act } from 'react';
import { hydrateRoot } from 'react-dom/client';
import { renderToString } from 'react-dom/server';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlAreaChart,
  PlBarChart,
  PlGaugeChart,
  PlHeatmapChart,
  PlLineChart,
  PlPieChart,
  PlScatterChart,
  PlTimelineChart
} from 'plass-ui';

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr'];
const SALES = [{ name: 'Europe', data: [42, 45, 51, 49] }];
const at = (day: number) => new Date(2026, 0, day);

type Height = number | string;

interface Case {
  name: string;
  chart: (height: Height, initialWidth?: number) => React.ReactElement;
}

const cases: Case[] = [
  {
    name: 'PlLineChart',
    chart: (height, initialWidth) => (
      <PlLineChart
        label="Sales"
        height={height}
        initialWidth={initialWidth}
        categories={MONTHS}
        series={SALES}
      />
    )
  },
  {
    name: 'PlAreaChart',
    chart: (height, initialWidth) => (
      <PlAreaChart
        label="Sales"
        height={height}
        initialWidth={initialWidth}
        categories={MONTHS}
        series={SALES}
      />
    )
  },
  {
    name: 'PlBarChart',
    chart: (height, initialWidth) => (
      <PlBarChart
        label="Sales"
        height={height}
        initialWidth={initialWidth}
        categories={MONTHS}
        series={SALES}
      />
    )
  },
  {
    // Bubbles, because the largest one is sized off the chart's height.
    name: 'PlScatterChart',
    chart: (height, initialWidth) => (
      <PlScatterChart
        label="Sales"
        height={height}
        initialWidth={initialWidth}
        series={[
          {
            name: 'Q1',
            data: [
              { x: 10, y: 22, z: 4 },
              { x: 20, y: 31, z: 9 },
              { x: 30, y: 28, z: 16 }
            ]
          }
        ]}
      />
    )
  },
  {
    name: 'PlTimelineChart',
    chart: (height, initialWidth) => (
      <PlTimelineChart
        label="Sales"
        height={height}
        initialWidth={initialWidth}
        series={[
          { name: 'Design', data: [{ start: at(1), end: at(9) }] },
          { name: 'Build', data: [{ start: at(8), end: at(26) }] }
        ]}
      />
    )
  },
  {
    name: 'PlPieChart',
    chart: (height, initialWidth) => (
      <PlPieChart
        label="Sales"
        height={height}
        initialWidth={initialWidth}
        categories={MONTHS}
        data={[40, 25, 20, 15]}
      />
    )
  },
  {
    name: 'PlGaugeChart',
    chart: (height, initialWidth) => (
      <PlGaugeChart label="Sales" height={height} initialWidth={initialWidth} value={68} />
    )
  },
  {
    name: 'PlHeatmapChart',
    chart: (height, initialWidth) => (
      <PlHeatmapChart
        label="Sales"
        height={height}
        initialWidth={initialWidth}
        categories={MONTHS}
        series={[
          { name: 'Mon', data: [2, 9, 6, 1] },
          { name: 'Tue', data: [3, 11, 8, 2] }
        ]}
      />
    )
  }
];

/** The chart's drawing: the `<svg>` sitting directly in the picture. */
function drawing(host: Element): SVGSVGElement | null {
  return (
    [...host.querySelectorAll('svg')].find(
      (svg) => svg.parentElement?.getAttribute('role') === 'img'
    ) ?? null
  );
}

/** Where everything in a drawing is, and what it says, without its ids. */
function geometry(svg: SVGSVGElement): string[] {
  const placed = ['viewBox', 'width', 'height', 'd', 'x', 'y', 'cx', 'cy', 'r'];

  return [svg, ...svg.querySelectorAll('*')].map((element) =>
    [
      element.tagName,
      ...placed.map((name) => element.getAttribute(name) ?? ''),
      element.tagName === 'text' ? element.textContent : ''
    ].join('|')
  );
}

/** A chart in a box 480 pixels wide, once it has drawn. */
async function drawn(chart: React.ReactElement): Promise<SVGSVGElement> {
  const screen = await render(<div style={{ width: 480 }}>{chart}</div>);

  await expect.poll(() => drawing(screen.container)).not.toBeNull();

  return drawing(screen.container)!;
}

describe('a chart’s height', () => {
  for (const { name, chart } of cases) {
    describe(name, () => {
      it('draws a CSS length at the height its box is measured at', async () => {
        const svg = await drawn(chart('300px'));

        expect(svg.parentElement!.style.height).toBe('300px');
        expect(svg.getAttribute('height')).toBe('300');
        expect(svg.querySelectorAll('path, rect').length).toBeGreaterThan(0);
        // The same drawing three hundred pixels as a number gives.
        expect(geometry(svg)).toEqual(geometry(await drawn(chart(300))));
      });

      it('draws again when the box it measures changes height', async () => {
        const screen = await render(<div style={{ width: 480 }}>{chart('300px')}</div>);

        await expect.poll(() => drawing(screen.container)?.getAttribute('height')).toBe('300');

        await screen.rerender(<div style={{ width: 480 }}>{chart('20rem')}</div>);

        await expect.poll(() => drawing(screen.container)?.getAttribute('height')).toBe('320');
      });

      it('sends the box at that height from a server, and draws once it hydrates', async () => {
        const host = document.createElement('div');
        const onRecoverableError = vi.fn();

        host.style.width = '480px';
        host.innerHTML = renderToString(chart('300px', 480));
        document.body.append(host);

        try {
          // Nothing can be laid out at a height nobody has measured yet, even
          // with a width to draw at.
          expect(drawing(host)).toBeNull();
          expect(host.querySelector<HTMLElement>('[style*="height:300px"]')).not.toBeNull();

          const root = await act(async () =>
            hydrateRoot(host, chart('300px', 480), { onRecoverableError })
          );

          try {
            expect(onRecoverableError).not.toHaveBeenCalled();
            expect(drawing(host)?.getAttribute('height')).toBe('300');
          } finally {
            await act(async () => root.unmount());
          }
        } finally {
          host.remove();
        }
      });

      it('draws a number from a server, as before', () => {
        const host = document.createElement('div');

        host.innerHTML = renderToString(chart(300, 480));

        expect(drawing(host)?.getAttribute('height')).toBe('300');
      });
    });
  }
});
