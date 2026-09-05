import { describe, expect, it } from 'vitest';
import { PlGaugeChart } from 'plass-ui';
import { render } from 'vitest-browser-react';

/** The stroke that is the reading, as a fraction of the arc. */
function drawn(plot: Element): number | null {
  const arc = plot.querySelector('path[stroke-dasharray]');

  return arc === null ? null : 1 - Number(arc.getAttribute('stroke-dashoffset'));
}

describe('PlGaugeChart', () => {
  describe('rendering', () => {
    it('names itself with the reading and the top of the scale', async () => {
      const screen = await render(<PlGaugeChart label="Quota" value={68} />);

      await expect
        .element(screen.getByRole('img', { name: 'Quota: 68 / 100' }))
        .toBeInTheDocument();
    });

    it('writes the reading in the middle as real text', async () => {
      const screen = await render(<PlGaugeChart label="Quota" value={68} />);

      // Real text and not an SVG label, so it can be selected and found.
      await expect.element(screen.getByText('68')).toBeInTheDocument();
    });

    it('draws the groove with nothing on it for a null reading', async () => {
      const screen = await render(<PlGaugeChart label="Quota" value={null} />);

      const plot = screen.getByRole('img', { name: 'Quota' });

      await expect.element(plot).toBeInTheDocument();
      expect(drawn(plot.element())).toBeNull();
      await expect.element(screen.getByText('—')).toBeInTheDocument();
    });

    it('fills the arc in proportion to the reading', async () => {
      const screen = await render(<PlGaugeChart label="Quota" value={25} />);

      const plot = screen.getByRole('img', { name: 'Quota' });

      await expect.element(plot).toBeInTheDocument();
      expect(drawn(plot.element())).toBeCloseTo(0.25, 3);
    });

    it('clamps a reading outside the scale rather than overrunning the arc', async () => {
      const screen = await render(<PlGaugeChart label="Quota" value={140} />);

      const plot = screen.getByRole('img', { name: 'Quota' });

      await expect.element(plot).toBeInTheDocument();
      expect(drawn(plot.element())).toBe(1);
    });

    it('reads its own min and max rather than assuming a percentage', async () => {
      const screen = await render(<PlGaugeChart label="Speed" value={90} min={60} max={120} />);

      const plot = screen.getByRole('img', { name: 'Speed: 90 / 120' });

      await expect.element(plot).toBeInTheDocument();
      expect(drawn(plot.element())).toBeCloseTo(0.5, 3);
    });

    it('says there is nothing to draw when the range is empty', async () => {
      const screen = await render(<PlGaugeChart label="Quota" value={5} min={10} max={10} />);

      await expect.element(screen.getByText('Nothing here')).toBeInTheDocument();
    });

    it('reflects a changed reading on re-render', async () => {
      const screen = await render(<PlGaugeChart label="Quota" value={25} />);

      await expect
        .element(screen.getByRole('img', { name: 'Quota: 25 / 100' }))
        .toBeInTheDocument();

      await screen.rerender(<PlGaugeChart label="Quota" value={75} />);

      const plot = screen.getByRole('img', { name: 'Quota: 75 / 100' });

      await expect.element(plot).toBeInTheDocument();
      expect(drawn(plot.element())).toBeCloseTo(0.75, 3);
    });
  });

  describe('thresholds', () => {
    /** Which family the arc is wearing. */
    const family = (plot: Element) =>
      plot.querySelector('path[stroke-dasharray]')?.getAttribute('stroke');

    it('takes the highest band at or below the reading', async () => {
      const bands = [
        { from: 60, color: 'warning' as const },
        { from: 90, color: 'danger' as const }
      ];

      const screen = await render(<PlGaugeChart label="Quota" value={95} thresholds={bands} />);

      const plot = screen.getByRole('img', { name: 'Quota: 95 / 100' });

      await expect.element(plot).toBeInTheDocument();
      expect(family(plot.element())).toBe('var(--plass-danger-fill)');
    });

    it('reads the bands rather than walking them in order', async () => {
      // The same two bands, written the other way round. A rule that took the
      // last match would answer `warning` here.
      const bands = [
        { from: 90, color: 'danger' as const },
        { from: 60, color: 'warning' as const }
      ];

      const screen = await render(<PlGaugeChart label="Quota" value={95} thresholds={bands} />);

      const plot = screen.getByRole('img', { name: 'Quota: 95 / 100' });

      await expect.element(plot).toBeInTheDocument();
      expect(family(plot.element())).toBe('var(--plass-danger-fill)');
    });

    it('stands on color below every band', async () => {
      const screen = await render(
        <PlGaugeChart
          label="Quota"
          value={10}
          color="success"
          thresholds={[{ from: 60, color: 'danger' }]}
        />
      );

      const plot = screen.getByRole('img', { name: 'Quota: 10 / 100' });

      await expect.element(plot).toBeInTheDocument();
      expect(family(plot.element())).toBe('var(--plass-success-fill)');
    });
  });

  describe('the dial', () => {
    it('writes the ends of the scale by default', async () => {
      const screen = await render(<PlGaugeChart label="Speed" value={90} min={60} max={120} />);

      const plot = screen.getByRole('img', { name: 'Speed: 90 / 120' });

      await expect.element(plot).toBeInTheDocument();

      const texts = [...plot.element().querySelectorAll('text')].map((one) => one.textContent);

      expect(texts).toEqual(['60', '120']);
    });

    it('leaves them out when asked, and on a full ring where they would collide', async () => {
      const screen = await render(<PlGaugeChart label="Quota" value={40} showRange={false} />);

      const plot = screen.getByRole('img', { name: 'Quota: 40 / 100' });

      await expect.element(plot).toBeInTheDocument();
      expect(plot.element().querySelectorAll('text').length).toBe(0);

      await screen.rerender(<PlGaugeChart label="Quota" value={40} sweep={360} />);

      const ring = screen.getByRole('img', { name: 'Quota: 40 / 100' });

      await expect.element(ring).toBeInTheDocument();
      expect(ring.element().querySelectorAll('text').length).toBe(0);
    });

    it('draws the marks it is asked for, ends included', async () => {
      const screen = await render(<PlGaugeChart label="Quota" value={40} ticks={5} />);

      const plot = screen.getByRole('img', { name: 'Quota: 40 / 100' });

      await expect.element(plot).toBeInTheDocument();
      expect(plot.element().querySelectorAll('line').length).toBe(5);
    });

    it('draws none by default', async () => {
      const screen = await render(<PlGaugeChart label="Quota" value={40} />);

      const plot = screen.getByRole('img', { name: 'Quota: 40 / 100' });

      await expect.element(plot).toBeInTheDocument();
      expect(plot.element().querySelectorAll('line').length).toBe(0);
    });
  });

  describe('center and caption', () => {
    it('takes the caller own content in place of the number', async () => {
      const screen = await render(
        <PlGaugeChart label="Quota" value={68} center={<strong>Nearly</strong>} />
      );

      await expect.element(screen.getByText('Nearly')).toBeInTheDocument();
      expect(screen.getByText('68').query()).toBeNull();
    });

    it('hangs a caption under the reading', async () => {
      const screen = await render(<PlGaugeChart label="Quota" value={68} caption="of quota" />);

      await expect.element(screen.getByText('of quota')).toBeInTheDocument();
      await expect.element(screen.getByText('68')).toBeInTheDocument();
    });
  });

  describe('accessibility', () => {
    it('is a plain box when it has no name to be called by', async () => {
      const screen = await render(<PlGaugeChart value={68} />);

      expect(screen.getByRole('img').query()).toBeNull();
      // The reading is still text, so it is still read.
      await expect.element(screen.getByText('68')).toBeInTheDocument();
    });
  });
});
