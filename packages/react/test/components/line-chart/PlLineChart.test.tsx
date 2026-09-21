import { userEvent } from 'vitest/browser';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlLineChart } from 'plass-ui';
import { press } from '../../support/keys';

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr'];

/**
 * A chart is measured before it draws, so nothing reaches the DOM until the
 * host element has a width. In a browser test the element is laid out for real,
 * but the `ResizeObserver` callback that confirms it lands a task later —
 * `expect.element` retries, which is what makes these assertions stable.
 */
describe('PlLineChart', () => {
  describe('rendering', () => {
    it('exposes the plot as an image with its label', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions by month"
          categories={MONTHS}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      await expect
        .element(screen.getByRole('img', { name: 'Sessions by month' }))
        .toBeInTheDocument();
    });

    it('draws one path per series', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          series={[
            { name: 'Web', data: [10, 20, 30, 40] },
            { name: 'Mobile', data: [5, 15, 25, 35] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      // Two line paths, and no fill paths — that is what makes this a line
      // chart rather than an area one.
      expect(plot.element().querySelectorAll('path[stroke]:not([stroke="none"])').length).toBe(2);
    });

    it('writes the categories and the values into a table', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions by month"
          categories={MONTHS}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const table = screen.getByRole('table', { name: 'Sessions by month' });

      await expect.element(table).toBeInTheDocument();
      await expect.element(screen.getByRole('rowheader', { name: 'Mar' })).toBeInTheDocument();
      await expect.element(screen.getByRole('columnheader', { name: 'Web' })).toBeInTheDocument();
      await expect.element(screen.getByRole('cell', { name: '30' })).toBeInTheDocument();
    });

    it('reflects a changed series on re-render', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          series={[{ name: 'Web', data: [1, 2] }]}
        />
      );

      await expect.element(screen.getByRole('cell', { name: '2' })).toBeInTheDocument();

      await screen.rerender(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          series={[{ name: 'Web', data: [1, 9] }]}
        />
      );

      await expect.element(screen.getByRole('cell', { name: '9' })).toBeInTheDocument();
    });

    it('shows the empty state rather than an axis when there is nothing to draw', async () => {
      const screen = await render(<PlLineChart label="Sessions" series={[]} empty="No data yet" />);

      await expect.element(screen.getByText('No data yet')).toBeInTheDocument();
      expect(screen.getByRole('table').query()).toBeNull();
    });

    it('leaves a gap out of the table rather than writing it as a zero', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          series={[{ name: 'Web', data: [10, null, 30, 40] }]}
        />
      );

      const table = screen.getByRole('table');

      await expect.element(table).toBeInTheDocument();

      const cells = [...table.element().querySelectorAll('tbody td')].map((cell) =>
        cell.textContent?.trim()
      );

      expect(cells).toEqual(['10', '', '30', '40']);
    });
  });

  describe('the nearest tooltip mode', () => {
    it('answers with the one series the pointer is nearest, and draws no crosshair', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          tooltip={{ mode: 'nearest' }}
          series={[
            { name: 'Web', data: [10, 20, 30, 40] },
            { name: 'App', data: [90, 80, 70, 60] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      await userEvent.hover(plot);

      // A crosshair says "these numbers all belong to this column", and with a
      // mark under the pointer there is no column.
      expect(plot.element().querySelectorAll('line[stroke-dasharray="4 4"]').length).toBe(0);
    });

    it('walks the marks with the arrow keys rather than the columns', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          tooltip={{ mode: 'nearest' }}
          series={[
            { name: 'Web', data: [10, 20, 30, 40] },
            { name: 'App', data: [90, 80, 70, 60] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      plot.element().focus();
      await press(plot.element(), 'ArrowRight');

      // One series in the readout, not the whole column: the walk is mark by
      // mark, and a mark names its own series.
      const status = document.querySelector('[role="status"]');

      expect(status?.textContent).toContain('Web');
      expect(status?.textContent).not.toContain('App');
    });
  });

  describe('reference lines', () => {
    it('draws one across the plot, dashed, and names it at the end of the line', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
          reference={{ value: 25, label: 'Target' }}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' }).element();

      await expect.element(screen.getByRole('img', { name: 'Sessions' })).toBeInTheDocument();

      const dashed = [...plot.querySelectorAll('line[stroke-dasharray]')];

      expect(dashed.length).toBe(1);
      expect([...plot.querySelectorAll('text')].map((one) => one.textContent)).toContain('Target');
    });

    it('takes several, and a solid one when it is asked for', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
          reference={[
            { value: 25, label: 'Target' },
            { value: 35, dashed: false, color: 'danger' }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' }).element();

      await expect.element(screen.getByRole('img', { name: 'Sessions' })).toBeInTheDocument();
      expect(plot.querySelectorAll('line[stroke-dasharray]').length).toBe(1);
      expect(plot.querySelector('line[stroke="var(--plass-danger-accent)"]')).not.toBeNull();
    });

    it('says them in the description, because a target is a fact about the picture', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
          reference={{ value: 25, label: 'Target' }}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' }).element();

      await expect.element(screen.getByRole('img', { name: 'Sessions' })).toBeInTheDocument();

      const description = document.getElementById(plot.getAttribute('aria-describedby') ?? '');

      expect(description?.textContent).toContain('Target 25');
    });
  });

  describe('legend', () => {
    it('is left off for a single series', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          series={[{ name: 'Web', data: [1, 2] }]}
        />
      );

      await expect.element(screen.getByRole('img', { name: 'Sessions' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Web' }).query()).toBeNull();
    });

    it('lists every series from two up, pressed', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          series={[
            { name: 'Web', data: [1, 2] },
            { name: 'Mobile', data: [3, 4] }
          ]}
        />
      );

      await expect
        .element(screen.getByRole('button', { name: 'Web' }))
        .toHaveAttribute('aria-pressed', 'true');
      await expect.element(screen.getByRole('button', { name: 'Mobile' })).toBeInTheDocument();
    });

    /**
     * Pointing at one entry drops every other series to 0.28. Only the pie ever
     * did that over any time at all — everywhere else the whole picture snapped
     * between two states on the frame the pointer crossed a row.
     */
    it('fades the other series down rather than switching them', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          series={[
            { name: 'Web', data: [1, 2] },
            { name: 'Mobile', data: [3, 4] }
          ]}
        />
      );

      await expect.element(screen.getByRole('button', { name: 'Web' })).toBeInTheDocument();

      const groups = [...screen.container.querySelectorAll('svg g[opacity]')];

      expect(groups.length).toBeGreaterThan(0);
      expect(
        groups.every((g) => (g.getAttribute('class') ?? '').includes('transition:opacity'))
      ).toBe(true);
    });

    /** The entry itself dims too, and the house transition does not name opacity. */
    it('fades the legend entry it dims', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          series={[
            { name: 'Web', data: [1, 2] },
            { name: 'Mobile', data: [3, 4] }
          ]}
        />
      );

      const entry = screen.getByRole('button', { name: 'Web' }).element();

      expect(entry.className).toContain('transition-property:background-color,color,opacity');
    });

    it('hides a series when its entry is clicked, and keeps it in the list', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          series={[
            { name: 'Web', data: [1, 2] },
            { name: 'Mobile', data: [3, 4] }
          ]}
        />
      );

      const entry = screen.getByRole('button', { name: 'Web' });

      await entry.click();

      await expect.element(entry).toHaveAttribute('aria-pressed', 'false');
    });

    it('starts a series hidden when it says so', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          series={[
            { name: 'Web', data: [1, 2] },
            { name: 'Mobile', data: [3, 4], hidden: true }
          ]}
        />
      );

      await expect
        .element(screen.getByRole('button', { name: 'Mobile' }))
        .toHaveAttribute('aria-pressed', 'false');
    });

    it('folds past `maxEntries`, and says how many are behind the button', async () => {
      const many = Array.from({ length: 6 }, (_, index) => ({
        name: `Series ${index + 1}`,
        data: [index + 1, index + 2]
      }));

      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={['Jan', 'Feb']}
          series={many}
          legend={{ maxEntries: 2 }}
        />
      );

      await expect.element(screen.getByRole('button', { name: '4 more' })).toBeInTheDocument();
      expect(screen.getByRole('button', { pressed: true }).elements().length).toBe(2);

      await screen.getByRole('button', { name: '4 more' }).click();

      // Every entry, and the way back out on the same button.
      expect(screen.getByRole('button', { pressed: true }).elements().length).toBe(6);
      await expect.element(screen.getByRole('button', { name: 'Show fewer' })).toBeInTheDocument();
    });

    it('can be turned off entirely', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          legend={false}
          series={[
            { name: 'Web', data: [1, 2] },
            { name: 'Mobile', data: [3, 4] }
          ]}
        />
      );

      await expect.element(screen.getByRole('img', { name: 'Sessions' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Web' }).query()).toBeNull();
    });
  });

  describe('accessibility', () => {
    it('names itself when no label was given', async () => {
      const screen = await render(
        <PlLineChart categories={MONTHS} series={[{ name: 'Web', data: [10, 20, 30, 40] }]} />
      );

      // A focusable `role="img"` with no name is a tab stop that announces
      // nothing at all, so the fallback is not cosmetic.
      await expect.element(screen.getByRole('img', { name: 'Chart' })).toBeInTheDocument();
    });

    it('keeps the readout outside the picture', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          height={200}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      // `role="img"` is a leaf: everything under it is cut out of the
      // accessibility tree, so a live region in there would announce to nobody.
      const status = screen.getByRole('status');

      await expect.element(status).toBeInTheDocument();
      expect(plot.element().contains(status.element())).toBe(false);
    });
  });

  describe('moving the active column', () => {
    it('writes the category labels once rather than on every move', async () => {
      const categories = Array.from({ length: 60 }, (_, index) => `Day ${index + 1}`);
      const tickFormat = vi.fn((category: unknown) => String(category));
      const screen = await render(
        <PlLineChart
          label="Visits"
          categories={categories}
          xAxis={{ tickFormat }}
          series={[{ name: 'Web', data: categories.map((_, index) => index) }]}
        />
      );
      const plot = screen.getByRole('img', { name: 'Visits' });

      await expect.element(plot).toBeInTheDocument();
      await expect.poll(() => tickFormat.mock.calls.length).toBeGreaterThan(0);

      const written = tickFormat.mock.calls.length;

      for (let day = 1; day <= 5; day += 1) {
        press(plot.element(), 'ArrowRight');
        await expect
          .poll(() => screen.getByRole('status').element().textContent)
          .toMatch(new RegExp(`^Day ${day}\\b`));
      }

      expect(tickFormat.mock.calls.length).toBe(written);
    });
  });

  describe('tooltip', () => {
    it('opens on an arrow key and names the category', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });
      const status = () => screen.getByRole('status').element().textContent;

      await expect.element(plot).toBeInTheDocument();
      expect(status()).toBe('');

      press(plot.element(), 'ArrowRight');

      await expect.poll(status).toBe('Jan, Web: 10');
      expect(document.querySelector('[data-plass-tooltip]')).not.toBeNull();
    });

    it('walks the columns with the arrow keys, Home and End, and stops at the ends', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });
      const status = () => screen.getByRole('status').element().textContent;

      await expect.element(plot).toBeInTheDocument();

      for (const [key, reading] of [
        ['ArrowRight', 'Jan, Web: 10'],
        ['ArrowRight', 'Feb, Web: 20'],
        ['End', 'Apr, Web: 40'],
        ['ArrowRight', 'Apr, Web: 40'],
        ['ArrowLeft', 'Mar, Web: 30'],
        ['Home', 'Jan, Web: 10'],
        ['ArrowLeft', 'Jan, Web: 10']
      ] as const) {
        press(plot.element(), key);
        await expect.poll(status).toBe(reading);
      }
    });

    it('starts from the last column when the first key goes back', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      press(plot.element(), 'ArrowLeft');

      await expect
        .poll(() => screen.getByRole('status').element().textContent)
        .toBe('Apr, Web: 40');
    });

    it('closes on Escape and consumes only the keys it answers', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });
      const status = () => screen.getByRole('status').element().textContent;

      await expect.element(plot).toBeInTheDocument();
      press(plot.element(), 'ArrowRight');
      await expect.poll(status).toBe('Jan, Web: 10');

      const escape = new KeyboardEvent('keydown', {
        key: 'Escape',
        bubbles: true,
        cancelable: true
      });

      plot.element().dispatchEvent(escape);

      await expect.poll(status).toBe('');
      expect(escape.defaultPrevented).toBe(true);
      expect(document.querySelector('[data-plass-tooltip]')).toBeNull();

      const other = new KeyboardEvent('keydown', { key: 'a', bubbles: true, cancelable: true });

      plot.element().dispatchEvent(other);
      expect(other.defaultPrevented).toBe(false);
    });

    it('narrows to the nearest series with mode="item"', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          height={200}
          tooltip={{ mode: 'item' }}
          series={[
            { name: 'High', data: [100, 100, 100, 100] },
            { name: 'Low', data: [1, 1, 1, 1] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      // Near the top of the plot, which is where the high series runs.
      await plot.hover({ position: { x: 120, y: 12 } });

      // The readout, which is what a screen reader is given, and the panel,
      // which is what everybody else sees. The panel carries no role of its
      // own — it is inside the chart's `role="img"`, where a role would be
      // announced to nobody — so it is reached by its data attribute.
      const status = screen.getByRole('status');

      await expect.element(status).toBeInTheDocument();
      expect(status.element().textContent).toContain('High');
      expect(status.element().textContent).not.toContain('Low');
      expect(document.querySelectorAll('[data-plass-tooltip] li').length).toBe(1);
    });

    it('shows the whole column with mode="index"', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          height={200}
          series={[
            { name: 'High', data: [100, 100, 100, 100] },
            { name: 'Low', data: [1, 1, 1, 1] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      await plot.hover({ position: { x: 120, y: 12 } });

      const status = screen.getByRole('status');

      await expect.element(status).toBeInTheDocument();
      expect(status.element().textContent).toContain('High');
      expect(status.element().textContent).toContain('Low');
      expect(document.querySelectorAll('[data-plass-tooltip] li').length).toBe(2);
    });

    it('is not focusable when it is turned off', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          tooltip={false}
          series={[{ name: 'Web', data: [10, 20] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      expect(plot.element().querySelectorAll('[role="status"]').length).toBe(0);
    });
  });

  describe('axes', () => {
    it('writes each tick through tickFormat', async () => {
      const screen = await render(
        <PlLineChart
          label="Uptime"
          categories={MONTHS}
          yAxis={{ min: 0, max: 100, tickCount: 2, tickFormat: (value) => `${value}%` }}
          series={[{ name: 'Uptime', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Uptime' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).toContain('0%');
      expect(texts).toContain('100%');
    });

    it('keeps both ends of a pinned scale', async () => {
      const screen = await render(
        <PlLineChart
          label="Uptime"
          categories={MONTHS}
          yAxis={{ min: 99.5, max: 100, tickCount: 5 }}
          series={[{ name: 'Uptime', data: [99.6, 99.8, 99.9, 100] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Uptime' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).toContain('99.5');
      expect(texts).toContain('100');
    });

    it('draws no category labels when the axis is hidden', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          xAxis={{ hidden: true }}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).not.toContain('Jan');
    });

    it('drops the gridlines when the value axis says so', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          yAxis={{ grid: false }}
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      // Only the baseline is left.
      expect(plot.element().querySelectorAll('line').length).toBe(1);
    });
  });

  describe('marks', () => {
    it('draws a dot per point with markers="all"', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          markers="all"
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      expect(plot.element().querySelectorAll('circle').length).toBe(4);
    });

    it('draws none with markers="none"', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          markers="none"
          series={[{ name: 'Web', data: [10, 20, 30, 40] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();
      expect(plot.element().querySelectorAll('circle').length).toBe(0);
    });

    it('labels only the last point with valueLabels="last"', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          valueLabels="last"
          series={[{ name: 'Web', data: [11, 22, 33, 44] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).toContain('44');
      expect(texts).not.toContain('11');
    });

    it('labels the high and the low with valueLabels="extremes"', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          valueLabels="extremes"
          series={[{ name: 'Web', data: [31, 12, 57, 44] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).toContain('12');
      expect(texts).toContain('57');
      expect(texts).not.toContain('31');
      expect(texts).not.toContain('44');
    });

    it('takes the extremes from the values that exist, not from the gaps', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          valueLabels="extremes"
          series={[{ name: 'Web', data: [31, null, 57, 44] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      // A gap is not a zero, so the low is 31 rather than the missing month.
      expect(texts).toContain('31');
      expect(texts).toContain('57');
      expect(texts).not.toContain('44');
    });

    it('labels nothing for a series that is all gap, and still labels the one beside it', async () => {
      // The second series is what keeps the chart drawn at all — a chart with
      // no numbers anywhere renders its empty state instead, which would never
      // reach the code this is about.
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          valueLabels="extremes"
          series={[
            { name: 'Web', data: [null, null, null, null] },
            { name: 'App', data: [63, 21, 39, 47] }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Sessions' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).toContain('21');
      expect(texts).toContain('63');
      expect(texts).not.toContain('39');
      expect(texts).not.toContain('47');
    });

    it('reads a gap as a zero with nulls="zero", everywhere at once', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          nulls="zero"
          series={[{ name: 'Web', data: [10, null, 30, 40] }]}
        />
      );

      const drawn = screen
        .getByRole('img', { name: 'Sessions' })
        .element()
        .querySelector('path[stroke]:not([stroke="none"])')
        ?.getAttribute('d');

      // One run rather than two: there is nothing missing to break at.
      expect((drawn?.match(/M/g) ?? []).length).toBe(1);

      // And the nought is in the table too, because a zero read only by the
      // painter would be a picture the numbers under it disagree with.
      const cells = [...screen.getByRole('table').element().querySelectorAll('tbody td')].map(
        (cell) => cell.textContent?.trim()
      );

      expect(cells).toEqual(['10', '0', '30', '40']);
    });

    it('breaks the path at a gap, and bridges it with nulls="connect"', async () => {
      const screen = await render(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          series={[{ name: 'Web', data: [10, null, 30, 40] }]}
        />
      );

      const broken = screen
        .getByRole('img', { name: 'Sessions' })
        .element()
        .querySelector('path[stroke]:not([stroke="none"])')
        ?.getAttribute('d');

      expect((broken?.match(/M/g) ?? []).length).toBe(2);

      await screen.rerender(
        <PlLineChart
          label="Sessions"
          categories={MONTHS}
          nulls="connect"
          series={[{ name: 'Web', data: [10, null, 30, 40] }]}
        />
      );

      const bridged = screen
        .getByRole('img', { name: 'Sessions' })
        .element()
        .querySelector('path[stroke]:not([stroke="none"])')
        ?.getAttribute('d');

      expect((bridged?.match(/M/g) ?? []).length).toBe(1);
    });
  });

  describe('formatting', () => {
    it('passes format through to the table', async () => {
      const screen = await render(
        <PlLineChart
          label="Revenue"
          categories={MONTHS}
          format={{ style: 'currency', currency: 'USD', maximumFractionDigits: 0 }}
          series={[{ name: 'Revenue', data: [1200, 1400] }]}
        />
      );

      await expect.element(screen.getByRole('cell', { name: '$1,200' })).toBeInTheDocument();
    });
  });
});
