import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlNavigationMenu, PlNavigationMenuItem, PlNavigationMenuLink } from 'plass-ui';

describe('PlNavigationMenu', () => {
  describe('the row', () => {
    it('is a nav, because what it holds is destinations', async () => {
      const screen = await render(
        <PlNavigationMenu>
          <PlNavigationMenuItem label="Pricing" href="/pricing" />
        </PlNavigationMenu>
      );

      await expect.element(screen.getByRole('navigation')).toBeVisible();
    });

    it('renders an item with an href and no panel as a real link', async () => {
      const screen = await render(
        <PlNavigationMenu>
          <PlNavigationMenuItem label="Pricing" href="/pricing" />
        </PlNavigationMenu>
      );

      await expect
        .element(screen.getByRole('link', { name: 'Pricing' }))
        .toHaveAttribute('href', '/pricing');
    });

    it('renders an item with children as something that expands', async () => {
      const screen = await render(
        <PlNavigationMenu>
          <PlNavigationMenuItem label="Product">
            <PlNavigationMenuLink href="/a" title="Analytics" />
          </PlNavigationMenuItem>
        </PlNavigationMenu>
      );

      const trigger = screen.getByRole('button', { name: /Product/ });

      await expect.element(trigger).toHaveAttribute('aria-expanded', 'false');
      expect(screen.getByRole('link', { name: 'Pricing' }).query()).toBeNull();
    });

    it('merges the two tokens a new tab needs into the rel it was given', async () => {
      const screen = await render(
        <PlNavigationMenu>
          <PlNavigationMenuItem
            label="Docs"
            href="https://example.com"
            target="_blank"
            rel="nofollow"
          />
        </PlNavigationMenu>
      );

      const link = screen.getByRole('link', { name: 'Docs' }).element();

      expect(link.getAttribute('rel')).toContain('nofollow');
      expect(link.getAttribute('rel')).toContain('noopener');
      expect(link.getAttribute('rel')).toContain('noreferrer');
    });

    it('leaves the rel alone on a link that stays in this tab', async () => {
      const screen = await render(
        <PlNavigationMenu>
          <PlNavigationMenuItem label="Docs" href="/docs" rel="nofollow" />
        </PlNavigationMenu>
      );

      expect(screen.getByRole('link', { name: 'Docs' }).element().getAttribute('rel')).toBe(
        'nofollow'
      );
    });

    it('runs the other way when it is told to', async () => {
      const screen = await render(
        <PlNavigationMenu data-testid="nav" orientation="vertical">
          <PlNavigationMenuItem label="Pricing" href="/pricing" />
        </PlNavigationMenu>
      );

      expect(screen.getByTestId('nav').element().firstElementChild).toHaveClass('flex-col');
    });
  });

  describe('the panel', () => {
    it('opens on a press and reports it', async () => {
      const onValueChange = vi.fn();

      const screen = await render(
        <PlNavigationMenu onValueChange={onValueChange}>
          <PlNavigationMenuItem label="Product" value="product">
            <PlNavigationMenuLink href="/a" title="Analytics" description="Numbers over time" />
          </PlNavigationMenuItem>
        </PlNavigationMenu>
      );

      await screen.getByRole('button', { name: /Product/ }).click();

      await expect.element(screen.getByRole('link', { name: /Analytics/ })).toBeVisible();
      expect(onValueChange).toHaveBeenCalledWith('product');
    });

    it('puts real anchors in the panel, with their descriptions', async () => {
      const screen = await render(
        <PlNavigationMenu>
          <PlNavigationMenuItem label="Product">
            <PlNavigationMenuLink href="/a" title="Analytics" description="Numbers over time" />
          </PlNavigationMenuItem>
        </PlNavigationMenu>
      );

      await screen.getByRole('button', { name: /Product/ }).click();

      const link = screen.getByRole('link', { name: /Analytics/ });

      await expect.element(link).toHaveAttribute('href', '/a');
      await expect.element(screen.getByText('Numbers over time')).toBeVisible();
    });

    it('lays the panel out in columns when it is asked to', async () => {
      const screen = await render(
        <PlNavigationMenu>
          <PlNavigationMenuItem label="Product" columns={2}>
            <PlNavigationMenuLink href="/a" title="Analytics" />
            <PlNavigationMenuLink href="/b" title="Billing" />
          </PlNavigationMenuItem>
        </PlNavigationMenu>
      );

      await screen.getByRole('button', { name: /Product/ }).click();

      const panel = screen.getByRole('link', { name: 'Analytics' }).element()
        .parentElement as HTMLElement;

      expect(panel.style.gridTemplateColumns).toBe('repeat(2, minmax(0px, 1fr))');
    });

    it('answers with what a controlled menu is given', async () => {
      const onValueChange = vi.fn();

      const screen = await render(
        <PlNavigationMenu value={null} onValueChange={onValueChange}>
          <PlNavigationMenuItem label="Product" value="product">
            <PlNavigationMenuLink href="/a" title="Analytics" />
          </PlNavigationMenuItem>
        </PlNavigationMenu>
      );

      await screen.getByRole('button', { name: /Product/ }).click();

      expect(onValueChange).toHaveBeenCalledWith('product');
      expect(screen.getByRole('link', { name: 'Analytics' }).query()).toBeNull();
    });

    it('opens the one it is told to', async () => {
      const screen = await render(
        <PlNavigationMenu value="product">
          <PlNavigationMenuItem label="Product" value="product">
            <PlNavigationMenuLink href="/a" title="Analytics" />
          </PlNavigationMenuItem>
        </PlNavigationMenu>
      );

      await expect.element(screen.getByRole('link', { name: 'Analytics' })).toBeVisible();
    });
  });

  describe('states', () => {
    it('opens nothing for a disabled item', async () => {
      const screen = await render(
        <PlNavigationMenu>
          <PlNavigationMenuItem label="Product" disabled>
            <PlNavigationMenuLink href="/a" title="Analytics" />
          </PlNavigationMenuItem>
        </PlNavigationMenu>
      );

      const trigger = screen.getByRole('button', { name: /Product/ }).element();

      expect(trigger).toBeDisabled();
      expect(trigger).toHaveClass('data-[disabled]:opacity-50');
    });

    it('carries no surface at rest, because the words are the page s', async () => {
      const screen = await render(
        <PlNavigationMenu>
          <PlNavigationMenuItem label="Pricing" href="/pricing" />
        </PlNavigationMenu>
      );

      expect(screen.getByRole('link', { name: 'Pricing' }).element()).toHaveClass('bg-transparent');
    });

    it('is never dyed, and carries the family in its slots', async () => {
      const screen = await render(
        <PlNavigationMenu data-testid="nav" color="danger">
          <PlNavigationMenuItem label="Pricing" href="/pricing" />
        </PlNavigationMenu>
      );

      const style = screen.getByTestId('nav').element().getAttribute('style') ?? '';

      expect(style).not.toContain('--p-fill');
      expect(style).toContain('--plass-danger-soft');
    });
  });
});
