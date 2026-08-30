import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlMenubar, PlMenubarMenu, PlMenuItem, PlMenuSeparator } from 'plass-ui';

describe('PlMenubar', () => {
  describe('the strip', () => {
    it('is a menubar with a word per menu', async () => {
      const screen = await render(
        <PlMenubar>
          <PlMenubarMenu label="File">
            <PlMenuItem>New</PlMenuItem>
          </PlMenubarMenu>
          <PlMenubarMenu label="Edit">
            <PlMenuItem>Copy</PlMenuItem>
          </PlMenubarMenu>
        </PlMenubar>
      );

      await expect.element(screen.getByRole('menubar')).toBeVisible();
      expect(screen.getByRole('menuitem').elements()).toHaveLength(2);
    });

    it('draws no surface of its own', async () => {
      const screen = await render(
        <PlMenubar data-testid="bar">
          <PlMenubarMenu label="File">
            <PlMenuItem>New</PlMenuItem>
          </PlMenubarMenu>
        </PlMenubar>
      );

      const className = screen.getByTestId('bar').element().className;

      expect(className).not.toContain('bg-');
      expect(className).not.toContain('border');
      expect(className).not.toContain('shadow');
    });

    it('sits a rung below the control ladder', async () => {
      const screen = await render(
        <PlMenubar>
          <PlMenubarMenu label="File">
            <PlMenuItem>New</PlMenuItem>
          </PlMenubarMenu>
        </PlMenubar>
      );

      // A strip of words, not a row of buttons: `md` is 26px rather than 40.
      expect(screen.getByRole('menuitem', { name: 'File' }).element()).toHaveClass('h-6.5');
    });

    it('spaces its words on the compact track', async () => {
      const screen = await render(
        <PlMenubar>
          <PlMenubarMenu label="File">
            <PlMenuItem>New</PlMenuItem>
          </PlMenubarMenu>
        </PlMenubar>
      );

      expect(screen.getByRole('menuitem', { name: 'File' }).element()).toHaveClass('px-2.5');
    });

    it('runs the other way when it is told to', async () => {
      const screen = await render(
        <PlMenubar data-testid="bar" orientation="vertical">
          <PlMenubarMenu label="File">
            <PlMenuItem>New</PlMenuItem>
          </PlMenubarMenu>
        </PlMenubar>
      );

      expect(screen.getByTestId('bar').element()).toHaveClass('flex-col');
    });

    it('carries the family in four slots and dyes nothing', async () => {
      const screen = await render(
        <PlMenubar data-testid="bar" color="danger">
          <PlMenubarMenu label="File">
            <PlMenuItem>New</PlMenuItem>
          </PlMenubarMenu>
        </PlMenubar>
      );

      const style = screen.getByTestId('bar').element().getAttribute('style') ?? '';

      expect(style).toContain('--plass-danger-soft');
      expect(style).not.toContain('--p-fill');
    });
  });

  describe('a menu on it', () => {
    it('opens on a press and holds the same rows a PlMenu does', async () => {
      const onClick = vi.fn();

      const screen = await render(
        <PlMenubar>
          <PlMenubarMenu label="File">
            <PlMenuItem onClick={onClick}>New</PlMenuItem>
            <PlMenuSeparator />
            <PlMenuItem>Open…</PlMenuItem>
          </PlMenubarMenu>
        </PlMenubar>
      );

      await screen.getByRole('menuitem', { name: 'File' }).click();

      await expect.element(screen.getByRole('menuitem', { name: 'New' })).toBeVisible();
      // A hairline is a hairline: without the stylesheet it has no height for
      // `toBeVisible` to find, so its presence is what is asserted.
      expect(screen.getByRole('separator').query()).not.toBeNull();

      await screen.getByRole('menuitem', { name: 'New' }).click();

      expect(onClick).toHaveBeenCalled();
    });

    it('says which one is open, in colour and nothing else', async () => {
      const screen = await render(
        <PlMenubar>
          <PlMenubarMenu label="File">
            <PlMenuItem>New</PlMenuItem>
          </PlMenubarMenu>
        </PlMenubar>
      );

      const trigger = screen.getByRole('menuitem', { name: 'File' });

      await expect.element(trigger).toHaveAttribute('aria-expanded', 'false');

      await trigger.click();

      await expect.element(trigger).toHaveAttribute('aria-expanded', 'true');
      // The mark is a class that only paints; nothing about the strip's size.
      expect(trigger.element().className).toContain('data-[popup-open]:bg-(--p-soft-hover)');
    });

    it('takes the axes from the bar rather than from itself', async () => {
      const screen = await render(
        <PlMenubar size="lg">
          <PlMenubarMenu label="File">
            <PlMenuItem>New</PlMenuItem>
          </PlMenubarMenu>
        </PlMenubar>
      );

      expect(screen.getByRole('menuitem', { name: 'File' }).element()).toHaveClass('h-8');
    });

    it('opens nothing while it is disabled', async () => {
      const screen = await render(
        <PlMenubar>
          <PlMenubarMenu label="File" disabled>
            <PlMenuItem>New</PlMenuItem>
          </PlMenubarMenu>
        </PlMenubar>
      );

      const trigger = screen.getByRole('menuitem', { name: 'File' }).element();

      expect(trigger).toBeDisabled();
      expect(screen.getByRole('menuitem', { name: 'New' }).query()).toBeNull();
    });

    it('disables every menu on the bar at once', async () => {
      const screen = await render(
        <PlMenubar disabled>
          <PlMenubarMenu label="File">
            <PlMenuItem>New</PlMenuItem>
          </PlMenubarMenu>
          <PlMenubarMenu label="Edit">
            <PlMenuItem>Copy</PlMenuItem>
          </PlMenubarMenu>
        </PlMenubar>
      );

      for (const trigger of screen.getByRole('menuitem').elements()) {
        expect(trigger).toHaveAttribute('data-disabled');
      }
    });
  });
});
