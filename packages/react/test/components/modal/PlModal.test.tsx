import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlModal, PlModalClose } from 'plass-ui';

describe('PlModal', () => {
  describe('opening and closing', () => {
    it('renders nothing until it is open', async () => {
      const screen = await render(<PlModal title="Delete project">Are you sure?</PlModal>);

      expect(screen.getByRole('dialog').query()).toBeNull();
    });

    it('shows itself when `defaultOpen` is set', async () => {
      const screen = await render(
        <PlModal defaultOpen title="Delete project">
          Are you sure?
        </PlModal>
      );

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
    });

    it('opens from its trigger', async () => {
      const screen = await render(
        <PlModal trigger={<button type="button">Delete</button>} title="Delete project">
          Are you sure?
        </PlModal>
      );

      await screen.getByRole('button', { name: 'Delete' }).click();

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
    });

    // The four tests below use `modal="trap-focus"` rather than the default. A
    // fully modal Base UI dialog renders an inert overlay with inline
    // `position: fixed; inset: 0`, and nothing loads Tailwind into the test run
    // — so the `z-(--plass-z-portal)` that puts the sheet above it in a real app is an inert
    // string here and every click lands on the overlay. The wiring under test is
    // the same either way.
    it('closes from the ×', async () => {
      const screen = await render(
        <PlModal defaultOpen modal="trap-focus" title="Delete project">
          Are you sure?
        </PlModal>
      );

      await screen.getByRole('button', { name: 'Close' }).click();

      await expect.poll(() => screen.getByRole('dialog').query()).toBeNull();
    });

    it('closes from a `PlModalClose` in the actions', async () => {
      const screen = await render(
        <PlModal
          defaultOpen
          modal="trap-focus"
          title="Delete project"
          actions={<PlModalClose render={<button type="button">Cancel</button>} />}
        >
          Are you sure?
        </PlModal>
      );

      await screen.getByRole('button', { name: 'Cancel' }).click();

      await expect.poll(() => screen.getByRole('dialog').query()).toBeNull();
    });

    it('reports the change to `onOpenChange`', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <PlModal defaultOpen modal="trap-focus" title="Delete project" onOpenChange={onOpenChange}>
          Are you sure?
        </PlModal>
      );

      await screen.getByRole('button', { name: 'Close' }).click();

      await vi.waitFor(() => expect(onOpenChange).toHaveBeenCalledWith(false));
    });

    it('stays open when the caller owns `open`', async () => {
      const screen = await render(
        <PlModal open modal="trap-focus" title="Delete project" onOpenChange={() => {}}>
          Are you sure?
        </PlModal>
      );

      await screen.getByRole('button', { name: 'Close' }).click();

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
    });
  });

  describe('the sections', () => {
    it('names the dialog with its title and describes it with the description', async () => {
      const screen = await render(
        <PlModal defaultOpen title="Delete project" description="This cannot be undone.">
          Are you sure?
        </PlModal>
      );

      await expect
        .element(screen.getByRole('dialog', { name: 'Delete project' }))
        .toBeInTheDocument();
      await expect.element(screen.getByText('This cannot be undone.')).toBeInTheDocument();
    });

    it('renders the title as a real heading', async () => {
      const screen = await render(
        <PlModal defaultOpen title="Delete project">
          Body
        </PlModal>
      );

      await expect
        .element(screen.getByRole('heading', { name: 'Delete project' }))
        .toBeInTheDocument();
    });

    it('renders the actions', async () => {
      const screen = await render(
        <PlModal defaultOpen title="Delete" actions={<button type="button">Delete it</button>}>
          Body
        </PlModal>
      );

      await expect.element(screen.getByRole('button', { name: 'Delete it' })).toBeInTheDocument();
    });

    it('hides the × when `showClose` is off', async () => {
      const screen = await render(
        <PlModal defaultOpen showClose={false} title="Delete">
          Body
        </PlModal>
      );

      expect(screen.getByRole('button', { name: 'Close' }).query()).toBeNull();
    });

    it('takes a different name for the ×', async () => {
      const screen = await render(
        <PlModal defaultOpen closeLabel="닫기" title="Delete">
          Body
        </PlModal>
      );

      await expect.element(screen.getByRole('button', { name: '닫기' })).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <PlModal defaultOpen className="my-own-class" title="Delete">
          Body
        </PlModal>
      );

      expect(screen.getByRole('dialog').element()).toHaveClass('my-own-class');
    });
  });

  describe('dismissible', () => {
    it('closes on Escape by default', async () => {
      const screen = await render(
        <PlModal defaultOpen title="Delete">
          Body
        </PlModal>
      );

      const dialog = screen.getByRole('dialog').element() as HTMLElement;

      dialog.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));

      await expect.poll(() => screen.getByRole('dialog').query()).toBeNull();
    });

    it('stays open on Escape when it is not dismissible', async () => {
      const screen = await render(
        <PlModal defaultOpen dismissible={false} title="Finish setup">
          Body
        </PlModal>
      );

      const dialog = screen.getByRole('dialog').element() as HTMLElement;

      dialog.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
    });
  });

  describe('width', () => {
    it('takes the width the `size` implies', async () => {
      const screen = await render(
        <PlModal defaultOpen size="xl" title="Wide">
          Body
        </PlModal>
      );

      expect(screen.getByRole('dialog').element()).toHaveClass('max-w-4xl');
    });

    it('lets `width` override it', async () => {
      const screen = await render(
        <PlModal defaultOpen width={720} title="Wide">
          Body
        </PlModal>
      );
      const dialog = screen.getByRole('dialog').element() as HTMLElement;

      expect(dialog.style.maxWidth).toBe('720px');
      expect(dialog).not.toHaveClass('max-w-lg');
    });
  });
  describe('the backdrop', () => {
    it('takes classes of its own without losing the scrim', async () => {
      await render(
        <PlModal defaultOpen title="Wide" classNames={{ backdrop: 'my-own-backdrop' }}>
          Body
        </PlModal>
      );

      const backdrop = document.querySelector('.my-own-backdrop');

      expect(backdrop).not.toBeNull();
      expect(backdrop).toHaveClass('plass-portal');
      expect(backdrop?.className).toContain('bg-(--plass-scrim)');
    });

    it('fades with the sheet, at the slow duration', async () => {
      const screen = await render(
        <PlModal defaultOpen title="Wide" classNames={{ backdrop: 'my-own-backdrop' }}>
          Body
        </PlModal>
      );

      const backdrop = document.querySelector('.my-own-backdrop')!;
      const sheet = screen.getByRole('dialog').element();

      // The two arrive as one thing, so they take one duration — and it is the
      // slow one, because 150ms on a surface this size is a cut rather than a
      // fade.
      for (const element of [backdrop, sheet]) {
        expect(element.className).toContain('--plass-duration-slow');
        expect(element).toHaveClass('data-[starting-style]:opacity-0');
        expect(element.className).not.toContain('translate');
      }
    });

    it('leaves the sheet where its own `className` put it', async () => {
      const screen = await render(
        <PlModal
          defaultOpen
          title="Wide"
          className="my-own-sheet"
          classNames={{ backdrop: 'my-own-backdrop' }}
        >
          Body
        </PlModal>
      );

      expect(screen.getByRole('dialog').element()).toHaveClass('my-own-sheet');
      expect(screen.getByRole('dialog').element()).not.toHaveClass('my-own-backdrop');
    });
  });
});
