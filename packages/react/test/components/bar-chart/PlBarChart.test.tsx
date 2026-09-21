import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlBarChart } from 'plass-ui';

const TEAMS = ['Platform', 'Payments', 'Growth'];

describe('PlBarChart', () => {
  describe('rendering', () => {
    it('draws one filled path per value', async () => {
      const screen = await render(
        <PlBarChart
          label="Deploys per team"
          categories={TEAMS}
          series={[{ name: 'Deploys', data: [10, 20, 30] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Deploys per team' });

      await expect.element(plot).toBeInTheDocument();
      expect(plot.element().querySelectorAll('path[fill]:not([fill="none"])').length).toBe(3);
    });

    it('draws nothing for a gap', async () => {
      const screen = await render(
        <PlBarChart
          label="Deploys"
          categories={TEAMS}
          series={[{ name: 'Deploys', data: [10, null, 30] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Deploys' });

      await expect.element(plot).toBeInTheDocument();
      expect(plot.element().querySelectorAll('path[fill]:not([fill="none"])').length).toBe(2);
    });

    it('writes its data into a table', async () => {
      const screen = await render(
        <PlBarChart
          label="Deploys per team"
          categories={TEAMS}
          series={[{ name: 'Deploys', data: [10, 20, 30] }]}
        />
      );

      await expect
        .element(screen.getByRole('table', { name: 'Deploys per team' }))
        .toBeInTheDocument();
      await expect.element(screen.getByRole('rowheader', { name: 'Payments' })).toBeInTheDocument();
    });

    it('reflects a changed orientation on re-render', async () => {
      const screen = await render(
        <PlBarChart
          label="Deploys"
          categories={TEAMS}
          series={[{ name: 'Deploys', data: [1, 2, 3] }]}
        />
      );

      await expect.element(screen.getByRole('img', { name: 'Deploys' })).toBeInTheDocument();

      await screen.rerender(
        <PlBarChart
          label="Deploys"
          orientation="horizontal"
          categories={TEAMS}
          series={[{ name: 'Deploys', data: [1, 2, 3] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Deploys' });

      await expect.element(plot).toBeInTheDocument();
      expect(plot.element().querySelectorAll('path[fill]:not([fill="none"])').length).toBe(3);
    });
  });

  describe('a turned category axis', () => {
    const CHANNELS = [
      'Organic search',
      'Direct traffic',
      'Email campaigns',
      'Paid social',
      'Referral links',
      'Affiliate partners'
    ];

    const sessions = [{ name: 'Sessions', data: [48, 39, 27, 19, 11, 8] }];

    /** The labels along the bottom, which are every text but the value ticks. */
    const names = (plot: HTMLElement) =>
      [...plot.querySelectorAll('text')].map((one) => one.textContent ?? '');

    /**
     * A box narrow enough for six of these names to be a problem. The chart
     * measures the element it is in, so this has to be a real width rather than
     * a prop — and without it the test would be reading the browser window.
     */
    const narrow = (chart: React.ReactNode) => <div style={{ width: 420 }}>{chart}</div>;

    it('cuts names to their slot and thins them out while it is upright', async () => {
      const screen = await render(
        narrow(<PlBarChart label="Sessions" categories={CHANNELS} series={sessions} />)
      );
      const plot = screen.getByRole('img', { name: 'Sessions' }).element() as HTMLElement;

      await expect.element(screen.getByRole('img', { name: 'Sessions' })).toBeInTheDocument();
      expect(names(plot).some((text) => text.endsWith('…'))).toBe(true);
    });

    it('turns them instead, whole, and writes every one', async () => {
      const screen = await render(
        narrow(
          <PlBarChart
            label="Sessions"
            categories={CHANNELS}
            series={sessions}
            xAxis={{ tickAngle: -45 }}
            height={300}
          />
        )
      );
      const plot = screen.getByRole('img', { name: 'Sessions' }).element() as HTMLElement;

      await expect.element(screen.getByRole('img', { name: 'Sessions' })).toBeInTheDocument();

      const drawn = names(plot);

      for (const channel of CHANNELS) {
        expect(drawn).toContain(channel);
      }

      const turned = [...plot.querySelectorAll('text[transform]')];

      expect(turned.length).toBe(CHANNELS.length);
      // Anchored at the end so the text runs back up towards its own tick,
      // which is what makes a negative angle read from the bottom left.
      expect(turned[0].getAttribute('transform')).toMatch(/^rotate\(-45 /);
      expect(turned[0].getAttribute('text-anchor')).toBe('end');
    });

    it('turns them on its own with `auto`, and only once one would be cut', async () => {
      const screen = await render(
        narrow(
          <PlBarChart
            label="Sessions"
            categories={CHANNELS}
            series={sessions}
            xAxis={{ tickAngle: 'auto' }}
            height={300}
          />
        )
      );
      const plot = screen.getByRole('img', { name: 'Sessions' }).element() as HTMLElement;

      await expect.element(screen.getByRole('img', { name: 'Sessions' })).toBeInTheDocument();
      expect(plot.querySelectorAll('text[transform]').length).toBe(CHANNELS.length);

      // Three short names fit their slots, and upright is the best an axis can
      // do when there is room for it.
      await screen.rerender(
        narrow(
          <PlBarChart
            label="Sessions"
            categories={['Jan', 'Feb', 'Mar']}
            series={[{ name: 'Sessions', data: [48, 39, 27] }]}
            xAxis={{ tickAngle: 'auto' }}
            height={300}
          />
        )
      );

      expect(plot.querySelectorAll('text[transform]').length).toBe(0);
    });

    it('leaves a horizontal chart alone, whose names already have a row each', async () => {
      const screen = await render(
        narrow(
          <PlBarChart
            label="Sessions"
            categories={CHANNELS}
            series={sessions}
            orientation="horizontal"
            xAxis={{ tickAngle: -45 }}
          />
        )
      );
      const plot = screen.getByRole('img', { name: 'Sessions' }).element() as HTMLElement;

      await expect.element(screen.getByRole('img', { name: 'Sessions' })).toBeInTheDocument();
      expect(plot.querySelectorAll('text[transform]').length).toBe(0);
    });
  });

  describe('sorting and folding', () => {
    const CITIES = ['Seoul', 'Tokyo', 'Lisbon', 'Quito'];
    const visits = [{ name: 'Visits', data: [10, 50, 30, 5] }];

    const names = (screen: Awaited<ReturnType<typeof render>>) =>
      [...screen.getByRole('table').element().querySelectorAll('tbody th')].map((cell) =>
        cell.textContent?.trim()
      );

    it('draws the categories in the order they were given', async () => {
      const screen = await render(
        <PlBarChart label="Visits" categories={CITIES} series={visits} />
      );

      await expect.element(screen.getByRole('table')).toBeInTheDocument();
      expect(names(screen)).toEqual(CITIES);
    });

    it('puts them in order of size, and the table agrees with the picture', async () => {
      const screen = await render(
        <PlBarChart label="Visits" categories={CITIES} series={visits} sort="descending" />
      );

      await expect.element(screen.getByRole('table')).toBeInTheDocument();
      expect(names(screen)).toEqual(['Tokyo', 'Lisbon', 'Seoul', 'Quito']);
    });

    it('folds the tail into one last category, named from the label pack', async () => {
      const screen = await render(
        <PlBarChart label="Visits" categories={CITIES} series={visits} maxCategories={2} />
      );

      await expect.element(screen.getByRole('table')).toBeInTheDocument();
      expect(names(screen)).toEqual(['Tokyo', 'Lisbon', 'Other']);
    });

    it('takes a name of its own for that fold', async () => {
      const screen = await render(
        <PlBarChart
          label="Visits"
          categories={CITIES}
          series={visits}
          maxCategories={2}
          otherLabel="Everywhere else"
        />
      );

      await expect.element(screen.getByRole('table')).toBeInTheDocument();
      expect(names(screen)).toContain('Everywhere else');
    });
  });

  describe('valueLabels', () => {
    it('writes nothing on the bars by default', async () => {
      const screen = await render(
        <PlBarChart
          label="Deploys"
          categories={TEAMS}
          series={[{ name: 'Deploys', data: [11, 22, 33] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Deploys' });

      await expect.element(plot).toBeInTheDocument();
      expect([...plot.element().querySelectorAll('text')].map((t) => t.textContent)).not.toContain(
        '11'
      );
    });

    it('writes every value with all', async () => {
      const screen = await render(
        <PlBarChart
          label="Deploys"
          valueLabels="all"
          categories={TEAMS}
          series={[{ name: 'Deploys', data: [11, 22, 33] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Deploys' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).toContain('11');
      expect(texts).toContain('22');
      expect(texts).toContain('33');
    });

    it("writes each number in its own series' colour, or in the page's ink", async () => {
      const label = (plot: HTMLElement) =>
        [...plot.querySelectorAll('text')].find((one) => one.textContent === '11');

      const screen = await render(
        <PlBarChart
          label="Deploys"
          valueLabels="all"
          categories={TEAMS}
          series={[{ name: 'Deploys', data: [11, 22, 33] }]}
        />
      );
      const plot = screen.getByRole('img', { name: 'Deploys' }).element() as HTMLElement;

      await expect.element(screen.getByRole('img', { name: 'Deploys' })).toBeInTheDocument();
      expect(label(plot)?.getAttribute('fill')).toBe('var(--plass-chart-1)');

      await screen.rerender(
        <PlBarChart
          label="Deploys"
          valueLabels="all"
          valueLabelColor="ink"
          categories={TEAMS}
          series={[{ name: 'Deploys', data: [11, 22, 33] }]}
        />
      );

      expect(label(plot)?.getAttribute('fill')).toBe('var(--plass-fg)');
    });

    it('writes only the high and the low with extremes', async () => {
      const screen = await render(
        <PlBarChart
          label="Deploys"
          valueLabels="extremes"
          categories={TEAMS}
          series={[{ name: 'Deploys', data: [11, 22, 33] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Deploys' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).toContain('11');
      expect(texts).toContain('33');
      expect(texts).not.toContain('22');
    });

    it('writes the last value that is there when the series ends in a gap', async () => {
      const screen = await render(
        <PlBarChart
          label="Deploys"
          valueLabels="last"
          categories={TEAMS}
          series={[{ name: 'Deploys', data: [11, 23, null] }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Deploys' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((t) => t.textContent);

      expect(texts).toContain('23');
      expect(texts).not.toContain('11');
    });
  });

  describe('stacked', () => {
    it('keeps the caller’s own numbers in the table when stacking to full', async () => {
      const screen = await render(
        <PlBarChart
          label="Mix"
          stacked="full"
          categories={['Jan']}
          series={[
            { name: 'New', data: [40] },
            { name: 'Renewed', data: [160] }
          ]}
        />
      );

      const table = screen.getByRole('table', { name: 'Mix' });

      await expect.element(table).toBeInTheDocument();

      // The bars are drawn as 20% and 80%; the table still says 40 and 160,
      // which is what the caller actually has.
      const cells = [...table.element().querySelectorAll('tbody td')].map((cell) =>
        cell.textContent?.trim()
      );

      expect(cells).toEqual(['40', '160']);
    });

    it('writes those numbers in the caller’s format when stacking to full', async () => {
      const screen = await render(
        <PlBarChart
          label="Mix"
          stacked="full"
          format={{ style: 'currency', currency: 'USD', maximumFractionDigits: 0 }}
          locale="en-US"
          categories={['Jan']}
          series={[
            { name: 'New', data: [4000] },
            { name: 'Renewed', data: [16000] }
          ]}
        />
      );

      const table = screen.getByRole('table', { name: 'Mix' });

      await expect.element(table).toBeInTheDocument();
      expect(
        [...table.element().querySelectorAll('tbody td')].map((cell) => cell.textContent?.trim())
      ).toEqual(['$4,000', '$16,000']);
    });

    it('puts the percentage on the value axis in either orientation', async () => {
      const mix = (orientation: 'vertical' | 'horizontal') => (
        <PlBarChart
          label="Mix"
          stacked="full"
          orientation={orientation}
          categories={['Seoul', 'Tokyo']}
          series={[
            { name: 'New', data: [1, 2] },
            { name: 'Renewed', data: [3, 4] }
          ]}
        />
      );

      const screen = await render(mix('vertical'));
      const plot = screen.getByRole('img', { name: 'Mix' });

      const texts = async () => {
        await expect.element(plot).toBeInTheDocument();

        return [...plot.element().querySelectorAll('text')].map((t) => t.textContent);
      };

      expect(await texts()).toContain('100%');

      await screen.rerender(mix('horizontal'));

      // Still on the value axis, and nowhere near the category names. `xAxis`
      // is the category axis and `yAxis` the value axis whichever way the bars
      // run, so turning the chart on its side must not send the tick format to
      // the other one.
      const turned = await texts();

      expect(turned).toContain('100%');
      expect(turned).toContain('Seoul');
      expect(turned).not.toContain('Seoul%');
    });
  });

  describe('the highlight', () => {
    /**
     * Two states, one sentence at two scales: a whole series drops to 0.28 when
     * the legend is pointed at another, and a single bar sits at 0.92 until the
     * crosshair reaches it. Only the pie and the heatmap ever faded either of
     * them; everywhere else the picture snapped between two states on the frame
     * the pointer crossed something.
     */
    it('fades both the series and the bar under the crosshair', async () => {
      const screen = await render(
        <PlBarChart
          label="Deploys per team"
          categories={TEAMS}
          series={[
            { name: 'Deploys', data: [10, 20, 30] },
            { name: 'Rollbacks', data: [1, 2, 3] }
          ]}
        />
      );

      await expect.element(screen.getByRole('button', { name: 'Deploys' })).toBeInTheDocument();

      const series = screen.container.querySelector('svg g[opacity]') as SVGGElement;
      const bar = series.querySelector('path') as SVGPathElement;

      expect(series.getAttribute('class')).toContain('transition:opacity');
      expect(bar.getAttribute('class')).toContain('transition:opacity');
    });

    /**
     * An entry that is switched off has nothing on the plot to be highlighted,
     * so pointing at it must leave the drawn series where they are rather than
     * fading every one of them for a series that is not there.
     */
    it('leaves the drawn series alone while a hidden entry is pointed at', async () => {
      const screen = await render(
        <PlBarChart
          label="Deploys per team"
          categories={TEAMS}
          series={[
            { name: 'Deploys', data: [10, 20, 30] },
            { name: 'Rollbacks', data: [1, 2, 3], hidden: true }
          ]}
        />
      );

      const entry = screen.getByRole('button', { name: 'Rollbacks' });

      await expect.element(entry).toHaveAttribute('aria-pressed', 'false');
      await entry.hover();

      const groups = [...screen.container.querySelectorAll('svg g[opacity]')];

      expect(groups.length).toBe(1);
      expect(groups[0].getAttribute('opacity')).toBe('1');
    });
  });
});
