import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlOverlay } from 'plass-ui';

describe('PlOverlay', () => {
  describe('showing it', () => {
    it('renders nothing while it is closed', async () => {
      const screen = await render(<PlOverlay>Saving</PlOverlay>);

      expect(screen.getByText('Saving').query()).toBeNull();
    });

    it('renders its content when it is open', async () => {
      const screen = await render(
        <PlOverlay open modal="trap-focus">
          Saving
        </PlOverlay>
      );

      await expect.element(screen.getByText('Saving')).toBeInTheDocument();
    });

    it('starts open when told to', async () => {
      const screen = await render(
        <PlOverlay defaultOpen modal="trap-focus">
          Saving
        </PlOverlay>
      );

      await expect.element(screen.getByText('Saving')).toBeInTheDocument();
    });

    it('closes on a controlled change', async () => {
      const screen = await render(
        <PlOverlay open modal="trap-focus">
          Saving
        </PlOverlay>
      );

      await screen.rerender(
        <PlOverlay open={false} modal="trap-focus">
          Saving
        </PlOverlay>
      );

      // Retried rather than asserted once: the popup fades out, so it is still
      // in the DOM for the length of the transition after `open` goes false.
      await expect.element(screen.getByText('Saving')).not.toBeInTheDocument();
    });
  });

  describe('the accessible name', () => {
    it('names itself even when it holds nothing readable', async () => {
      const screen = await render(<PlOverlay open modal="trap-focus" />);

      await expect.element(screen.getByRole('dialog', { name: 'Overlay' })).toBeInTheDocument();
    });

    it('takes a name of its own', async () => {
      const screen = await render(
        <PlOverlay open modal="trap-focus" label="Saving your changes" />
      );

      await expect
        .element(screen.getByRole('dialog', { name: 'Saving your changes' }))
        .toBeInTheDocument();
    });
  });

  describe('dismissing it', () => {
    it('ignores Escape by default', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <PlOverlay open modal="trap-focus" onOpenChange={onOpenChange}>
          Saving
        </PlOverlay>
      );

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
      await screen
        .getByRole('dialog')
        .element()
        .dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));

      expect(onOpenChange).not.toHaveBeenCalled();
    });

    it('answers Escape once it is dismissible', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <PlOverlay open dismissible modal="trap-focus" onOpenChange={onOpenChange}>
          Saving
        </PlOverlay>
      );

      const dialog = screen.getByRole('dialog');

      await expect.element(dialog).toBeInTheDocument();
      dialog
        .element()
        .dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));

      await expect.poll(() => onOpenChange).toHaveBeenCalledWith(false);
    });
  });

  describe('rendering', () => {
    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <PlOverlay open modal="trap-focus" className="my-own-class">
          Saving
        </PlOverlay>
      );

      expect(screen.getByRole('dialog').element()).toHaveClass('my-own-class');
    });

    it('forwards unknown props to the popup', async () => {
      const screen = await render(
        <PlOverlay open modal="trap-focus" data-testid="sheet">
          Saving
        </PlOverlay>
      );

      expect(screen.getByTestId('sheet').element()).toBeInTheDocument();
    });
  });
  describe('the backdrop', () => {
    it('takes classes of its own without losing the tone', async () => {
      await render(
        <PlOverlay open modal="trap-focus" classNames={{ backdrop: 'my-own-backdrop' }}>
          Saving
        </PlOverlay>
      );

      const backdrop = document.querySelector('.my-own-backdrop');

      expect(backdrop).not.toBeNull();
      expect(backdrop).toHaveClass('plass-portal');
    });
  });
});
