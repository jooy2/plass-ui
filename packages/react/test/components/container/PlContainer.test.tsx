import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlContainer } from 'plass-ui';

describe('PlContainer', () => {
  describe('maxWidth', () => {
    it('holds the content to nothing unless it is asked to', async () => {
      await render(<PlContainer className="page-under-test" />);

      const element = document.querySelector('.page-under-test') as HTMLElement;

      // Neither the class nor the slot: a container with no measure has nothing
      // to carry, and the stylesheet's own fallback is `none`.
      expect(element).not.toHaveClass('plass-container');
      expect(element.getAttribute('style')).toBeNull();
    });

    it('takes any length, which is how a measure in characters gets written', async () => {
      const screen = await render(<PlContainer className="page-under-test" maxWidth="72ch" />);

      const element = document.querySelector('.page-under-test') as HTMLElement;

      // The rung ladder is `rem` and a paragraph's measure is characters. No
      // ladder can spell `72ch`, which is exactly why the prop takes a length.
      expect(element.style.getPropertyValue('--p-maxw-xs')).toBe('72ch');

      await screen.rerender(<PlContainer className="page-under-test" maxWidth={640} />);

      expect(element.style.getPropertyValue('--p-maxw-xs')).toBe('640px');
    });

    it('changes measure with the window, and resolves it in CSS', async () => {
      await render(<PlContainer className="page-under-test" maxWidth={{ xs: 'none', md: 'lg' }} />);

      const element = document.querySelector('.page-under-test') as HTMLElement;

      // One slot per rung the caller named, and the cascade in the stylesheet
      // fills the rest — so a window being dragged costs no re-render and a
      // server's first paint is already right at every width.
      expect(element.style.getPropertyValue('--p-maxw-xs')).toBe('none');
      expect(element.style.getPropertyValue('--p-maxw-md')).toBe('64rem');
      expect(element.style.getPropertyValue('--p-maxw-sm')).toBe('');
    });

    it('takes the step it was named', async () => {
      await render(<PlContainer className="page-under-test" maxWidth="lg" />);

      const element = document.querySelector('.page-under-test') as HTMLElement;

      expect(element).toHaveClass('plass-container');
      expect(element.style.getPropertyValue('--p-maxw-xs')).toBe('64rem');
    });
  });

  describe('centered', () => {
    it('centres what is left over by default', async () => {
      await render(<PlContainer className="page-under-test" maxWidth="sm" />);

      expect(document.querySelector('.page-under-test')).toHaveClass('mx-auto');
    });

    it('leaves it against the start when it is turned off', async () => {
      await render(<PlContainer className="page-under-test" maxWidth="sm" centered={false} />);

      expect(document.querySelector('.page-under-test')).not.toHaveClass('mx-auto');
    });
  });

  describe('padded', () => {
    it('pads on the sheet track', async () => {
      await render(<PlContainer className="page-under-test" />);

      expect(document.querySelector('.page-under-test')).toHaveClass('px-5');
    });

    it('takes the compact track when it is asked to', async () => {
      await render(<PlContainer className="page-under-test" density="compact" />);

      expect(document.querySelector('.page-under-test')).toHaveClass('px-3.5');
    });

    it('gives the gutter up entirely when it is turned off', async () => {
      await render(<PlContainer className="page-under-test" padded={false} />);

      expect(document.querySelector('.page-under-test')?.className).not.toMatch(/\bpx-/);
    });

    it('keeps the measure and the centring without it', async () => {
      await render(<PlContainer className="page-under-test" maxWidth="md" padded={false} />);

      const element = document.querySelector('.page-under-test') as HTMLElement;

      expect(element.style.getPropertyValue('--p-maxw-xs')).toBe('48rem');
      expect(element).toHaveClass('mx-auto');
    });
  });

  describe('the element', () => {
    it('is a div', async () => {
      await render(<PlContainer className="page-under-test" />);

      expect(document.querySelector('.page-under-test')?.tagName).toBe('DIV');
    });

    it('renders as whatever it was told to', async () => {
      await render(<PlContainer className="page-under-test" render={<main />} />);

      expect(document.querySelector('.page-under-test')?.tagName).toBe('MAIN');
    });

    it('renders what it was given', async () => {
      const screen = await render(
        <PlContainer>
          <p>The page</p>
        </PlContainer>
      );

      await expect.element(screen.getByText('The page')).toBeInTheDocument();
    });

    it('forwards unknown props to the box', async () => {
      const screen = await render(<PlContainer data-testid="page" />);

      expect(screen.getByTestId('page').element()).toBeInTheDocument();
    });
  });
});
