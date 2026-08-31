/**
 * Nothing here measures the box, and that is on purpose: no component test
 * loads the stylesheet, so every element in this run is zero by zero and an
 * assertion about a clipped pixel would pass without the clip. What is asserted
 * instead is the pair that can actually break — the content is still in the
 * accessibility tree, and the classes that take it off the screen are on the
 * element.
 */
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlVisuallyHidden } from 'plass-ui';

/** The element under test, by the class the test put on it. */
const box = (className: string) => document.querySelector(`.${className}`)!;

describe('PlVisuallyHidden', () => {
  describe('what a screen reader gets', () => {
    it('leaves the content in the document', async () => {
      const screen = await render(<PlVisuallyHidden>Close</PlVisuallyHidden>);

      await expect.element(screen.getByText('Close')).toBeInTheDocument();
    });

    it('names a control that draws only a glyph', async () => {
      const screen = await render(
        <button type="button">
          <span aria-hidden="true">✕</span>
          <PlVisuallyHidden>Close</PlVisuallyHidden>
        </button>
      );

      await expect.element(screen.getByRole('button', { name: 'Close' })).toBeInTheDocument();
    });

    it('is not hidden with an attribute', async () => {
      await render(<PlVisuallyHidden className="hidden-under-test">Close</PlVisuallyHidden>);

      // `hidden` or `aria-hidden` here would take the text off the tree along
      // with the screen, which is the one thing this component exists to avoid.
      expect(box('hidden-under-test')).not.toHaveAttribute('hidden');
      expect(box('hidden-under-test')).not.toHaveAttribute('aria-hidden');
    });
  });

  describe('what a sighted reader gets', () => {
    it('clips the box rather than collapsing it', async () => {
      await render(<PlVisuallyHidden className="hidden-under-test">Close</PlVisuallyHidden>);

      expect(box('hidden-under-test')).toHaveClass('absolute');
      expect(box('hidden-under-test')).toHaveClass('size-px');
      expect(box('hidden-under-test')).toHaveClass('overflow-hidden');
    });
  });

  describe('focusable', () => {
    it('carries the classes that put it back in the flow', async () => {
      await render(
        <PlVisuallyHidden focusable className="skip-under-test">
          <a href="#main">Skip to content</a>
        </PlVisuallyHidden>
      );

      expect(box('skip-under-test')).toHaveClass('focus-within:static');
      expect(box('skip-under-test')).toHaveClass('focus-within:size-auto');
    });

    it('carries none of them by default', async () => {
      await render(
        <PlVisuallyHidden className="clipped-under-test">
          <a href="#main">Skip to content</a>
        </PlVisuallyHidden>
      );

      expect(box('clipped-under-test')).not.toHaveClass('focus-within:static');
    });

    it('reveals for a child that takes the focus, not only for itself', async () => {
      await render(
        <PlVisuallyHidden focusable className="skip-under-test">
          <a href="#main">Skip to content</a>
        </PlVisuallyHidden>
      );

      const link = document.querySelector<HTMLAnchorElement>('.skip-under-test a')!;
      link.focus();

      // `:focus-within` and not `:focus` — the thing tabbed to is the link
      // inside the box, and a `:focus` rule would never match while it is.
      expect(box('skip-under-test').matches(':focus-within')).toBe(true);
      expect(box('skip-under-test').matches(':focus')).toBe(false);
    });
  });

  describe('the element', () => {
    it('is a span by default', async () => {
      await render(<PlVisuallyHidden className="hidden-under-test">Close</PlVisuallyHidden>);

      expect(box('hidden-under-test').tagName).toBe('SPAN');
    });

    it('renders whatever it was told to render instead', async () => {
      await render(
        <PlVisuallyHidden render={<h2 />} className="hidden-under-test">
          Section
        </PlVisuallyHidden>
      );

      expect(box('hidden-under-test').tagName).toBe('H2');
    });

    it('keeps a caller-supplied class alongside its own', async () => {
      await render(<PlVisuallyHidden className="my-own-class">Close</PlVisuallyHidden>);

      expect(box('my-own-class')).toHaveClass('absolute');
    });

    it('passes native attributes through', async () => {
      await render(
        <PlVisuallyHidden id="live-status" aria-live="polite">
          Saved
        </PlVisuallyHidden>
      );

      expect(document.getElementById('live-status')).toHaveAttribute('aria-live', 'polite');
    });
  });
});
