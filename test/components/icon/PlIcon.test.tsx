import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlIcon } from 'plass-ui';

/** Stands in for whatever an icon set hands back. */
function Star() {
  return (
    <svg viewBox="0 0 16 16" data-testid="glyph">
      <path d="M8 1.5 10 6l4.5.5-3.4 3 1 4.5L8 11.7 3.9 14l1-4.5-3.4-3L6 6Z" />
    </svg>
  );
}

describe('PlIcon', () => {
  describe('rendering', () => {
    it('renders the glyph it is given', async () => {
      const screen = await render(<PlIcon icon={<Star />} />);

      await expect.element(screen.getByTestId('glyph')).toBeInTheDocument();
    });

    it('takes a character as readily as an element', async () => {
      const screen = await render(<PlIcon icon="★" label="Favourite" />);

      await expect.element(screen.getByRole('img', { name: 'Favourite' })).toHaveTextContent('★');
    });

    it('reflects a changed glyph on re-render', async () => {
      const screen = await render(<PlIcon icon="★" label="Favourite" />);

      await screen.rerender(<PlIcon icon="☆" label="Favourite" />);

      await expect.element(screen.getByRole('img', { name: 'Favourite' })).toHaveTextContent('☆');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<PlIcon icon="★" label="Star" className="my-own-class" />);

      expect(screen.getByRole('img').element()).toHaveClass('my-own-class');
    });

    it('forwards unknown props to the element', async () => {
      const screen = await render(<PlIcon icon="★" label="Star" data-testid="mark" />);

      expect(screen.getByRole('img').element()).toHaveAttribute('data-testid', 'mark');
    });
  });

  describe('the accessible name', () => {
    it('is hidden from the accessibility tree without a label', async () => {
      const screen = await render(<PlIcon icon={<Star />} className="icon-under-test" />);

      const element = document.querySelector('.icon-under-test');

      expect(element).toHaveAttribute('aria-hidden', 'true');
      expect(element).not.toHaveAttribute('role');
      expect(screen.getByRole('img').query()).toBeNull();
    });

    it('becomes a named image with one', async () => {
      const screen = await render(<PlIcon icon={<Star />} label="Favourite" />);

      await expect.element(screen.getByRole('img', { name: 'Favourite' })).toBeInTheDocument();
    });
  });

  describe('colour', () => {
    it('inherits the surrounding colour by default', async () => {
      const screen = await render(<PlIcon icon="★" label="Star" />);
      const element = screen.getByRole('img').element() as HTMLElement;

      expect(element.style.getPropertyValue('--p-accent')).toBe('');
    });

    it('takes the family it is given', async () => {
      const screen = await render(<PlIcon icon="★" label="Star" color="warning" />);
      const element = screen.getByRole('img').element() as HTMLElement;

      expect(element.style.getPropertyValue('--p-accent')).toBe('var(--plass-warning-accent)');
    });
  });

  describe('size', () => {
    it('draws the box its size asks for', async () => {
      const screen = await render(<PlIcon icon="★" label="Star" size="xl" />);

      expect(screen.getByRole('img').element()).toHaveClass('size-7');
    });
  });
});
