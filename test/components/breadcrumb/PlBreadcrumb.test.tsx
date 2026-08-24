import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlBreadcrumb, PlBreadcrumbItem } from 'plass-ui';

describe('PlBreadcrumb', () => {
  describe('the trail', () => {
    it('renders a navigation landmark with a list in it', async () => {
      const screen = await render(
        <PlBreadcrumb>
          <PlBreadcrumbItem href="/">Home</PlBreadcrumbItem>
          <PlBreadcrumbItem>Settings</PlBreadcrumbItem>
        </PlBreadcrumb>
      );

      await expect
        .element(screen.getByRole('navigation', { name: 'Breadcrumb' }))
        .toBeInTheDocument();
      await expect.element(screen.getByRole('list')).toBeInTheDocument();
    });

    it('takes a name of its own', async () => {
      const screen = await render(
        <PlBreadcrumb label="You are here">
          <PlBreadcrumbItem>Settings</PlBreadcrumbItem>
        </PlBreadcrumb>
      );

      await expect
        .element(screen.getByRole('navigation', { name: 'You are here' }))
        .toBeInTheDocument();
    });

    it('renders every step', async () => {
      const screen = await render(
        <PlBreadcrumb>
          <PlBreadcrumbItem href="/">Home</PlBreadcrumbItem>
          <PlBreadcrumbItem href="/settings">Settings</PlBreadcrumbItem>
          <PlBreadcrumbItem>Billing</PlBreadcrumbItem>
        </PlBreadcrumb>
      );

      await expect.element(screen.getByText('Home')).toBeInTheDocument();
      await expect.element(screen.getByText('Settings')).toBeInTheDocument();
      await expect.element(screen.getByText('Billing')).toBeInTheDocument();
    });
  });

  describe('the current step', () => {
    it('marks the last step as the page you are on', async () => {
      const screen = await render(
        <PlBreadcrumb>
          <PlBreadcrumbItem href="/">Home</PlBreadcrumbItem>
          <PlBreadcrumbItem href="/billing">Billing</PlBreadcrumbItem>
        </PlBreadcrumb>
      );

      expect(screen.getByText('Billing').element().closest('[aria-current]')).toHaveAttribute(
        'aria-current',
        'page'
      );
    });

    it('stops the last step being a link even with an href', async () => {
      const screen = await render(
        <PlBreadcrumb>
          <PlBreadcrumbItem href="/">Home</PlBreadcrumbItem>
          <PlBreadcrumbItem href="/billing">Billing</PlBreadcrumbItem>
        </PlBreadcrumb>
      );

      await expect.element(screen.getByRole('link', { name: 'Home' })).toBeInTheDocument();
      expect(screen.getByRole('link', { name: 'Billing' }).query()).toBeNull();
    });

    it('takes the mark off the last step when an earlier one claims it', async () => {
      const screen = await render(
        <PlBreadcrumb>
          <PlBreadcrumbItem href="/">Home</PlBreadcrumbItem>
          <PlBreadcrumbItem current href="/settings">
            Settings
          </PlBreadcrumbItem>
          <PlBreadcrumbItem href="/billing">Billing</PlBreadcrumbItem>
        </PlBreadcrumb>
      );

      expect(screen.getByText('Settings').element().closest('[aria-current]')).not.toBeNull();
      await expect.element(screen.getByRole('link', { name: 'Billing' })).toBeInTheDocument();
    });
  });

  describe('a step', () => {
    it('is a link with an href', async () => {
      const screen = await render(
        <PlBreadcrumb>
          <PlBreadcrumbItem href="/docs">Docs</PlBreadcrumbItem>
          <PlBreadcrumbItem>Here</PlBreadcrumbItem>
        </PlBreadcrumb>
      );

      expect(screen.getByRole('link', { name: 'Docs' }).element()).toHaveAttribute('href', '/docs');
    });

    it('is a button with only an onClick', async () => {
      const onClick = vi.fn();
      const screen = await render(
        <PlBreadcrumb>
          <PlBreadcrumbItem onClick={onClick}>Docs</PlBreadcrumbItem>
          <PlBreadcrumbItem>Here</PlBreadcrumbItem>
        </PlBreadcrumb>
      );

      await screen.getByRole('button', { name: 'Docs' }).click();

      expect(onClick).toHaveBeenCalledTimes(1);
    });

    it('is neither when it is disabled', async () => {
      const screen = await render(
        <PlBreadcrumb>
          <PlBreadcrumbItem disabled href="/docs">
            Docs
          </PlBreadcrumbItem>
          <PlBreadcrumbItem>Here</PlBreadcrumbItem>
        </PlBreadcrumb>
      );

      expect(screen.getByRole('link', { name: 'Docs' }).query()).toBeNull();
      expect(screen.getByText('Docs').element().closest('[aria-disabled]')).not.toBeNull();
    });
  });

  describe('folding', () => {
    // An array rather than a fragment: `React.Children.toArray` does not walk
    // into a fragment, so a trail wrapped in one arrives as a single step.
    const trail = [
      <PlBreadcrumbItem key="home" href="/">
        Home
      </PlBreadcrumbItem>,
      <PlBreadcrumbItem key="a" href="/a">
        Alpha
      </PlBreadcrumbItem>,
      <PlBreadcrumbItem key="b" href="/b">
        Bravo
      </PlBreadcrumbItem>,
      <PlBreadcrumbItem key="c" href="/c">
        Charlie
      </PlBreadcrumbItem>,
      <PlBreadcrumbItem key="here">Here</PlBreadcrumbItem>
    ];

    it('shows everything without `maxItems`', async () => {
      const screen = await render(<PlBreadcrumb>{trail}</PlBreadcrumb>);

      await expect.element(screen.getByText('Bravo')).toBeInTheDocument();
    });

    it('folds the middle away past `maxItems`', async () => {
      const screen = await render(<PlBreadcrumb maxItems={3}>{trail}</PlBreadcrumb>);

      expect(screen.getByText('Bravo').query()).toBeNull();
      await expect.element(screen.getByText('Home')).toBeInTheDocument();
      await expect.element(screen.getByText('Here')).toBeInTheDocument();
    });

    it('puts the middle back when the fold is pressed', async () => {
      const screen = await render(<PlBreadcrumb maxItems={3}>{trail}</PlBreadcrumb>);

      await screen.getByRole('button', { name: 'Show the hidden steps' }).click();

      await expect.element(screen.getByText('Bravo')).toBeInTheDocument();
    });

    it('leaves the fold inert when `expandable` is off', async () => {
      const screen = await render(
        <PlBreadcrumb maxItems={3} expandable={false}>
          {trail}
        </PlBreadcrumb>
      );

      expect(screen.getByRole('button').query()).toBeNull();
    });
  });

  describe('structured data', () => {
    it('emits nothing by default', async () => {
      await render(
        <PlBreadcrumb className="trail-under-test">
          <PlBreadcrumbItem href="/">Home</PlBreadcrumbItem>
          <PlBreadcrumbItem>Here</PlBreadcrumbItem>
        </PlBreadcrumb>
      );

      expect(document.querySelector('.trail-under-test script')).toBeNull();
    });

    it('emits every step, including the folded ones', async () => {
      await render(
        <PlBreadcrumb
          className="trail-under-test"
          structuredData
          maxItems={2}
          baseUrl="https://example.com"
        >
          <PlBreadcrumbItem href="/">Home</PlBreadcrumbItem>
          <PlBreadcrumbItem href="/a">A</PlBreadcrumbItem>
          <PlBreadcrumbItem href="/b">B</PlBreadcrumbItem>
          <PlBreadcrumbItem>Here</PlBreadcrumbItem>
        </PlBreadcrumb>
      );

      const script = document.querySelector('.trail-under-test script');
      const data = JSON.parse(script?.textContent ?? '{}');

      expect(data['@type']).toBe('BreadcrumbList');
      expect(data.itemListElement).toHaveLength(4);
      expect(data.itemListElement[0].item).toBe('https://example.com/');
      expect(data.itemListElement[3].item).toBeUndefined();
      expect(data.itemListElement[3].name).toBe('Here');
    });
  });
});
