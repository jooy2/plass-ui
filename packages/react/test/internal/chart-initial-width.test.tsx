/**
 * A chart's drawing in the HTML a server sends.
 *
 * A chart lays itself out from the width its box is measured at, and a server
 * has no box, so the HTML held an empty box of the right height and the plot
 * arrived with the script. `initialWidth` is the width to lay it out at until
 * then: the server and the render that hydrates its HTML draw the whole chart
 * at it, and the measured width takes over once the page has hydrated. Left
 * out, nothing changes.
 *
 * Every chart is asked, because each one measures its own box.
 */
import * as React from 'react';
import { act } from 'react';
import { hydrateRoot } from 'react-dom/client';
import { renderToString } from 'react-dom/server';
import { describe, expect, it, vi } from 'vitest';
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

interface Case {
  name: string;
  chart: (initialWidth?: number) => React.ReactElement;
  /** Whether it writes ticks along an axis. */
  ticks: boolean;
}

const cases: Case[] = [
  {
    name: 'PlLineChart',
    chart: (initialWidth) => (
      <PlLineChart label="Sales" initialWidth={initialWidth} categories={MONTHS} series={SALES} />
    ),
    ticks: true
  },
  {
    name: 'PlAreaChart',
    chart: (initialWidth) => (
      <PlAreaChart label="Sales" initialWidth={initialWidth} categories={MONTHS} series={SALES} />
    ),
    ticks: true
  },
  {
    name: 'PlBarChart',
    chart: (initialWidth) => (
      <PlBarChart label="Sales" initialWidth={initialWidth} categories={MONTHS} series={SALES} />
    ),
    ticks: true
  },
  {
    name: 'PlScatterChart',
    chart: (initialWidth) => (
      <PlScatterChart
        label="Sales"
        initialWidth={initialWidth}
        series={[
          {
            name: 'Q1',
            data: [
              { x: 10, y: 22 },
              { x: 20, y: 31 },
              { x: 30, y: 28 }
            ]
          }
        ]}
      />
    ),
    ticks: true
  },
  {
    name: 'PlTimelineChart',
    chart: (initialWidth) => (
      <PlTimelineChart
        label="Sales"
        initialWidth={initialWidth}
        series={[
          { name: 'Design', data: [{ start: at(1), end: at(9) }] },
          { name: 'Build', data: [{ start: at(8), end: at(26) }] }
        ]}
      />
    ),
    ticks: true
  },
  {
    name: 'PlPieChart',
    chart: (initialWidth) => (
      <PlPieChart
        label="Sales"
        initialWidth={initialWidth}
        categories={MONTHS}
        data={[40, 25, 20, 15]}
      />
    ),
    ticks: false
  },
  {
    name: 'PlGaugeChart',
    chart: (initialWidth) => <PlGaugeChart label="Sales" initialWidth={initialWidth} value={68} />,
    ticks: false
  },
  {
    name: 'PlHeatmapChart',
    chart: (initialWidth) => (
      <PlHeatmapChart
        label="Sales"
        initialWidth={initialWidth}
        categories={MONTHS}
        series={[
          { name: 'Mon', data: [2, 9, 6, 1] },
          { name: 'Tue', data: [3, 11, 8, 2] }
        ]}
      />
    ),
    ticks: false
  },
  {
    name: 'PlSparkline',
    chart: (initialWidth) => (
      <PlSparkline label="Sales" initialWidth={initialWidth} data={[12, 19, 15, 22]} />
    ),
    ticks: false
  }
];

/** The server's HTML, in a box of its own `width` in the document. */
function serve(element: React.ReactElement, width: number): HTMLDivElement {
  const host = document.createElement('div');

  host.style.width = `${width}px`;
  host.innerHTML = renderToString(element);
  document.body.append(host);

  return host;
}

/**
 * The chart's drawing: the one `<svg>` that is the picture or sits directly in
 * it. A legend's swatch is an `<svg>` too, and neither is.
 */
function drawing(host: Element): SVGSVGElement | null {
  return (
    [...host.querySelectorAll('svg')].find(
      (svg) =>
        svg.getAttribute('role') === 'img' || svg.parentElement?.getAttribute('role') === 'img'
    ) ?? null
  );
}

describe('initialWidth', () => {
  for (const { name, chart, ticks } of cases) {
    describe(name, () => {
      it('leaves the server’s plot empty without it', () => {
        const host = serve(chart(), 320);

        try {
          expect(host.querySelector('svg')).toBeNull();
        } finally {
          host.remove();
        }
      });

      it('draws the whole chart at it on a server', () => {
        const html = renderToString(chart(480));
        const host = serve(chart(480), 320);

        try {
          const svg = drawing(host);

          // A prop the chart did not take for itself would reach the DOM as an
          // attribute.
          expect(html.toLowerCase()).not.toContain('initialwidth');
          expect(svg).not.toBeNull();
          expect(svg!.getAttribute('width')).toBe('480');
          expect(svg!.querySelectorAll('path, rect, circle').length).toBeGreaterThan(0);

          if (ticks) {
            expect(svg!.querySelectorAll('text').length).toBeGreaterThan(0);
          }

          // A guess wider than the box is cut at its edge rather than
          // spilling across the page.
          expect(svg!.parentElement!.classList.contains('overflow-hidden')).toBe(true);
        } finally {
          host.remove();
        }
      });

      it('hydrates what the server drew and then draws at the measured width', async () => {
        const host = serve(chart(480), 320);
        const onRecoverableError = vi.fn();

        try {
          const root = await act(async () => hydrateRoot(host, chart(480), { onRecoverableError }));

          try {
            const svg = drawing(host);

            expect(onRecoverableError).not.toHaveBeenCalled();
            expect(svg).not.toBeNull();
            expect(svg!.getAttribute('width')).toBe('320');
            expect(svg!.parentElement!.classList.contains('overflow-hidden')).toBe(false);
          } finally {
            await act(async () => root.unmount());
          }
        } finally {
          host.remove();
        }
      });
    });
  }

  it('writes the gauge’s reading into the server’s HTML', () => {
    expect(renderToString(<PlGaugeChart label="Quota" value={68} />)).not.toContain('>68<');
    expect(renderToString(<PlGaugeChart label="Quota" value={68} initialWidth={320} />)).toContain(
      '>68<'
    );
  });

  it('takes no width that cannot be drawn at as a guess', () => {
    for (const guess of [0, -120, Number.NaN, Number.POSITIVE_INFINITY]) {
      expect(renderToString(<PlLineChart initialWidth={guess} series={SALES} />)).not.toContain(
        '<svg'
      );
    }
  });

  it('leaves a sparkline of a numeric width as it was', () => {
    const html = renderToString(
      <PlSparkline label="Sales" width={200} initialWidth={480} data={[12, 19, 15, 22]} />
    );

    expect(html).toContain('width="200"');
    expect(html).not.toContain('width="480"');
    // Nothing is a guess, so nothing is cut.
    expect(html).toContain('<div class="absolute inset-0">');
  });
});
