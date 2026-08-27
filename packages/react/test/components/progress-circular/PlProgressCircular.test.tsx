import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlProgressCircular } from 'plass-ui';

/** The arc, which is the second circle in the ring's `<svg>`. */
function arcOf(element: Element): SVGCircleElement {
  return element.querySelectorAll('circle')[1] as SVGCircleElement;
}

describe('PlProgressCircular', () => {
  describe('rendering', () => {
    it('renders a progressbar', async () => {
      const screen = await render(<PlProgressCircular value={40} />);

      await expect.element(screen.getByRole('progressbar')).toBeInTheDocument();
    });

    it('carries the value and the range', async () => {
      const screen = await render(<PlProgressCircular value={3} min={0} max={4} />);
      const ring = screen.getByRole('progressbar').element();

      expect(ring).toHaveAttribute('aria-valuenow', '3');
      expect(ring).toHaveAttribute('aria-valuemin', '0');
      expect(ring).toHaveAttribute('aria-valuemax', '4');
    });

    it('reports no value at all while indeterminate', async () => {
      const screen = await render(<PlProgressCircular label="Loading" />);

      expect(screen.getByRole('progressbar').element()).not.toHaveAttribute('aria-valuenow');
    });

    it('renders the label and the value beside the ring', async () => {
      const screen = await render(<PlProgressCircular value={40} label="Loading" showValue />);

      await expect.element(screen.getByText('Loading')).toBeInTheDocument();
      await expect.element(screen.getByText('40%')).toBeInTheDocument();
    });

    it('shows the value as a percentage of the range, not of 100', async () => {
      const screen = await render(<PlProgressCircular value={3} min={0} max={4} showValue />);

      await expect.element(screen.getByText('75%')).toBeInTheDocument();
    });

    it('keeps the svg out of the accessibility tree', async () => {
      const screen = await render(<PlProgressCircular value={40} />);

      expect(screen.getByRole('progressbar').element().querySelector('svg')).toHaveAttribute(
        'aria-hidden',
        'true'
      );
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<PlProgressCircular value={40} className="my-own-class" />);

      expect(screen.getByRole('progressbar').element()).toHaveClass('my-own-class');
    });

    it('reflects a changed value on re-render', async () => {
      const screen = await render(<PlProgressCircular value={40} showValue />);

      await expect.element(screen.getByText('40%')).toBeInTheDocument();

      await screen.rerender(<PlProgressCircular value={90} showValue />);

      await expect.element(screen.getByText('90%')).toBeInTheDocument();
    });
  });

  describe('the ring', () => {
    it('grows with the size', async () => {
      const screen = await render(<PlProgressCircular value={40} size="xs" />);
      const small = screen.getByRole('progressbar').element().querySelector('svg');

      expect(small).toHaveAttribute('width', '14');

      await screen.rerender(<PlProgressCircular value={40} size="xl" />);

      expect(screen.getByRole('progressbar').element().querySelector('svg')).toHaveAttribute(
        'width',
        '32'
      );
    });

    it('closes the gap as the value climbs', async () => {
      const screen = await render(<PlProgressCircular value={25} />);
      const quarter = Number(
        arcOf(screen.getByRole('progressbar').element()).getAttribute('stroke-dashoffset')
      );

      await screen.rerender(<PlProgressCircular value={75} />);

      const most = Number(
        arcOf(screen.getByRole('progressbar').element()).getAttribute('stroke-dashoffset')
      );

      expect(most).toBeLessThan(quarter);
    });

    it('leaves no gap at all when it is full', async () => {
      const screen = await render(<PlProgressCircular value={100} />);

      expect(
        arcOf(screen.getByRole('progressbar').element()).getAttribute('stroke-dashoffset')
      ).toBe('0');
    });

    it('starts the arc at twelve o’clock rather than at three', async () => {
      const screen = await render(<PlProgressCircular value={40} size="md" />);

      expect(arcOf(screen.getByRole('progressbar').element()).getAttribute('transform')).toBe(
        'rotate(-90 10 10)'
      );
    });

    it('turns while indeterminate and holds still when it has a value', async () => {
      const screen = await render(<PlProgressCircular label="Loading" />);

      expect(screen.getByRole('progressbar').element().querySelector('svg')).toHaveClass(
        'plass-ring-spin'
      );

      await screen.rerender(<PlProgressCircular label="Loading" value={40} />);

      expect(screen.getByRole('progressbar').element().querySelector('svg')).not.toHaveClass(
        'plass-ring-spin'
      );
    });

    it('strokes the arc with the family gradient rather than a flat colour', async () => {
      const screen = await render(<PlProgressCircular value={40} />);
      const ring = screen.getByRole('progressbar').element();
      const gradient = ring.querySelector('linearGradient');

      expect(gradient).not.toBeNull();
      expect(arcOf(ring).getAttribute('stroke')).toBe(`url(#${gradient?.id})`);
    });

    it('gives two rings on one page two different gradient ids', async () => {
      const screen = await render(
        <div>
          <PlProgressCircular value={40} />
          <PlProgressCircular value={80} />
        </div>
      );

      const ids = [...screen.container.querySelectorAll('linearGradient')].map((node) => node.id);

      expect(new Set(ids).size).toBe(2);
    });
  });
});
