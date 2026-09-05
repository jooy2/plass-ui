import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlPieChart } from 'plass-ui';

const SOURCES = ['Search', 'Social', 'Direct', 'Referral'];

/** Every slice drawn, in the order the arcs were built. */
function slices(plot: Element): SVGPathElement[] {
  return [...plot.querySelectorAll<SVGPathElement>('path[fill]:not([fill="none"])')];
}

describe('PlPieChart', () => {
  describe('rendering', () => {
    it('draws one arc per slice', async () => {
      const screen = await render(
        <PlPieChart label="Traffic" categories={SOURCES} data={[40, 25, 20, 15]} />
      );

      const plot = screen.getByRole('img', { name: 'Traffic' });

      await expect.element(plot).toBeInTheDocument();
      expect(slices(plot.element()).length).toBe(4);
    });

    it('skips a gap and a zero, which have no angle to draw', async () => {
      const screen = await render(
        <PlPieChart label="Traffic" categories={SOURCES} data={[40, null, 0, 15]} />
      );

      const plot = screen.getByRole('img', { name: 'Traffic' });

      await expect.element(plot).toBeInTheDocument();
      expect(slices(plot.element()).length).toBe(2);
    });

    it('says there is nothing to draw when the total is zero', async () => {
      const screen = await render(<PlPieChart label="Traffic" data={[0, 0]} />);

      await expect.element(screen.getByText('Nothing here')).toBeInTheDocument();
    });

    it('names every slice in the table, not just the series', async () => {
      const screen = await render(
        <PlPieChart label="Traffic" categories={SOURCES} data={[40, 25, 20, 15]} />
      );

      await expect.element(screen.getByRole('table', { name: 'Traffic' })).toBeInTheDocument();
      await expect.element(screen.getByRole('rowheader', { name: 'Social' })).toBeInTheDocument();
    });

    it('reflects a changed shape on re-render', async () => {
      const chart = (shape: 'pie' | 'donut') => (
        <PlPieChart label="Traffic" shape={shape} categories={SOURCES} data={[40, 25, 20, 15]} />
      );

      const screen = await render(chart('pie'));
      const plot = screen.getByRole('img', { name: 'Traffic' });

      await expect.element(plot).toBeInTheDocument();

      // A disc's wedge is drawn from the centre out — `M{cx} {cy}L` — and a
      // ring's is not, so the path itself is what says which shape this is.
      expect(slices(plot.element())[0].getAttribute('d')).toMatch(/^M[\d.]+ [\d.]+L/);

      await screen.rerender(chart('donut'));

      await expect.element(plot).toBeInTheDocument();
      expect(slices(plot.element())[0].getAttribute('d')).toMatch(/^M[\d.]+ [\d.]+A/);
    });
  });

  describe('center', () => {
    it('puts the caller’s own content in the hole of a donut', async () => {
      const screen = await render(
        <PlPieChart label="Traffic" shape="donut" data={[40, 60]} center={<strong>100</strong>} />
      );

      await expect.element(screen.getByText('100')).toBeInTheDocument();
    });

    it('leaves it out of a pie, which has no hole to put it in', async () => {
      const screen = await render(
        <PlPieChart label="Traffic" data={[40, 60]} center={<strong>100</strong>} />
      );

      await expect.element(screen.getByRole('img', { name: 'Traffic' })).toBeInTheDocument();
      expect(screen.getByText('100').query()).toBeNull();
    });
  });

  describe('valueLabels', () => {
    it('writes the share and not the value', async () => {
      const screen = await render(
        <PlPieChart label="Traffic" valueLabels="all" data={[750, 250]} height={240} />
      );

      const plot = screen.getByRole('img', { name: 'Traffic' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((one) => one.textContent);

      expect(texts).toContain('75%');
      expect(texts).not.toContain('750');
    });

    it('writes nothing by default', async () => {
      const screen = await render(<PlPieChart label="Traffic" data={[750, 250]} height={240} />);

      const plot = screen.getByRole('img', { name: 'Traffic' });

      await expect.element(plot).toBeInTheDocument();
      expect(plot.element().querySelectorAll('text').length).toBe(0);
    });
  });

  describe('the legend', () => {
    it('lists the slices rather than the series', async () => {
      const screen = await render(
        <PlPieChart label="Traffic" categories={SOURCES} data={[40, 25, 20, 15]} />
      );

      for (const name of SOURCES) {
        await expect.element(screen.getByRole('button', { name })).toBeInTheDocument();
      }
    });

    it('takes a slice out of the ring and shares its angle out again', async () => {
      const screen = await render(
        // The tooltip is off because nothing loads the CSS here, so the readout
        // panel is neither absolutely positioned nor `pointer-events-none` — it
        // joins the flow, spills out of the plot's fixed height and catches the
        // click meant for the legend. That is the test run's missing stylesheet,
        // not the component, and this test is about the legend either way.
        <PlPieChart label="Traffic" categories={SOURCES} data={[40, 25, 20, 15]} tooltip={false} />
      );

      const plot = screen.getByRole('img', { name: 'Traffic' });

      await expect.element(plot).toBeInTheDocument();

      const entry = screen.getByRole('button', { name: 'Social' });

      await entry.click();

      // Waited for on the button rather than on the count: the click is what
      // takes time here, and a poll that starts its own clock afterwards is a
      // race against Playwright's actionability wait rather than against the
      // render.
      await expect.element(entry).toHaveAttribute('aria-pressed', 'false');
      expect(slices(plot.element()).length).toBe(3);
    });
  });

  describe('the keyboard', () => {
    it('walks the slices with the arrow keys and says which one it is on', async () => {
      const screen = await render(
        <PlPieChart label="Traffic" categories={SOURCES} data={[40, 25, 20, 15]} />
      );

      const plot = screen.getByRole('img', { name: 'Traffic' });

      await expect.element(plot).toBeInTheDocument();

      const status = screen.container.querySelector('[role="status"]') as HTMLElement;

      arrow(plot.element(), 'ArrowRight');
      await expect.poll(() => status.textContent).toContain('Search');

      arrow(plot.element(), 'ArrowLeft');
      await expect.poll(() => status.textContent).toContain('Referral');
    });

    it('is a tab stop only while there is something on it', async () => {
      const screen = await render(<PlPieChart label="Traffic" data={[0, 0]} />);

      await expect.element(screen.getByRole('img', { name: 'Traffic' })).toBeInTheDocument();
      expect(screen.getByRole('img', { name: 'Traffic' }).element()).not.toHaveAttribute(
        'tabindex'
      );
    });
  });
});

/**
 * The plot is a `role="img"` rather than a control, and nothing in the test run
 * loads the CSS that gives it a size — so Playwright has no box to click and
 * focus before pressing a key. The component listens for `keydown`, which is
 * what this sends.
 */
function arrow(element: Element, key: string): void {
  element.dispatchEvent(new KeyboardEvent('keydown', { key, bubbles: true, cancelable: true }));
}
