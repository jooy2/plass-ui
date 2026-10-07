import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlProgressCircular, PlassProvider } from 'plass-ui';

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

    it('reports Infinity as full, the way the ring draws it', async () => {
      const screen = await render(<PlProgressCircular value={Infinity} showValue />);
      const ring = screen.getByRole('progressbar').element();

      expect(ring).toHaveAttribute('aria-valuenow', '100');
      expect(ring).toHaveAttribute('data-complete');
      await expect.element(screen.getByText('100%')).toBeInTheDocument();
    });

    it('renders the label and the value beside the ring', async () => {
      const screen = await render(<PlProgressCircular value={40} label="Loading" showValue />);

      await expect.element(screen.getByText('Loading')).toBeInTheDocument();
      await expect.element(screen.getByText('40%')).toBeInTheDocument();
    });

    it('writes the value in the locale of the provider', async () => {
      const percent = new Intl.NumberFormat('de-DE', { style: 'percent' }).format(0.75);
      const screen = await render(
        <PlassProvider locale="de-DE">
          <PlProgressCircular value={3} min={0} max={4} showValue />
        </PlassProvider>
      );
      const bar = screen.getByRole('progressbar');

      expect(percent).not.toBe('75%');
      await expect.element(bar).toHaveAttribute('aria-valuetext', percent);
      expect(bar.element().textContent).toContain(percent);
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

  describe('naming', () => {
    it('is named by its label', async () => {
      const screen = await render(<PlProgressCircular value={40} label="Syncing" />);

      await expect
        .element(screen.getByRole('progressbar', { name: 'Syncing', exact: true }))
        .toBeInTheDocument();
    });

    it("is named by an `aria-label` in a visible label's place", async () => {
      const screen = await render(
        <PlProgressCircular value={40} label="Syncing" aria-label="Syncing your photos" />
      );

      await expect
        .element(screen.getByRole('progressbar', { name: 'Syncing your photos', exact: true }))
        .toBeInTheDocument();
    });

    it("points at the caller's element with an `aria-labelledby`, over a label and an `aria-label`", async () => {
      const screen = await render(
        <>
          <span id="circular-heading">Photo library</span>
          <PlProgressCircular
            value={40}
            label="Syncing"
            aria-label="Syncing your photos"
            aria-labelledby="circular-heading"
          />
        </>
      );

      const bar = screen.getByRole('progressbar', { name: 'Photo library', exact: true });

      await expect.element(bar).toHaveAttribute('aria-labelledby', 'circular-heading');
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

    it('keeps the ladder’s diameter and stroke at every size', async () => {
      const ladder = [
        ['xs', 14, 1.5],
        ['sm', 16, 1.75],
        ['md', 20, 2],
        ['lg', 26, 2.5],
        ['xl', 32, 3]
      ] as const;
      const screen = await render(<PlProgressCircular value={40} />);

      for (const [size, diameter, stroke] of ladder) {
        await screen.rerender(<PlProgressCircular value={40} size={size} />);

        const ring = screen.getByRole('progressbar').element();

        expect(ring.querySelector('svg')).toHaveAttribute('width', String(diameter));
        expect(ring.querySelector('svg')).toHaveAttribute('height', String(diameter));
        expect(arcOf(ring)).toHaveAttribute('stroke-width', String(stroke));
      }
    });

    it('draws the ring at diameter instead of the rung, and the stroke follows', async () => {
      const screen = await render(<PlProgressCircular value={40} size="sm" diameter={96} />);
      const ring = screen.getByRole('progressbar').element();
      const svg = ring.querySelector('svg');

      expect(svg).toHaveAttribute('width', '96');
      expect(svg).toHaveAttribute('height', '96');
      expect(svg).toHaveAttribute('viewBox', '0 0 96 96');

      // `xl`'s proportion, 3 in 32, carried on past the end of the ladder; and
      // the stroke straddles the path, so the radius is in by half of it.
      for (const circle of ring.querySelectorAll('circle')) {
        expect(circle).toHaveAttribute('stroke-width', '9');
        expect(circle).toHaveAttribute('r', '43.5');
      }

      expect(arcOf(ring)).toHaveAttribute('transform', 'rotate(-90 48 48)');
    });

    it('still takes the gap and the text size from size beside a diameter', async () => {
      const screen = await render(
        <PlProgressCircular value={40} size="xl" diameter={96} label="Loading" />
      );

      expect(screen.getByRole('progressbar').element()).toHaveClass('gap-3', 'text-[0.875rem]');

      await screen.rerender(
        <PlProgressCircular value={40} size="xs" diameter={96} label="Loading" />
      );

      expect(screen.getByRole('progressbar').element()).toHaveClass('gap-1', 'text-[0.625rem]');
      expect(screen.getByRole('progressbar').element().querySelector('svg')).toHaveAttribute(
        'width',
        '96'
      );
    });

    it('draws a diameter of 14 exactly as the xs ring', async () => {
      const screen = await render(<PlProgressCircular value={40} size="xs" />);
      const rung = arcOf(screen.getByRole('progressbar').element());
      const expected = [rung.getAttribute('r'), rung.getAttribute('stroke-width')];

      await screen.rerender(<PlProgressCircular value={40} size="xl" diameter={14} />);

      const arc = arcOf(screen.getByRole('progressbar').element());

      expect(expected).toEqual(['6.25', '1.5']);
      expect([arc.getAttribute('r'), arc.getAttribute('stroke-width')]).toEqual(expected);
    });

    it('keeps the radius above zero on a ring smaller than the ladder', async () => {
      const screen = await render(<PlProgressCircular value={40} diameter={0.5} />);
      const ring = screen.getByRole('progressbar').element();

      expect(ring.querySelector('svg')).toHaveAttribute('width', '0.5');

      for (const circle of ring.querySelectorAll('circle')) {
        expect(circle).toHaveAttribute('stroke-width', String((0.5 * 1.5) / 14));
        expect(Number(circle.getAttribute('r'))).toBeGreaterThan(0);
      }
    });

    it('ignores a diameter that is not a finite number above zero', async () => {
      const screen = await render(<PlProgressCircular value={40} size="lg" diameter={0} />);

      for (const diameter of [0, -24, Number.NaN, Infinity]) {
        await screen.rerender(<PlProgressCircular value={40} size="lg" diameter={diameter} />);

        const ring = screen.getByRole('progressbar').element();

        expect(ring.querySelector('svg')).toHaveAttribute('width', '26');
        expect(arcOf(ring)).toHaveAttribute('stroke-width', '2.5');
      }
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
