import { describe, expect, it } from 'vitest';
import { PlSparkline } from 'plass-ui';
import { render } from 'vitest-browser-react';

const TREND = [12, 19, 15, 22, 18, 26];

describe('PlSparkline', () => {
  describe('rendering', () => {
    it('draws one line for the whole series', async () => {
      const screen = await render(<PlSparkline label="Signups" data={TREND} width={200} />);

      const strip = screen.getByRole('img', { name: 'Signups' });

      await expect.element(strip).toBeInTheDocument();
      expect(strip.element().querySelectorAll('path').length).toBe(1);
    });

    it('breaks the line at a gap rather than bridging it', async () => {
      const screen = await render(
        <PlSparkline label="Signups" data={[1, 2, null, 4, 5]} width={200} />
      );

      const strip = screen.getByRole('img', { name: 'Signups' });

      await expect.element(strip).toBeInTheDocument();

      // Two runs, so the path is moved to twice.
      const d = strip.element().querySelector('path')?.getAttribute('d') ?? '';

      expect((d.match(/M/g) ?? []).length).toBe(2);
    });

    it('draws a bar per value when asked', async () => {
      const screen = await render(
        <PlSparkline label="Signups" shape="bar" data={TREND} width={200} />
      );

      const strip = screen.getByRole('img', { name: 'Signups' });

      await expect.element(strip).toBeInTheDocument();
      expect(strip.element().querySelectorAll('path').length).toBe(TREND.length);
    });

    it('fills under the line with an area', async () => {
      const screen = await render(
        <PlSparkline label="Signups" shape="area" data={TREND} width={200} />
      );

      const strip = screen.getByRole('img', { name: 'Signups' });

      await expect.element(strip).toBeInTheDocument();

      // The wash and the line on top of it.
      expect(strip.element().querySelectorAll('path').length).toBe(2);
      expect(strip.element().querySelectorAll('linearGradient').length).toBe(1);
    });

    it('reflects a changed shape on re-render', async () => {
      const screen = await render(<PlSparkline label="Signups" data={TREND} width={200} />);

      await expect.element(screen.getByRole('img', { name: 'Signups' })).toBeInTheDocument();

      await screen.rerender(<PlSparkline label="Signups" shape="bar" data={TREND} width={200} />);

      const strip = screen.getByRole('img', { name: 'Signups' });

      await expect.element(strip).toBeInTheDocument();
      expect(strip.element().querySelectorAll('path').length).toBe(TREND.length);
    });
  });

  describe('the scale', () => {
    /** Where the mark actually sits, top to bottom. */
    const ys = (strip: Element) =>
      [
        ...(strip.querySelector('path')?.getAttribute('d') ?? '').matchAll(/[ML]([\d.]+) ([\d.]+)/g)
      ].map((one) => Number(one[2]));

    it('fills the strip with the series own range by default', async () => {
      const screen = await render(<PlSparkline label="Signups" data={[10, 11]} width={200} />);

      const strip = screen.getByRole('img', { name: 'Signups' });

      await expect.element(strip).toBeInTheDocument();

      // A one-unit spread still uses the whole height, which is the thing that
      // makes a sparkline legible and the thing that makes two incomparable.
      const drawn = ys(strip.element());

      expect(Math.max(...drawn) - Math.min(...drawn)).toBeGreaterThan(10);
    });

    it('shares a scale across strips when min and max are given', async () => {
      const screen = await render(
        <PlSparkline label="Signups" data={[10, 11]} min={0} max={100} width={200} />
      );

      const strip = screen.getByRole('img', { name: 'Signups' });

      await expect.element(strip).toBeInTheDocument();

      const drawn = ys(strip.element());

      expect(Math.max(...drawn) - Math.min(...drawn)).toBeLessThan(3);
    });

    it('stretches to take a baseline that sits outside the data', async () => {
      const screen = await render(
        <PlSparkline label="Signups" data={[10, 11]} baseline={100} width={200} />
      );

      const strip = screen.getByRole('img', { name: 'Signups' });

      await expect.element(strip).toBeInTheDocument();

      const rule = strip.element().querySelector('line');

      expect(rule).not.toBeNull();

      // The rule is at the top of the strip and the data is squashed against
      // the bottom, which is what including it in the range means.
      const drawn = ys(strip.element());

      expect(Number(rule?.getAttribute('y1'))).toBeLessThan(Math.min(...drawn));
    });
  });

  describe('endDot', () => {
    it('marks the last point that is a point, not the last slot', async () => {
      const screen = await render(
        <PlSparkline label="Signups" endDot data={[1, 5, null]} width={200} />
      );

      const strip = screen.getByRole('img', { name: 'Signups' });

      await expect.element(strip).toBeInTheDocument();

      const dot = strip.element().querySelector('circle');

      expect(dot).not.toBeNull();
      // Halfway along, where index 1 is — not at the far right.
      expect(Number(dot?.getAttribute('cx'))).toBeCloseTo(100, 0);
    });

    it('leaves bars alone, which already end where they end', async () => {
      const screen = await render(
        <PlSparkline label="Signups" shape="bar" endDot data={TREND} width={200} />
      );

      const strip = screen.getByRole('img', { name: 'Signups' });

      await expect.element(strip).toBeInTheDocument();
      expect(strip.element().querySelector('circle')).toBeNull();
    });
  });

  describe('accessibility', () => {
    it('reads out the numbers rather than describing the shape', async () => {
      const screen = await render(<PlSparkline label="Signups" data={[1, null, 3]} width={200} />);

      await expect.element(screen.getByText('1, —, 3')).toBeInTheDocument();
    });

    it('is invisible to a reader when it carries no name', async () => {
      const screen = await render(<PlSparkline data={TREND} width={200} />);

      // An unnamed strip is decoration beside text that already has the
      // numbers, so it is taken off the tree rather than announced as an
      // unlabelled image.
      await expect.poll(() => screen.container.querySelector('svg')).not.toBeNull();
      expect(screen.container.querySelector('svg')).toHaveAttribute('aria-hidden', 'true');
      expect(screen.getByRole('img').query()).toBeNull();
    });
  });
});
