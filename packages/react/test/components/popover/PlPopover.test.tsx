import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlButton, PlPopover, PlPopoverClose } from 'plass-ui';

describe('PlPopover', () => {
  describe('opening and closing', () => {
    it('renders nothing until it is open', async () => {
      const screen = await render(
        <PlPopover trigger={<PlButton>Help</PlButton>} title="Rates">
          How the number is worked out.
        </PlPopover>
      );

      expect(screen.getByRole('dialog').query()).toBeNull();
    });

    it('opens from its trigger and names itself', async () => {
      const screen = await render(
        <PlPopover trigger={<PlButton>Help</PlButton>} title="Rates">
          How the number is worked out.
        </PlPopover>
      );

      await screen.getByRole('button', { name: 'Help' }).click();

      await expect.element(screen.getByRole('dialog', { name: 'Rates' })).toBeInTheDocument();
    });

    it('describes itself from the line under the title', async () => {
      const screen = await render(
        <PlPopover defaultOpen title="Rates" description="Updated hourly">
          How the number is worked out.
        </PlPopover>
      );

      await expect
        .element(screen.getByRole('dialog', { description: 'Updated hourly' }))
        .toBeInTheDocument();
    });

    it('closes on Escape', async () => {
      const screen = await render(
        <PlPopover defaultOpen title="Rates">
          How the number is worked out.
        </PlPopover>
      );

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();

      document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));

      await expect.poll(() => screen.getByRole('dialog').query()).toBeNull();
    });

    it('refuses Escape when it is not dismissible', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <PlPopover defaultOpen dismissible={false} onOpenChange={onOpenChange} title="Rates">
          How the number is worked out.
        </PlPopover>
      );

      document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
      expect(onOpenChange).not.toHaveBeenCalled();
    });

    it('closes from a PlPopoverClose, which is what keeps a refusal from being a trap', async () => {
      const screen = await render(
        <PlPopover defaultOpen dismissible={false} title="Rates">
          <PlPopoverClose render={<PlButton variant="ghost">Got it</PlButton>} />
        </PlPopover>
      );

      await screen.getByRole('button', { name: 'Got it' }).click();

      await expect.poll(() => screen.getByRole('dialog').query()).toBeNull();
    });

    it('reports the change and stays where a controlled open put it', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <PlPopover open onOpenChange={onOpenChange} showClose title="Rates">
          How the number is worked out.
        </PlPopover>
      );

      await screen.getByRole('button', { name: 'Close' }).click();

      expect(onOpenChange).toHaveBeenCalledWith(false);
      // The parent said open and never said otherwise.
      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
    });
  });

  describe('the popup', () => {
    it('leaves the page working behind it, which is what it is for', async () => {
      const screen = await render(
        <>
          <PlButton>Behind</PlButton>
          <PlPopover defaultOpen title="Rates">
            How the number is worked out.
          </PlPopover>
        </>
      );

      // A popover is a detail beside the page, not instead of it — nothing is
      // taken off the accessibility tree the way a modal takes it.
      await expect.element(screen.getByRole('button', { name: 'Behind' })).toBeInTheDocument();
    });

    it('caps its width off the size ladder, and takes an override', async () => {
      const screen = await render(
        <PlPopover defaultOpen data-testid="popup" title="Rates">
          How the number is worked out.
        </PlPopover>
      );

      expect(screen.getByTestId('popup').element()).toHaveClass('max-w-80');

      await screen.rerender(
        <PlPopover defaultOpen data-testid="popup" width={420} title="Rates">
          How the number is worked out.
        </PlPopover>
      );

      const element = screen.getByTestId('popup').element() as HTMLElement;

      expect(element).not.toHaveClass('max-w-80');
      expect(element.style.maxWidth).toBe('420px');
    });

    it('floats at the top of the ladder, with no elevation to sit it flat', async () => {
      const screen = await render(
        <PlPopover defaultOpen data-testid="popup" title="Rates">
          How the number is worked out.
        </PlPopover>
      );

      const element = screen.getByTestId('popup').element() as HTMLElement;

      expect(element.style.getPropertyValue('--p-elev')).toBe('var(--plass-shadow-3)');
    });

    it('draws no wedge until it is asked for one', async () => {
      const screen = await render(
        <PlPopover defaultOpen data-testid="popup" title="Rates">
          How the number is worked out.
        </PlPopover>
      );

      // A tooltip is a filled plate whose wedge is the same solid colour; this
      // surface is translucent over a blurred backdrop, and a wedge sticking out
      // past the popup's own box cannot carry that backdrop with it.
      expect(screen.getByTestId('popup').element().querySelector('svg')).toBeNull();

      await screen.rerender(
        <PlPopover defaultOpen arrow data-testid="popup" title="Rates">
          How the number is worked out.
        </PlPopover>
      );

      expect(screen.getByTestId('popup').element().querySelector('svg')).not.toBeNull();
    });

    it('fades and never slides', async () => {
      const screen = await render(
        <PlPopover defaultOpen data-testid="popup" title="Rates">
          How the number is worked out.
        </PlPopover>
      );

      const element = screen.getByTestId('popup').element();

      expect(element).toHaveClass('data-[starting-style]:opacity-0');
      expect(element.className).not.toContain('translate');
    });
  });
});
