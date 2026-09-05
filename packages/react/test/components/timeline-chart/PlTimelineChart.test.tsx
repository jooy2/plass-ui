import { describe, expect, it } from 'vitest';
import { PlTimelineChart } from 'plass-ui';
import { render } from 'vitest-browser-react';

const at = (day: number) => new Date(2026, 0, day);

const PLAN = [
  {
    name: 'Design',
    data: [
      { start: at(1), end: at(9), label: 'Wireframes' },
      { start: at(11), end: at(18), label: 'Visuals' }
    ]
  },
  {
    name: 'Build',
    data: [{ start: at(8), end: at(26), label: 'Implementation' }]
  }
];

/** Every span drawn. */
function spans(plot: Element): SVGRectElement[] {
  return [...plot.querySelectorAll<SVGRectElement>('svg rect')];
}

describe('PlTimelineChart', () => {
  describe('rendering', () => {
    it('draws one bar per span', async () => {
      const screen = await render(<PlTimelineChart label="Plan" series={PLAN} />);

      const plot = screen.getByRole('img', { name: 'Plan' });

      await expect.element(plot).toBeInTheDocument();
      expect(spans(plot.element()).length).toBe(3);
    });

    it('names the rows down the side rather than in a legend', async () => {
      const screen = await render(<PlTimelineChart label="Plan" series={PLAN} />);

      const plot = screen.getByRole('img', { name: 'Plan' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((one) => one.textContent);

      expect(texts).toContain('Design');
      expect(texts).toContain('Build');
      // A Gantt's rows *are* its axis, so there is nothing to click.
      expect(screen.getByRole('button', { name: 'Design' }).query()).toBeNull();
    });

    it('draws a span the caller wrote backwards either way round', async () => {
      const screen = await render(
        <PlTimelineChart
          label="Plan"
          series={[{ name: 'Design', data: [{ start: at(20), end: at(4) }] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Plan' });

      await expect.element(plot).toBeInTheDocument();
      expect(Number(spans(plot.element())[0].getAttribute('width'))).toBeGreaterThan(10);
    });

    it('leaves a span with no times undrawn', async () => {
      const screen = await render(
        <PlTimelineChart
          label="Plan"
          series={[
            {
              name: 'Design',
              // A string is not an instant, so this span has nowhere to be.
              data: [
                { start: 'soon' as never, end: at(9) },
                { start: at(2), end: at(6) }
              ]
            }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Plan' });

      await expect.element(plot).toBeInTheDocument();
      expect(spans(plot.element()).length).toBe(1);
    });

    it('says there is nothing to draw when no row has a span', async () => {
      const screen = await render(
        <PlTimelineChart label="Plan" series={[{ name: 'Design', data: [] }]} />
      );

      await expect.element(screen.getByText('Nothing here')).toBeInTheDocument();
    });
  });

  describe('the time axis', () => {
    it('ticks where a calendar ticks rather than on round milliseconds', async () => {
      const screen = await render(<PlTimelineChart label="Plan" series={PLAN} />);

      const plot = screen.getByRole('img', { name: 'Plan' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')]
        .map((one) => one.textContent ?? '')
        .filter((one) => one !== 'Design' && one !== 'Build');

      // Dates a reader recognises, not `1,767,225,600,000`.
      expect(texts.length).toBeGreaterThan(1);
      expect(texts.every((one) => /\d/.test(one) && !/\d{6}/.test(one))).toBe(true);
    });

    it('takes its own ends over the data', async () => {
      const screen = await render(
        <PlTimelineChart label="Plan" series={PLAN} min={at(1)} max={at(60)} />
      );

      const plot = screen.getByRole('img', { name: 'Plan' });

      await expect.element(plot).toBeInTheDocument();

      // Two months of axis, so a nine-day span is a short bar rather than half
      // the plot.
      const widths = spans(plot.element()).map((one) => Number(one.getAttribute('width')));

      expect(Math.max(...widths)).toBeLessThan(plot.element().clientWidth * 0.5);
    });
  });

  describe('lanes', () => {
    it('moves an overlapping span onto a lane of its own', async () => {
      const overlapping = [
        {
          name: 'Design',
          data: [
            { start: at(1), end: at(20) },
            { start: at(5), end: at(25) }
          ]
        }
      ];

      const screen = await render(<PlTimelineChart label="Plan" series={overlapping} />);

      const plot = screen.getByRole('img', { name: 'Plan' });

      await expect.element(plot).toBeInTheDocument();

      // Two bars on the same row at two different heights, not one over the
      // other.
      const ys = spans(plot.element()).map((one) => Number(one.getAttribute('y')));

      expect(ys[0]).not.toBe(ys[1]);
    });

    it('leaves a row whose spans do not overlap in one lane', async () => {
      const screen = await render(
        <PlTimelineChart
          label="Plan"
          series={[
            {
              name: 'Design',
              data: [
                { start: at(1), end: at(5) },
                { start: at(6), end: at(9) }
              ]
            }
          ]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Plan' });

      await expect.element(plot).toBeInTheDocument();

      const ys = spans(plot.element()).map((one) => Number(one.getAttribute('y')));

      expect(ys[0]).toBe(ys[1]);
    });
  });

  describe('the table', () => {
    it('writes a row per span rather than a grid', async () => {
      const screen = await render(<PlTimelineChart label="Plan" series={PLAN} />);
      const table = screen.getByRole('table', { name: 'Plan' });

      await expect.element(table).toBeInTheDocument();
      expect(table.element().querySelectorAll('tbody tr').length).toBe(3);
    });

    it('adds a label column only when a span carries one', async () => {
      const screen = await render(<PlTimelineChart label="Plan" series={PLAN} />);

      await expect.element(screen.getByRole('columnheader', { name: 'label' })).toBeInTheDocument();

      await screen.rerender(
        <PlTimelineChart
          label="Plan"
          series={[{ name: 'Design', data: [{ start: at(1), end: at(9) }] }]}
        />
      );

      await expect.element(screen.getByRole('table', { name: 'Plan' })).toBeInTheDocument();
      expect(screen.getByRole('columnheader', { name: 'label' }).query()).toBeNull();
    });
  });
});
