import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAspectRatio } from 'plass-ui';

describe('PlAspectRatio', () => {
  describe('the proportion', () => {
    it('holds a square by default', async () => {
      await render(<PlAspectRatio className="box-under-test" />);

      // Serialised back out the way the browser stores it: a bare number is a
      // ratio against one.
      expect(document.querySelector<HTMLElement>('.box-under-test')?.style.aspectRatio).toBe(
        '1 / 1'
      );
    });

    it('passes a number straight to aspect-ratio', async () => {
      await render(<PlAspectRatio className="box-under-test" ratio={1.5} />);

      expect(document.querySelector<HTMLElement>('.box-under-test')?.style.aspectRatio).toBe(
        '1.5 / 1'
      );
    });

    it("passes CSS's own ratio syntax through untouched", async () => {
      await render(<PlAspectRatio className="box-under-test" ratio="16 / 9" />);

      expect(document.querySelector<HTMLElement>('.box-under-test')?.style.aspectRatio).toBe(
        '16 / 9'
      );
    });

    it("lets the caller's own style win", async () => {
      await render(
        <PlAspectRatio className="box-under-test" ratio={1} style={{ aspectRatio: '4 / 3' }} />
      );

      expect(document.querySelector<HTMLElement>('.box-under-test')?.style.aspectRatio).toBe(
        '4 / 3'
      );
    });
  });

  describe('the content', () => {
    it('renders what it was given', async () => {
      const screen = await render(
        <PlAspectRatio>
          <span>Held</span>
        </PlAspectRatio>
      );

      await expect.element(screen.getByText('Held')).toBeInTheDocument();
    });

    it('clips whatever overflows the proportion', async () => {
      await render(<PlAspectRatio className="box-under-test" />);

      expect(document.querySelector('.box-under-test')).toHaveClass('overflow-hidden');
    });
  });

  describe('fit', () => {
    it('covers by default', async () => {
      await render(<PlAspectRatio className="box-under-test" />);

      expect(document.querySelector('.box-under-test')).toHaveClass('[&>img]:object-cover');
    });

    it('contains when it is asked to', async () => {
      await render(<PlAspectRatio className="box-under-test" fit="contain" />);

      expect(document.querySelector('.box-under-test')).toHaveClass('[&>img]:object-contain');
    });
  });

  describe('rounded', () => {
    it('cuts no corners unless it is asked to', async () => {
      await render(<PlAspectRatio className="box-under-test" />);

      expect(document.querySelector('.box-under-test')).not.toHaveClass(
        'rounded-(--plass-radius-md)'
      );
    });

    it('takes the size step of the house ladder', async () => {
      await render(<PlAspectRatio className="box-under-test" rounded size="lg" />);

      expect(document.querySelector('.box-under-test')).toHaveClass('rounded-(--plass-radius-lg)');
    });
  });

  describe('the element', () => {
    it('is a div', async () => {
      await render(<PlAspectRatio className="box-under-test" />);

      expect(document.querySelector('.box-under-test')?.tagName).toBe('DIV');
    });

    it('renders as whatever it was told to', async () => {
      await render(<PlAspectRatio className="box-under-test" render={<figure />} />);

      expect(document.querySelector('.box-under-test')?.tagName).toBe('FIGURE');
    });

    it('forwards unknown props to the box', async () => {
      const screen = await render(<PlAspectRatio data-testid="frame" />);

      expect(screen.getByTestId('frame').element()).toBeInTheDocument();
    });
  });
});
