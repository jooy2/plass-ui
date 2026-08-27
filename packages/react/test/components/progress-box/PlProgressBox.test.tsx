import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlProgressBox } from 'plass-ui';

/** The fill layer inside each plate, in order. */
function fillsOf(element: Element): HTMLElement[] {
  return [...element.querySelectorAll('[aria-hidden="true"]')] as HTMLElement[];
}

describe('PlProgressBox', () => {
  describe('rendering', () => {
    it('renders a progressbar', async () => {
      const screen = await render(<PlProgressBox value={40} />);

      await expect.element(screen.getByRole('progressbar')).toBeInTheDocument();
    });

    it('carries the value and the range', async () => {
      const screen = await render(<PlProgressBox value={3} min={0} max={4} />);
      const row = screen.getByRole('progressbar').element();

      expect(row).toHaveAttribute('aria-valuenow', '3');
      expect(row).toHaveAttribute('aria-valuemin', '0');
      expect(row).toHaveAttribute('aria-valuemax', '4');
    });

    it('reports no value at all while indeterminate', async () => {
      const screen = await render(<PlProgressBox label="Working" />);

      expect(screen.getByRole('progressbar').element()).not.toHaveAttribute('aria-valuenow');
    });

    it('renders the label and the value', async () => {
      const screen = await render(<PlProgressBox value={50} label="Deploying" showValue />);

      await expect.element(screen.getByText('Deploying')).toBeInTheDocument();
      await expect.element(screen.getByText('50%')).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<PlProgressBox value={40} className="my-own-class" />);

      expect(screen.getByRole('progressbar').element()).toHaveClass('my-own-class');
    });

    it('reflects a changed value on re-render', async () => {
      const screen = await render(<PlProgressBox value={40} showValue />);

      await expect.element(screen.getByText('40%')).toBeInTheDocument();

      await screen.rerender(<PlProgressBox value={90} showValue />);

      await expect.element(screen.getByText('90%')).toBeInTheDocument();
    });
  });

  describe('the plates', () => {
    it('draws four of them by default', async () => {
      const screen = await render(<PlProgressBox value={40} />);

      expect(fillsOf(screen.getByRole('progressbar').element())).toHaveLength(4);
    });

    it('draws as many as it was asked for', async () => {
      const screen = await render(<PlProgressBox value={40} count={7} />);

      expect(fillsOf(screen.getByRole('progressbar').element())).toHaveLength(7);
    });

    it('never draws none', async () => {
      const screen = await render(<PlProgressBox value={40} count={0} />);

      expect(fillsOf(screen.getByRole('progressbar').element())).toHaveLength(1);
    });

    it('rounds a fractional count down to a whole one', async () => {
      const screen = await render(<PlProgressBox value={40} count={3.7} />);

      expect(fillsOf(screen.getByRole('progressbar').element())).toHaveLength(3);
    });

    it('fills in order, the leading one partially', async () => {
      // 30% of four plates is the first one full and the second three tenths of
      // the way across — which is the whole reason a plate is a track of its own.
      const screen = await render(<PlProgressBox value={30} count={4} />);
      const fills = fillsOf(screen.getByRole('progressbar').element());

      expect(fills[0].style.width).toBe('100%');
      expect(fills[1].style.width).toBe('20%');
      expect(fills[2].style.width).toBe('0%');
      expect(fills[3].style.width).toBe('0%');
    });

    it('fills every plate when it is done', async () => {
      const screen = await render(<PlProgressBox value={100} count={3} />);

      for (const fill of fillsOf(screen.getByRole('progressbar').element())) {
        expect(fill.style.width).toBe('100%');
      }
    });

    it('cycles while indeterminate, each plate held back by its own index', async () => {
      const screen = await render(<PlProgressBox label="Working" count={3} />);
      const fills = fillsOf(screen.getByRole('progressbar').element());

      for (const [index, fill] of fills.entries()) {
        expect(fill).toHaveClass('plass-plate-wave');
        expect(fill.style.getPropertyValue('--p-i')).toBe(String(index));
      }
    });

    it('stops cycling once it has a value', async () => {
      const screen = await render(<PlProgressBox label="Working" />);

      expect(fillsOf(screen.getByRole('progressbar').element())[0]).toHaveClass('plass-plate-wave');

      await screen.rerender(<PlProgressBox label="Working" value={40} />);

      expect(fillsOf(screen.getByRole('progressbar').element())[0]).not.toHaveClass(
        'plass-plate-wave'
      );
    });
  });
});
