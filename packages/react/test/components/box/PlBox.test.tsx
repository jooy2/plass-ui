import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlBox } from 'plass-ui';

describe('PlBox', () => {
  describe('the sheet', () => {
    it('renders its children on a div', async () => {
      const screen = await render(<PlBox>Grouped</PlBox>);

      await expect.element(screen.getByText('Grouped')).toBeInTheDocument();
      expect(screen.getByText('Grouped').element().tagName).toBe('DIV');
    });

    it('is a glass sheet with a hairline round it by default', async () => {
      await render(<PlBox className="box-under-test">Grouped</PlBox>);
      const element = document.querySelector('.box-under-test');

      expect(element).toHaveClass('border');
      expect(element).toHaveClass('bg-(--plass-glass)');
    });

    it('is the densest glass on solid, and no sheet at all on ghost', async () => {
      const screen = await render(
        <PlBox variant="solid" className="box-under-test">
          Grouped
        </PlBox>
      );

      expect(document.querySelector('.box-under-test')).toHaveClass('bg-(--plass-glass-press)');

      await screen.rerender(
        <PlBox variant="ghost" className="box-under-test">
          Grouped
        </PlBox>
      );

      expect(document.querySelector('.box-under-test')).toHaveClass('bg-transparent');
      expect(document.querySelector('.box-under-test')).not.toHaveClass('border');
    });

    it('is never dyed, whatever colour it is given', async () => {
      await render(
        <PlBox color="danger" className="box-under-test">
          Grouped
        </PlBox>
      );

      const element = document.querySelector<HTMLElement>('.box-under-test');

      // A container's slot set carries no `--p-fill`: what a box holds arrives
      // with its own colours, and the family reaches the hairline and stops.
      expect(element?.style.getPropertyValue('--p-fill')).toBe('');
      expect(element?.style.getPropertyValue('--p-line')).toBe('var(--plass-danger-line)');
    });

    it('lies flat until it is asked to float', async () => {
      const screen = await render(<PlBox className="box-under-test">Grouped</PlBox>);

      expect(
        document.querySelector<HTMLElement>('.box-under-test')?.style.getPropertyValue('--p-elev')
      ).toBe('var(--plass-shadow-0)');

      await screen.rerender(
        <PlBox elevation={2} className="box-under-test">
          Grouped
        </PlBox>
      );

      expect(
        document.querySelector<HTMLElement>('.box-under-test')?.style.getPropertyValue('--p-elev')
      ).toBe('var(--plass-shadow-2)');
    });
  });

  describe('size and padding', () => {
    it('takes its radius and its padding off the size ladder', async () => {
      await render(
        <PlBox size="lg" className="box-under-test">
          Grouped
        </PlBox>
      );
      const element = document.querySelector('.box-under-test');

      // `size` on a box is the size of the *sheet* — its radius and its padding
      // — and never a height or a type scale, because the children bring their
      // own typography.
      expect(element).toHaveClass('rounded-(--plass-radius-lg)');
      expect(element).toHaveClass('px-6');
      expect(element).toHaveClass('py-6');
    });

    it('packs tighter on compact', async () => {
      await render(
        <PlBox density="compact" className="box-under-test">
          Grouped
        </PlBox>
      );

      expect(document.querySelector('.box-under-test')).toHaveClass('px-3.5');
    });

    it('goes full bleed when the padding is turned off', async () => {
      await render(
        <PlBox padded={false} className="box-under-test">
          Grouped
        </PlBox>
      );
      const element = document.querySelector('.box-under-test');

      expect(element).not.toHaveClass('px-5');
      expect(element).not.toHaveClass('py-5');
    });
  });

  describe('the element', () => {
    it('renders something else when it is told to', async () => {
      const screen = await render(<PlBox render={<section />}>Grouped</PlBox>);

      expect(screen.getByText('Grouped').element().tagName).toBe('SECTION');
    });

    it('keeps caller-supplied class names alongside its own, and forwards the rest', async () => {
      const screen = await render(
        <PlBox className="my-own-class" id="panel" data-testid="box">
          Grouped
        </PlBox>
      );

      expect(screen.getByTestId('box').element()).toHaveClass('my-own-class');
      expect(screen.getByTestId('box').element()).toHaveClass('block');
      expect(screen.getByTestId('box').element()).toHaveAttribute('id', 'panel');
    });
  });
});
