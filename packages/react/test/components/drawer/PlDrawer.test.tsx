import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlButton, PlDrawer, PlDrawerClose } from 'plass-ui';

describe('PlDrawer', () => {
  describe('overlay mode', () => {
    // Three of the tests below use `modal="trap-focus"` rather than the
    // default, for the reason `PlModal`'s suite gives: a fully modal Base UI
    // dialog renders an inert overlay with inline `position: fixed; inset: 0`,
    // and nothing loads Tailwind into the test run — so the `z-(--plass-z-portal)` that puts
    // the panel above it in a real app is an inert string here and every click
    // lands on the overlay. The wiring under test is the same either way.
    it('opens from its trigger and names itself', async () => {
      const screen = await render(
        <PlDrawer trigger={<PlButton>Filters</PlButton>} title="Filters">
          Everything you can narrow by.
        </PlDrawer>
      );

      expect(screen.getByRole('dialog').query()).toBeNull();

      await screen.getByRole('button', { name: 'Filters' }).click();

      await expect.element(screen.getByRole('dialog', { name: 'Filters' })).toBeInTheDocument();
    });

    it('describes itself from the line under the title', async () => {
      const screen = await render(
        <PlDrawer defaultOpen title="Filters" description="Nothing is applied yet">
          Everything you can narrow by.
        </PlDrawer>
      );

      await expect
        .element(screen.getByRole('dialog'))
        .toHaveAccessibleDescription('Nothing is applied yet');
    });

    it('shows the × and closes on it', async () => {
      const screen = await render(
        <PlDrawer defaultOpen modal="trap-focus" title="Filters">
          Everything you can narrow by.
        </PlDrawer>
      );

      await screen.getByRole('button', { name: 'Close' }).click();

      await expect.poll(() => screen.getByRole('dialog').query()).toBeNull();
    });

    it('closes from a PlDrawerClose in the actions', async () => {
      const screen = await render(
        <PlDrawer
          defaultOpen
          modal="trap-focus"
          title="Filters"
          actions={<PlDrawerClose render={<PlButton variant="ghost">Cancel</PlButton>} />}
        >
          Everything you can narrow by.
        </PlDrawer>
      );

      await screen.getByRole('button', { name: 'Cancel' }).click();

      await expect.poll(() => screen.getByRole('dialog').query()).toBeNull();
    });

    it('reports the change and stays where a controlled open put it', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <PlDrawer open modal="trap-focus" onOpenChange={onOpenChange} title="Filters">
          Everything you can narrow by.
        </PlDrawer>
      );

      await screen.getByRole('button', { name: 'Close' }).click();

      expect(onOpenChange).toHaveBeenCalledWith(false);
      // The parent said open and never said otherwise.
      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
    });

    it('refuses Escape when it is not dismissible', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <PlDrawer defaultOpen dismissible={false} onOpenChange={onOpenChange} title="Filters">
          Everything you can narrow by.
        </PlDrawer>
      );

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();

      document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));

      await expect.element(screen.getByRole('dialog')).toBeInTheDocument();
      expect(onOpenChange).not.toHaveBeenCalled();
    });
  });

  describe('inline mode', () => {
    it('is in the layout rather than in a dialog', async () => {
      const screen = await render(
        <PlDrawer mode="inline" title="Sections">
          The sidebar that is simply there.
        </PlDrawer>
      );

      await expect
        .element(screen.getByText('The sidebar that is simply there.'))
        .toBeInTheDocument();
      // No scrim, no portal, no focus trap and nothing to dismiss.
      expect(screen.getByRole('dialog').query()).toBeNull();
    });

    it('starts open, because a fixed sidebar that had to be opened is not one', async () => {
      const screen = await render(
        <PlDrawer mode="inline" title="Sections">
          The sidebar that is simply there.
        </PlDrawer>
      );

      await expect.element(screen.getByRole('heading', { name: 'Sections' })).toBeInTheDocument();
    });

    it('is not in the layout at all while it is closed', async () => {
      const screen = await render(
        <PlDrawer mode="inline" open={false} title="Sections">
          The sidebar that is simply there.
        </PlDrawer>
      );

      expect(screen.getByText('The sidebar that is simply there.').query()).toBeNull();
    });

    it('shows no × unless it is asked to', async () => {
      const screen = await render(
        <PlDrawer mode="inline" title="Sections">
          The sidebar that is simply there.
        </PlDrawer>
      );

      // A × that closes a fixed sidebar with nothing to reopen it is a one-way
      // door.
      expect(screen.getByRole('button', { name: 'Close' }).query()).toBeNull();

      await screen.rerender(
        <PlDrawer mode="inline" showClose title="Sections">
          The sidebar that is simply there.
        </PlDrawer>
      );

      await expect.element(screen.getByRole('button', { name: 'Close' })).toBeInTheDocument();
    });

    it('renders no trigger, because there is nothing to open', async () => {
      const screen = await render(
        <PlDrawer mode="inline" trigger={<PlButton>Open</PlButton>} title="Sections">
          The sidebar that is simply there.
        </PlDrawer>
      );

      expect(screen.getByRole('button', { name: 'Open' }).query()).toBeNull();
    });
  });

  describe('the panel', () => {
    it('cuts only the corners that face the page', async () => {
      const screen = await render(
        <PlDrawer mode="inline" data-testid="panel" side="left" title="Sections">
          Body
        </PlDrawer>
      );

      const element = screen.getByTestId('panel').element();

      // The corners against the window edge are always square: a corner cut off
      // something with no visible end is a corner cut off nothing.
      expect(element).toHaveClass('rounded-r-(--plass-radius-md)');
      expect(element).toHaveClass('border-r');
    });

    it('takes an extent as a width along the sides and a height at the ends', async () => {
      const screen = await render(
        <PlDrawer mode="inline" data-testid="panel" side="left" extent={420} title="Sections">
          Body
        </PlDrawer>
      );

      expect((screen.getByTestId('panel').element() as HTMLElement).style.width).toBe('420px');

      await screen.rerender(
        <PlDrawer mode="inline" data-testid="panel" side="bottom" extent={220} title="Sections">
          Body
        </PlDrawer>
      );

      expect((screen.getByTestId('panel').element() as HTMLElement).style.height).toBe('220px');
    });

    it('lies flat in the layout inline, with no shadow to float from', async () => {
      const screen = await render(
        <PlDrawer mode="inline" data-testid="panel" title="Sections">
          Body
        </PlDrawer>
      );

      const element = screen.getByTestId('panel').element() as HTMLElement;

      expect(element.style.getPropertyValue('--p-elev')).toBe('var(--plass-shadow-0)');
    });

    it('scores the sections when it is asked to', async () => {
      const screen = await render(
        <PlDrawer mode="inline" data-testid="panel" dividers title="Sections" actions={<span />}>
          Body
        </PlDrawer>
      );

      expect(screen.getByTestId('panel').element().querySelectorAll('.border-t')).not.toHaveLength(
        0
      );
    });
  });
  describe('the backdrop', () => {
    it('takes classes of its own on an overlay drawer', async () => {
      await render(
        <PlDrawer open title="Filters" classNames={{ backdrop: 'my-own-backdrop' }}>
          Body
        </PlDrawer>
      );

      const backdrop = document.querySelector('.my-own-backdrop');

      expect(backdrop).not.toBeNull();
      expect(backdrop).toHaveClass('plass-portal');
    });

    it('fades with the panel, at the slow duration', async () => {
      const screen = await render(
        <PlDrawer open title="Filters" classNames={{ backdrop: 'my-own-backdrop' }}>
          Body
        </PlDrawer>
      );

      // A drawer takes the page the way a modal does, so it opens on the same
      // duration — and the scrim opens with it rather than a beat apart.
      for (const element of [
        document.querySelector('.my-own-backdrop')!,
        screen.getByRole('dialog').element()
      ]) {
        expect(element.className).toContain('--plass-duration-slow');
        expect(element).toHaveClass('data-[starting-style]:opacity-0');
      }
    });

    it('has none to give an inline drawer, and does not fail over it', async () => {
      await render(
        <PlDrawer mode="inline" title="Filters" classNames={{ backdrop: 'my-own-backdrop' }}>
          Body
        </PlDrawer>
      );

      // An inline drawer sits in the flow: there is no scrim, so there is
      // nothing for the class to land on and nothing to go wrong either.
      expect(document.querySelector('.my-own-backdrop')).toBeNull();
    });
  });
});
