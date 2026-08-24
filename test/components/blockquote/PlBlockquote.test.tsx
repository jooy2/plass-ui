import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlBlockquote } from 'plass-ui';

describe('PlBlockquote', () => {
  describe('the markup', () => {
    it('renders a blockquote', async () => {
      await render(<PlBlockquote className="quote-under-test">Simplicity is hard.</PlBlockquote>);

      expect(document.querySelector('.quote-under-test blockquote')).not.toBeNull();
    });

    it('wraps it in a plain div when nobody is credited', async () => {
      await render(<PlBlockquote className="quote-under-test">Simplicity is hard.</PlBlockquote>);

      expect(document.querySelector('div.quote-under-test')).not.toBeNull();
      expect(document.querySelector('.quote-under-test figcaption')).toBeNull();
    });

    it('wraps it in a figure with a caption when somebody is', async () => {
      await render(
        <PlBlockquote className="quote-under-test" author="Ada Lovelace">
          Simplicity is hard.
        </PlBlockquote>
      );

      expect(document.querySelector('figure.quote-under-test')).not.toBeNull();
      expect(document.querySelector('.quote-under-test figcaption')).not.toBeNull();
    });

    it('keeps the attribution outside the quote', async () => {
      await render(
        <PlBlockquote className="quote-under-test" author="Ada Lovelace">
          Simplicity is hard.
        </PlBlockquote>
      );

      expect(document.querySelector('.quote-under-test blockquote figcaption')).toBeNull();
    });

    it('renders the source inside a cite', async () => {
      await render(
        <PlBlockquote className="quote-under-test" source="Notes on the Analytical Engine">
          Simplicity is hard.
        </PlBlockquote>
      );

      expect(document.querySelector('.quote-under-test cite')?.textContent).toBe(
        'Notes on the Analytical Engine'
      );
    });

    it('puts `cite` on the blockquote itself', async () => {
      await render(
        <PlBlockquote className="quote-under-test" cite="https://example.com/notes">
          Simplicity is hard.
        </PlBlockquote>
      );

      expect(document.querySelector('.quote-under-test blockquote')).toHaveAttribute(
        'cite',
        'https://example.com/notes'
      );
    });
  });

  describe('rendering', () => {
    it('renders what was said', async () => {
      const screen = await render(<PlBlockquote>Simplicity is hard.</PlBlockquote>);

      await expect.element(screen.getByText('Simplicity is hard.')).toBeInTheDocument();
    });

    it('reflects a changed quote on re-render', async () => {
      const screen = await render(<PlBlockquote>Before</PlBlockquote>);

      await screen.rerender(<PlBlockquote>After</PlBlockquote>);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('draws the quotation mark by default', async () => {
      await render(<PlBlockquote className="quote-under-test">Said.</PlBlockquote>);

      expect(document.querySelector('.quote-under-test svg')).not.toBeNull();
    });

    it('draws nothing when `icon` is false', async () => {
      await render(
        <PlBlockquote className="quote-under-test" icon={false}>
          Said.
        </PlBlockquote>
      );

      expect(document.querySelector('.quote-under-test svg')).toBeNull();
    });

    it('takes a mark of its own', async () => {
      const screen = await render(<PlBlockquote icon={<span>❝</span>}>Said.</PlBlockquote>);

      await expect.element(screen.getByText('❝')).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      await render(<PlBlockquote className="my-own-class">Said.</PlBlockquote>);

      expect(document.querySelector('.my-own-class')).not.toBeNull();
    });

    it('forwards unknown props to the wrapper', async () => {
      const screen = await render(<PlBlockquote data-testid="quote">Said.</PlBlockquote>);

      expect(screen.getByTestId('quote').element()).toBeInTheDocument();
    });
  });
});
