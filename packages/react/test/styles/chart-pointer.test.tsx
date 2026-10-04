/**
 * Which column or mark a chart inside a scaled ancestor reads under the
 * pointer.
 *
 * The chart is drawn at half its size by a `transform` on the box around it, as
 * a chart inside a scaled `PlMockup` is, with `src/standalone.css` loaded the
 * way `carousel.test.tsx` loads it, so the panel is placed and lets the pointer
 * through. Each mark is found where it is drawn on the screen, and the pointer
 * is put on the middle of it: whatever the scale, the chart has to read that
 * one.
 */
import * as React from 'react';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlBarChart, PlLineChart, PlScatterChart, PlTimelineChart } from 'plass-ui';
import type { PlassOrientation } from 'plass-ui';
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

const orientations: PlassOrientation[] = ['vertical', 'horizontal'];

/** A chart laid out at twice the size it is drawn at. */
function Scaled({ children }: { children: React.ReactNode }) {
  return (
    <div style={{ transform: 'scale(0.5)', transformOrigin: '0 0', width: 640 }}>{children}</div>
  );
}

/** The element that reads the pointer: the picture, by its role. */
function plotOf(name: string): HTMLElement {
  return document.querySelector<HTMLElement>(`[role="img"][aria-label="${name}"]`)!;
}

/**
 * Every mark drawn, in paint order, found by the class every mark carries. A
 * bar chart's series are groups that carry it as well, so only the shapes are
 * taken.
 */
function marksOf(plot: Element): Element[] {
  return [...plot.querySelectorAll('svg :is(path, rect)[class*="transition:opacity"]')];
}

/**
 * Puts the pointer on `mark` as it is drawn on the screen: on the middle of it,
 * or, given the way a bar grows, two pixels short of the end it grows to.
 */
function pointAt(plot: Element, mark: Element, grows?: PlassOrientation) {
  const box = mark.getBoundingClientRect();

  plot.dispatchEvent(
    new PointerEvent('pointermove', {
      bubbles: true,
      clientX: grows === 'horizontal' ? box.right - 2 : box.left + box.width / 2,
      clientY: grows === 'vertical' ? box.top + 2 : box.top + box.height / 2
    })
  );
}

/** What the chart says it is reading, which is what the panel shows. */
function status(): string {
  return document.querySelector('[role="status"]')?.textContent ?? '';
}

describe('a chart inside a scaled ancestor', () => {
  it.each(orientations)('reads the column under the pointer, %s', async (orientation) => {
    await render(
      <Scaled>
        <PlBarChart
          label="Sessions"
          orientation={orientation}
          categories={MONTHS}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      </Scaled>
    );

    await expect.poll(() => marksOf(plotOf('Sessions')).length).toBe(4);

    const plot = plotOf('Sessions');

    for (const [index, bar] of marksOf(plot).entries()) {
      pointAt(plot, bar);

      await expect.poll(status).toBe(`${MONTHS[index]}, Web: ${(index + 1) * 10}`);
    }
  });

  it.each(orientations)(
    'reads the series nearest the pointer with mode="item", %s',
    async (orientation) => {
      await render(
        <Scaled>
          <PlBarChart
            label="Sessions"
            orientation={orientation}
            categories={MONTHS}
            tooltip={{ mode: 'item' }}
            series={[
              { name: 'High', data: [100, 100, 100, 100] },
              { name: 'Low', data: [10, 10, 10, 10] }
            ]}
          />
        </Scaled>
      );

      await expect.poll(() => marksOf(plotOf('Sessions')).length).toBe(8);

      const plot = plotOf('Sessions');
      const [high, low] = [marksOf(plot).slice(0, 4), marksOf(plot).slice(4)];

      // The end of a bar, which is where its value is: the middle of a long
      // bar can be nearer the end of a short one beside it.
      pointAt(plot, low[2], orientation);

      await expect.poll(status).toBe('Mar, Low: 10');

      pointAt(plot, high[1], orientation);

      await expect.poll(status).toBe('Feb, High: 100');
    }
  );

  it('reads the line nearest the pointer with mode="item"', async () => {
    await render(
      <Scaled>
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          markers="all"
          tooltip={{ mode: 'item' }}
          series={[
            { name: 'High', data: [100, 100, 100, 100] },
            { name: 'Low', data: [10, 10, 10, 10] }
          ]}
        />
      </Scaled>
    );

    const dots = () => [...plotOf('Sessions').querySelectorAll('svg circle')];

    await expect.poll(() => dots().length).toBe(8);

    const plot = plotOf('Sessions');

    pointAt(plot, dots()[6]);

    await expect.poll(status).toBe('Mar, Low: 10');

    pointAt(plot, dots()[1]);

    await expect.poll(status).toBe('Feb, High: 100');
  });

  it('reads the mark under the pointer on a PlScatterChart', async () => {
    const points = [
      { x: 10, y: 22 },
      { x: 20, y: 31 },
      { x: 30, y: 28 },
      { x: 40, y: 12 }
    ];

    await render(
      <Scaled>
        <PlScatterChart label="Spend" series={[{ name: 'Q1', data: points }]} />
      </Scaled>
    );

    await expect.poll(() => marksOf(plotOf('Spend')).length).toBe(4);

    const plot = plotOf('Spend');

    // The marks are painted largest first, and all four are the same size, so
    // they are in the order they were given.
    for (const [index, mark] of marksOf(plot).entries()) {
      pointAt(plot, mark);

      await expect.poll(status).toBe(`${points[index].x}, Q1: ${points[index].y}`);
    }
  });

  it('reads the span under the pointer on a PlTimelineChart', async () => {
    const at = (day: number) => new Date(2026, 0, day);
    const rows = ['Design', 'Build', 'Ship'];

    await render(
      <Scaled>
        <PlTimelineChart
          label="Plan"
          series={[
            { name: 'Design', data: [{ start: at(1), end: at(9) }] },
            { name: 'Build', data: [{ start: at(8), end: at(20) }] },
            { name: 'Ship', data: [{ start: at(19), end: at(28) }] }
          ]}
        />
      </Scaled>
    );

    await expect.poll(() => marksOf(plotOf('Plan')).length).toBe(3);

    const plot = plotOf('Plan');

    for (const [index, span] of marksOf(plot).entries()) {
      pointAt(plot, span);

      await expect.poll(status).toMatch(new RegExp(`^${rows[index]}, `));
    }
  });
});
