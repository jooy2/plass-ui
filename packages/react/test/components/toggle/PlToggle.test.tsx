import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlButtonGroup, PlToggle } from 'plass-ui';

describe('PlToggle', () => {
  describe('the control', () => {
    it('renders a button that reports whether it is pressed', async () => {
      const screen = await render(<PlToggle>Bold</PlToggle>);

      await expect
        .element(screen.getByRole('button', { name: 'Bold' }))
        .toHaveAttribute('aria-pressed', 'false');
    });

    it('goes on when it is pressed, and off again', async () => {
      const onPressedChange = vi.fn();

      const screen = await render(<PlToggle onPressedChange={onPressedChange}>Bold</PlToggle>);

      const toggle = screen.getByRole('button', { name: 'Bold' });

      await toggle.click();

      expect(onPressedChange).toHaveBeenLastCalledWith(true);
      await expect.element(toggle).toHaveAttribute('aria-pressed', 'true');

      await toggle.click();

      expect(onPressedChange).toHaveBeenLastCalledWith(false);
      await expect.element(toggle).toHaveAttribute('aria-pressed', 'false');
    });

    it('starts on when it is told to', async () => {
      const screen = await render(<PlToggle defaultPressed>Bold</PlToggle>);

      await expect.element(screen.getByRole('button')).toHaveAttribute('aria-pressed', 'true');
    });

    it('answers with what a controlled toggle is given', async () => {
      const onPressedChange = vi.fn();

      const screen = await render(
        <PlToggle pressed={false} onPressedChange={onPressedChange}>
          Bold
        </PlToggle>
      );

      await screen.getByRole('button').click();

      expect(onPressedChange).toHaveBeenCalledWith(true);
      await expect.element(screen.getByRole('button')).toHaveAttribute('aria-pressed', 'false');
    });

    it('does nothing while it is disabled', async () => {
      const onPressedChange = vi.fn();

      const screen = await render(
        <PlToggle disabled onPressedChange={onPressedChange}>
          Bold
        </PlToggle>
      );

      const toggle = screen.getByRole('button').element() as HTMLButtonElement;

      expect(toggle).toBeDisabled();
      toggle.click();
      expect(onPressedChange).not.toHaveBeenCalled();
    });
  });

  describe('the surface', () => {
    it('is neutral while it is off, because off is a state that is false', async () => {
      const screen = await render(<PlToggle>Bold</PlToggle>);

      expect(screen.getByRole('button').element()).toHaveClass('text-(--plass-muted-fg)');
    });

    it('takes the family only once it is on', async () => {
      const screen = await render(<PlToggle defaultPressed>Bold</PlToggle>);

      expect(screen.getByRole('button').element()).toHaveClass('text-(--p-accent)');
    });

    it('never reaches for the family while it is off, under the pointer either', async () => {
      // The rule a two-state control lives by, and the one a hover can undo
      // without anybody noticing: `--p-soft` is the family's wash and it is
      // what an `on` toggle is painted with, so an `off` toggle that reached
      // for it under the pointer drew itself as an on one — with the ink as
      // the only thing still carrying the state.
      //
      // Asserted on the classes rather than on a colour because the suite runs
      // with no stylesheet, and because `:hover` has no computed style to read
      // until something is actually hovering. What holds either way is that the
      // family never appears in the off state's declarations at all.
      //
      // Five toggles at once rather than a rerender: a toggle cannot be made to
      // change what it started as, controlled or not.
      const screen = await render(
        <div>
          <PlToggle variant="solid">Solid off</PlToggle>
          <PlToggle variant="glass">Glass off</PlToggle>
          <PlToggle variant="ghost">Ghost off</PlToggle>
          <PlToggle variant="glass" defaultPressed>
            Glass on
          </PlToggle>
          <PlToggle variant="ghost" defaultPressed>
            Ghost on
          </PlToggle>
        </div>
      );

      for (const name of ['Solid off', 'Glass off', 'Ghost off']) {
        expect(screen.getByRole('button', { name }).element().className).not.toMatch(/--p-soft/);
      }

      // And the other half, so neutralising both states is not a way to pass:
      // on is still the family asserting itself.
      for (const name of ['Glass on', 'Ghost on']) {
        expect(screen.getByRole('button', { name }).element().className).toMatch(/bg-\(--p-soft\)/);
      }
    });

    it('fills with the gradient on solid, and wears the on-fill ink', async () => {
      const screen = await render(
        <PlToggle variant="solid" defaultPressed>
          Bold
        </PlToggle>
      );

      const toggle = screen.getByRole('button').element();

      expect(toggle).toHaveClass('[background-image:var(--p-fill)]');
      expect(toggle).toHaveClass('text-(--p-on-solid)');
    });

    it('keeps its elevation when it goes on — only the colour moves', async () => {
      const screen = await render(
        <PlToggle variant="solid" elevation={2}>
          Bold
        </PlToggle>
      );

      const toggle = screen.getByRole('button');
      const element = toggle.element() as HTMLElement;

      expect(element.style.getPropertyValue('--p-elev')).toBe('var(--plass-shadow-2)');
      expect(element.className).toContain('[box-shadow:var(--p-elev),var(--plass-gloss-glass)]');

      await toggle.click();

      // The shadow the pressed state reads is the same slot, not a level up:
      // "on" is a fact about the thing beside the toggle, not about how far the
      // key is off the page.
      expect(element.style.getPropertyValue('--p-elev')).toBe('var(--plass-shadow-2)');
      expect(element.className).toContain('[box-shadow:var(--p-elev),var(--p-lift)]');
    });

    it('carries the interaction light unless it is disabled', async () => {
      const screen = await render(<PlToggle>Bold</PlToggle>);

      expect(screen.getByRole('button').element()).toHaveClass('plass-glow');

      await screen.rerender(<PlToggle disabled>Bold</PlToggle>);

      expect(screen.getByRole('button').element()).not.toHaveClass('plass-glow');
    });

    it('goes square around an icon with no label', async () => {
      const screen = await render(<PlToggle aria-label="Bold" startIcon={<svg />} />);

      const toggle = screen.getByRole('button', { name: 'Bold' }).element();

      expect(toggle).toHaveClass('w-10');
      expect(toggle).toHaveClass('px-0');
    });

    it('pads against its label when it has one', async () => {
      const screen = await render(<PlToggle>Bold</PlToggle>);

      expect(screen.getByRole('button').element()).toHaveClass('px-4');
    });

    it('stretches when it is told to', async () => {
      const screen = await render(<PlToggle fullWidth>Bold</PlToggle>);

      expect(screen.getByRole('button').element()).toHaveClass('w-full');
    });
  });

  describe('inside a group', () => {
    it('takes the axes a PlButtonGroup sets', async () => {
      const screen = await render(
        <PlButtonGroup size="sm" color="danger">
          <PlToggle>Bold</PlToggle>
        </PlButtonGroup>
      );

      const toggle = screen.getByRole('button').element() as HTMLElement;

      expect(toggle).toHaveClass('h-8');
      expect(toggle.style.getPropertyValue('--p-accent')).toBe('var(--plass-danger-accent)');
    });

    it('and its own prop still wins', async () => {
      const screen = await render(
        <PlButtonGroup size="sm">
          <PlToggle size="lg">Bold</PlToggle>
        </PlButtonGroup>
      );

      expect(screen.getByRole('button').element()).toHaveClass('h-12');
    });
  });
});
