import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlContainer } from 'plass-ui';

describe('PlContainer', () => {
  describe('maxWidth', () => {
    it('holds the content to nothing unless it is asked to', async () => {
      await render(<PlContainer className="page-under-test" />);

      const element = document.querySelector('.page-under-test');

      expect(element?.className).not.toMatch(/max-w-/);
    });

    it('takes the step it was named', async () => {
      await render(<PlContainer className="page-under-test" maxWidth="lg" />);

      expect(document.querySelector('.page-under-test')).toHaveClass('max-w-[64rem]');
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

      const element = document.querySelector('.page-under-test');

      expect(element).toHaveClass('max-w-[48rem]');
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
