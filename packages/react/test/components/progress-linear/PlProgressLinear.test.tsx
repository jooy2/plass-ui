import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlProgressLinear } from 'plass-ui';

describe('PlProgressLinear', () => {
  describe('rendering', () => {
    it('renders a progressbar', async () => {
      const screen = await render(<PlProgressLinear value={40} />);

      await expect.element(screen.getByRole('progressbar')).toBeInTheDocument();
    });

    it('carries the value and the range', async () => {
      const screen = await render(<PlProgressLinear value={3} min={0} max={4} />);
      const bar = screen.getByRole('progressbar').element();

      expect(bar).toHaveAttribute('aria-valuenow', '3');
      expect(bar).toHaveAttribute('aria-valuemin', '0');
      expect(bar).toHaveAttribute('aria-valuemax', '4');
    });

    it('reports no value at all while indeterminate', async () => {
      const screen = await render(<PlProgressLinear label="Uploading" />);

      expect(screen.getByRole('progressbar').element()).not.toHaveAttribute('aria-valuenow');
    });

    it('is indeterminate by default', async () => {
      const screen = await render(<PlProgressLinear label="Working" />);

      expect(screen.getByRole('progressbar').element()).not.toHaveAttribute('aria-valuenow');
    });

    it('renders the label', async () => {
      const screen = await render(<PlProgressLinear value={40} label="Uploading" />);

      await expect.element(screen.getByText('Uploading')).toBeInTheDocument();
    });

    it('shows the value as a percentage of the range, not of 100', async () => {
      const screen = await render(<PlProgressLinear value={3} min={0} max={4} showValue />);

      await expect.element(screen.getByText('75%')).toBeInTheDocument();
    });

    it('shows nothing when there is no value to show', async () => {
      const screen = await render(<PlProgressLinear showValue label="Working" />);

      expect(screen.getByText('%').query()).toBeNull();
    });

    it('formats the value when told how', async () => {
      const screen = await render(
        <PlProgressLinear
          value={1240}
          max={4000}
          showValue
          format={{ style: 'currency', currency: 'USD', maximumFractionDigits: 0 }}
        />
      );

      await expect.element(screen.getByText('$1,240')).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<PlProgressLinear value={40} className="my-own-class" />);

      expect(screen.getByRole('progressbar').element()).toHaveClass('my-own-class');
    });

    it('reflects a changed value on re-render', async () => {
      const screen = await render(<PlProgressLinear value={40} showValue />);

      await expect.element(screen.getByText('40%')).toBeInTheDocument();

      await screen.rerender(<PlProgressLinear value={90} showValue />);

      await expect.element(screen.getByText('90%')).toBeInTheDocument();
    });
  });

  describe('the value', () => {
    it('clamps a value past the top of the range', async () => {
      const screen = await render(<PlProgressLinear value={180} showValue />);

      await expect.element(screen.getByText('100%')).toBeInTheDocument();
    });

    it('clamps a value below the bottom of it', async () => {
      const screen = await render(<PlProgressLinear value={-40} showValue />);

      await expect.element(screen.getByText('0%')).toBeInTheDocument();
    });

    it('falls back to indeterminate when the range is empty', async () => {
      const screen = await render(<PlProgressLinear value={5} min={10} max={10} showValue />);

      expect(screen.getByText('%').query()).toBeNull();
    });
  });

  describe('the groove', () => {
    it('travels rather than jumping when it has a value', async () => {
      const screen = await render(<PlProgressLinear value={40} />);
      const indicator = screen
        .getByRole('progressbar')
        .element()
        .querySelector('[class*="absolute"]');

      expect(indicator?.className).toContain('transition');
      expect(indicator?.className).not.toContain('plass-progress-sweep');
    });

    it('sweeps while indeterminate', async () => {
      const screen = await render(<PlProgressLinear label="Working" />);
      const sweep = screen
        .getByRole('progressbar')
        .element()
        .querySelector('.plass-progress-sweep');

      expect(sweep).not.toBeNull();
    });
  });
});
