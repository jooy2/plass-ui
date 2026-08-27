import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlButton, PlToolbar } from 'plass-ui';

describe('PlToolbar', () => {
  describe('the row', () => {
    it('lays out its three slots in order', async () => {
      const screen = await render(
        <PlToolbar data-testid="bar" start={<span>Logo</span>} end={<PlButton>Save</PlButton>}>
          <span>Middle</span>
        </PlToolbar>
      );

      const text = screen.getByTestId('bar').element().textContent;

      expect(text).toBe('LogoMiddleSave');
    });

    it('keeps the ends apart even with nothing in the middle', async () => {
      const screen = await render(
        <PlToolbar data-testid="bar" start={<span>Logo</span>} end={<span>Save</span>} />
      );

      // `flex-1` even when empty, or the two ends collapse together in the
      // middle of the bar.
      const middle = screen.getByTestId('bar').element().children[1];

      expect(middle).toHaveClass('flex-1');
    });

    it('takes no height of its own', async () => {
      const screen = await render(
        <PlToolbar data-testid="bar">
          <span>Middle</span>
        </PlToolbar>
      );

      // A toolbar is as tall as the controls in it plus its padding. Nothing
      // here states a height.
      const element = screen.getByTestId('bar').element();

      expect(element.className).not.toMatch(/\bh-\d/);
      expect(element).toHaveClass('py-5');
    });

    it('packs tighter on compact without moving the type scale', async () => {
      const screen = await render(
        <PlToolbar data-testid="bar" density="compact">
          <span>Middle</span>
        </PlToolbar>
      );

      expect(screen.getByTestId('bar').element()).toHaveClass('px-3.5');
    });
  });

  describe('the sheet', () => {
    it('is never dyed, whatever colour it is given', async () => {
      const screen = await render(
        <PlToolbar data-testid="bar" color="danger">
          <span>Middle</span>
        </PlToolbar>
      );

      const element = screen.getByTestId('bar').element() as HTMLElement;

      // A toolbar holds other people's controls, and those arrive with colours
      // of their own.
      expect(element.style.getPropertyValue('--p-fill')).toBe('');
      expect(element.style.getPropertyValue('--p-line')).toBe('var(--plass-danger-line)');
    });

    it('is flat, even pinned', async () => {
      const screen = await render(
        <PlToolbar data-testid="bar" position="sticky">
          <span>Middle</span>
        </PlToolbar>
      );

      // A shadow under a header says "there is content beneath this", and that
      // is only true once the page has been scrolled.
      expect(
        (screen.getByTestId('bar').element() as HTMLElement).style.getPropertyValue('--p-elev')
      ).toBe('var(--plass-shadow-0)');
    });
  });

  describe('position', () => {
    it('is a sheet with corners in the flow and loses them when it is pinned', async () => {
      const screen = await render(
        <PlToolbar data-testid="bar">
          <span>Middle</span>
        </PlToolbar>
      );

      expect(screen.getByTestId('bar').element()).toHaveClass('rounded-(--plass-radius-md)');

      await screen.rerender(
        <PlToolbar data-testid="bar" position="fixed">
          <span>Middle</span>
        </PlToolbar>
      );

      const element = screen.getByTestId('bar').element();

      // A rounded corner against the edge of the screen is a gap with nothing
      // behind it.
      expect(element).not.toHaveClass('rounded-(--plass-radius-md)');
      expect(element).toHaveClass('fixed');
      expect(element).toHaveClass('top-0');
    });

    it('moves the rule to the edge that faces the content', async () => {
      const screen = await render(
        <PlToolbar data-testid="bar" divider>
          <span>Middle</span>
        </PlToolbar>
      );

      expect(screen.getByTestId('bar').element()).toHaveClass('border-b');

      await screen.rerender(
        <PlToolbar data-testid="bar" divider position="fixed" side="bottom">
          <span>Middle</span>
        </PlToolbar>
      );

      const element = screen.getByTestId('bar').element();

      expect(element).toHaveClass('border-t');
      expect(element).toHaveClass('bottom-0');
    });
  });

  describe('the element', () => {
    it('claims no toolbar role', async () => {
      const screen = await render(
        <PlToolbar data-testid="bar">
          <PlButton>Save</PlButton>
        </PlToolbar>
      );

      // That role is a promise about keyboard behaviour, and a bar that claims
      // it without implementing it is worse than one that never claimed
      // anything.
      expect(screen.getByTestId('bar').element()).not.toHaveAttribute('role');
    });

    it('renders a real header when it is told to', async () => {
      const screen = await render(
        <PlToolbar data-testid="bar" render={<header />}>
          <span>Middle</span>
        </PlToolbar>
      );

      expect(screen.getByTestId('bar').element().tagName).toBe('HEADER');
    });
  });
});
