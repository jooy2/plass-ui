import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlIconButton } from 'plass-ui';

/** Something to press. Any node will do; the component never looks inside it. */
const glyph = (
  <svg viewBox="0 0 24 24" data-testid="glyph">
    <path d="M12 5v14M5 12h14" />
  </svg>
);

describe('PlIconButton', () => {
  describe('the name', () => {
    it('is the label, because the glyph is not one', async () => {
      const screen = await render(<PlIconButton icon={glyph} label="Add an item" />);

      await expect.element(screen.getByRole('button', { name: 'Add an item' })).toBeInTheDocument();
    });

    it('draws the glyph it was given', async () => {
      const screen = await render(<PlIconButton icon={glyph} label="Add" />);

      expect(screen.getByTestId('glyph').element()).toBeInTheDocument();
    });
  });

  describe('the shape', () => {
    it('is a disc rather than the house fillet', async () => {
      const screen = await render(<PlIconButton icon={glyph} label="Add" />);

      expect(screen.getByRole('button').element()).toHaveStyle({ borderRadius: '9999px' });
    });

    it("lets the caller's own radius win", async () => {
      const screen = await render(
        <PlIconButton icon={glyph} label="Add" style={{ borderRadius: '4px' }} />
      );

      expect(screen.getByRole('button').element()).toHaveStyle({ borderRadius: '4px' });
    });

    it('is square, because a disc in a rectangle is an ellipse', async () => {
      const screen = await render(<PlIconButton icon={glyph} label="Add" size="md" />);
      const element = screen.getByRole('button').element();

      // PlButton's own icon-only path, reached by there being no children.
      expect(element).toHaveClass('h-10');
      expect(element).toHaveClass('w-10');
    });
  });

  describe('what it takes from PlButton', () => {
    it('presses', async () => {
      const press = vi.fn();
      const screen = await render(<PlIconButton icon={glyph} label="Add" onClick={press} />);

      await screen.getByRole('button').click();

      expect(press).toHaveBeenCalledOnce();
    });

    it('does not press while it is loading', async () => {
      const press = vi.fn();
      const screen = await render(
        <PlIconButton icon={glyph} label="Add" loading onClick={press} />
      );

      // `force` because the driver refuses to click an `aria-disabled` element;
      // the point of the test is that PlButton's own handler is what blocks it.
      await screen.getByRole('button').click({ force: true });

      expect(press).not.toHaveBeenCalled();
    });

    it('swaps the glyph for a spinner while it is loading', async () => {
      const screen = await render(<PlIconButton icon={glyph} label="Add" loading />);

      expect(screen.getByTestId('glyph').query()).toBeNull();
      expect(screen.getByRole('button').element()).toHaveAttribute('aria-busy', 'true');
    });

    it('is unavailable when it is disabled', async () => {
      const screen = await render(<PlIconButton icon={glyph} label="Add" disabled />);

      expect(screen.getByRole('button').element()).toBeDisabled();
    });

    it('takes the variants and colours the button takes', async () => {
      const screen = await render(
        <PlIconButton icon={glyph} label="Add" variant="ghost" color="danger" />
      );

      const element = screen.getByRole('button').element() as HTMLElement;

      expect(element.style.getPropertyValue('--p-accent')).toBe('var(--plass-danger-accent)');
      expect(element).toHaveClass('bg-transparent');
    });

    it('renders as whatever it was told to', async () => {
      await render(
        <PlIconButton
          icon={glyph}
          label="Add"
          className="disc-under-test"
          render={<a href="#x" />}
        />
      );

      expect(document.querySelector('.disc-under-test')?.tagName).toBe('A');
    });
  });
});
