import { renderToString } from 'react-dom/server';
import { describe, expect, it, vi } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import {
  PlassProvider,
  PlNavigationMenu,
  PlNavigationMenuItem,
  PlNavigationMenuLink
} from 'plass-ui';

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

    it('marks the link to the page the reader is on, and no other', async () => {
      const screen = await render(
        <PlNavigationMenu>
          <PlNavigationMenuItem label="Pricing" href="/pricing" active />
          <PlNavigationMenuItem label="Blog" href="/blog" />
        </PlNavigationMenu>
      );

      const current = screen.getByRole('link', { name: 'Pricing' }).element();

      expect(current).toHaveAttribute('aria-current', 'page');
      expect(current).toHaveClass('aria-[current=page]:text-(--p-accent)');
      expect(screen.getByRole('link', { name: 'Blog' }).element()).not.toHaveAttribute(
        'aria-current'
      );
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

    it('merges the two tokens a new tab needs into a panel link s rel', async () => {
      const screen = await render(
        <PlNavigationMenu>
          <PlNavigationMenuItem label="Product">
            <PlNavigationMenuLink
              href="https://example.com"
              title="Docs"
              target="_blank"
              rel="nofollow"
            />
          </PlNavigationMenuItem>
        </PlNavigationMenu>
      );

      await screen.getByRole('button', { name: /Product/ }).click();

      const link = screen.getByRole('link', { name: /Docs/ });

      await expect.element(link).toHaveAttribute('target', '_blank');
      expect(link.element().getAttribute('rel')?.split(' ')).toEqual(
        expect.arrayContaining(['nofollow', 'noopener', 'noreferrer'])
      );
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

    it("puts a closed panel's links in the server HTML", () => {
      // A crawler that never hovers reads what the server sent, and a link that
      // only exists once a panel opens is one it never finds.
      const html = renderToString(
        <PlNavigationMenu>
          <PlNavigationMenuItem label="Product">
            <PlNavigationMenuLink href="/a" title="Analytics" />
          </PlNavigationMenuItem>
          <PlNavigationMenuItem label="Company">
            <PlNavigationMenuLink href="/about" title="About" />
          </PlNavigationMenuItem>
        </PlNavigationMenu>
      );

      expect(html).toContain('href="/a"');
      expect(html).toContain('href="/about"');
    });

    it("keeps a closed panel's links in the document and out of reach", async () => {
      const screen = await render(
        <PlNavigationMenu>
          <PlNavigationMenuItem label="Product">
            <PlNavigationMenuLink href="/a" title="Analytics" />
          </PlNavigationMenuItem>
        </PlNavigationMenu>
      );

      const link = document.querySelector<HTMLAnchorElement>('a[href="/a"]');

      expect(link).not.toBeNull();
      // Hidden, so neither announced nor a focus stop until its panel opens.
      expect(link!.closest('[hidden]')).not.toBeNull();
      expect(screen.getByRole('link', { name: 'Analytics' }).query()).toBeNull();

      link!.focus();

      expect(document.activeElement).not.toBe(link);
    });

    it('still has them once a panel has opened and closed again', async () => {
      const screen = await render(
        <PlNavigationMenu>
          <PlNavigationMenuItem label="Product">
            <PlNavigationMenuLink href="/a" title="Analytics" />
          </PlNavigationMenuItem>
        </PlNavigationMenu>
      );

      await screen.getByRole('button', { name: /Product/ }).click();
      await expect.element(screen.getByRole('link', { name: 'Analytics' })).toBeVisible();

      await userEvent.keyboard('{Escape}');
      await expect
        .element(screen.getByRole('button', { name: /Product/ }))
        .toHaveAttribute('aria-expanded', 'false');

      await expect
        .poll(() => document.querySelector('a[href="/a"]')?.closest('[hidden]'))
        .toBeTruthy();
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

  describe('where the panel opens', () => {
    const trigger = () => document.querySelector<HTMLElement>('button')!;
    const positioner = () => document.querySelector<HTMLElement>('.plass-portal')!;

    /**
     * How far the box Base UI places the panel in stands off the word it opened
     * from, to the pixel: below the word, past its right edge and short of its
     * left edge. The side the panel is on is the one that reads `sideOffset`.
     */
    function standoff() {
      const box = positioner().getBoundingClientRect();
      const word = trigger().getBoundingClientRect();

      return {
        below: Math.round(box.top - word.bottom),
        right: Math.round(box.left - word.right),
        left: Math.round(word.left - box.right)
      };
    }

    function menu(orientation?: 'horizontal' | 'vertical') {
      return (
        <PlNavigationMenu orientation={orientation}>
          <PlNavigationMenuItem label="Product">
            <PlNavigationMenuLink href="/a" title="Analytics" />
          </PlNavigationMenuItem>
        </PlNavigationMenu>
      );
    }

    it('hangs it under the row', async () => {
      await render(menu());

      trigger().click();

      await expect.poll(() => standoff().below).toBe(8);
      expect(positioner()).toHaveAttribute('data-side', 'bottom');
      expect(positioner()).toHaveAttribute('data-align', 'center');
    });

    it('opens it beside a vertical rail, at the end of the line', async () => {
      await render(menu('vertical'));

      trigger().click();

      await expect.poll(() => standoff().right).toBe(8);
      expect(positioner()).toHaveAttribute('data-side', 'inline-end');
    });

    it('sets a rail s panel level with its item, top to top', async () => {
      // A panel several times the height of its item, with room above the rail,
      // so a panel centred on the item would stand well above it. The links are
      // given their height here because no stylesheet is loaded to give it.
      await render(
        <div style={{ paddingTop: 200 }}>
          <PlNavigationMenu orientation="vertical">
            <PlNavigationMenuItem label="Product">
              {['/a', '/b', '/c'].map((href) => (
                <PlNavigationMenuLink
                  key={href}
                  href={href}
                  title={href}
                  style={{ display: 'block', height: 100 }}
                />
              ))}
            </PlNavigationMenuItem>
          </PlNavigationMenu>
        </div>
      );

      trigger().click();

      await expect.poll(() => standoff().right).toBe(8);
      expect(
        Math.round(positioner().getBoundingClientRect().top - trigger().getBoundingClientRect().top)
      ).toBe(0);
      expect(positioner()).toHaveAttribute('data-align', 'start');
    });

    it('opens it to the left of the rail on a page that runs right to left', async () => {
      document.documentElement.setAttribute('dir', 'rtl');

      try {
        // Base UI reads the direction from `PlassProvider`, which reads it off
        // the document.
        await render(<PlassProvider>{menu('vertical')}</PlassProvider>);

        trigger().click();

        await expect.poll(() => standoff().left).toBe(8);
        expect(positioner()).toHaveAttribute('data-side', 'inline-end');
      } finally {
        document.documentElement.removeAttribute('dir');
      }
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
  describe('caller styling', () => {
    it("keeps an item's class names on the link it renders", async () => {
      const screen = await render(
        <PlNavigationMenu>
          <PlNavigationMenuItem label="Pricing" href="/pricing" className="my-own-class" />
        </PlNavigationMenu>
      );

      const link = screen.getByRole('link', { name: 'Pricing' }).element();

      expect(link).toHaveClass('my-own-class');
      expect(link.className).toContain('font-medium');
    });

    it('keeps them on the trigger when the item opens a panel instead', async () => {
      const screen = await render(
        <PlNavigationMenu>
          <PlNavigationMenuItem label="Product" className="my-own-class" style={{ order: 2 }}>
            <PlNavigationMenuLink href="/a" title="Analytics" />
          </PlNavigationMenuItem>
        </PlNavigationMenu>
      );

      const trigger = screen.getByRole('button', { name: /Product/ }).element() as HTMLElement;

      expect(trigger).toHaveClass('my-own-class');
      expect(trigger.style.order).toBe('2');
    });
  });
});
