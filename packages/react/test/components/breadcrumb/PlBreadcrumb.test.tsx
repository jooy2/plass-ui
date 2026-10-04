import { describe, expect, it, vi } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlBreadcrumb, PlBreadcrumbItem } from 'plass-ui';
import { RouterLink } from '../../support/router';

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

    it('is a link that cannot be followed when it is disabled, and Tab passes over it', async () => {
      const onClick = vi.fn();
      // Buttons either side with a `tabIndex` of their own: WebKit follows the
      // platform and leaves a plain button or link out of the Tab order, so
      // without one Tab would reach nothing there.
      const screen = await render(
        <>
          <button type="button" tabIndex={0}>
            Before
          </button>
          <PlBreadcrumb>
            <PlBreadcrumbItem disabled href="/docs" onClick={onClick}>
              Docs
            </PlBreadcrumbItem>
            <PlBreadcrumbItem>Here</PlBreadcrumbItem>
          </PlBreadcrumb>
          <button type="button" tabIndex={0}>
            After
          </button>
        </>
      );

      const docs = screen.getByRole('link', { name: 'Docs' });

      expect(docs.element()).toHaveAttribute('aria-disabled', 'true');
      expect(docs.element()).not.toHaveAttribute('href');

      // Dispatched rather than driven: Playwright waits for an
      // `aria-disabled` element to be enabled before it will press it.
      (docs.element() as HTMLElement).click();

      expect(onClick).not.toHaveBeenCalled();

      const before = screen.getByRole('button', { name: 'Before' });

      (before.element() as HTMLElement).focus();
      await expect.element(before).toHaveFocus();
      await userEvent.tab();
      await expect.element(screen.getByRole('button', { name: 'After' })).toHaveFocus();
    });

    it('is plain text when it is disabled with nowhere to go', async () => {
      const screen = await render(
        <PlBreadcrumb>
          <PlBreadcrumbItem disabled onClick={() => {}}>
            Docs
          </PlBreadcrumbItem>
          <PlBreadcrumbItem>Here</PlBreadcrumbItem>
        </PlBreadcrumb>
      );

      expect(screen.getByRole('link').query()).toBeNull();
      expect(screen.getByRole('button').query()).toBeNull();
      expect(screen.getByText('Docs').element().closest('[aria-disabled]')).not.toBeNull();
    });

    it('stays the current page, and not a link, when it is the current step and disabled', async () => {
      const screen = await render(
        <PlBreadcrumb>
          <PlBreadcrumbItem href="/">Home</PlBreadcrumbItem>
          <PlBreadcrumbItem disabled href="/billing">
            Billing
          </PlBreadcrumbItem>
        </PlBreadcrumb>
      );

      expect(screen.getByRole('link', { name: 'Billing' }).query()).toBeNull();
      expect(screen.getByText('Billing').element().closest('[aria-current]')).toHaveAttribute(
        'aria-current',
        'page'
      );
    });
  });

  describe('render', () => {
    it("draws a step's link on the element it is given", async () => {
      const screen = await render(
        <PlBreadcrumb>
          <PlBreadcrumbItem render={<RouterLink href="/docs" />}>Docs</PlBreadcrumbItem>
          <PlBreadcrumbItem>Here</PlBreadcrumbItem>
        </PlBreadcrumb>
      );

      const link = screen.getByRole('link', { name: 'Docs' }).element();

      expect(link).toHaveAttribute('data-router');
      expect(link).toHaveAttribute('href', '/docs');
      expect(link).toHaveClass('cursor-pointer', 'hover:bg-(--p-soft)');
    });

    it("lets the element keep its own address over the step's", async () => {
      const screen = await render(
        <PlBreadcrumb>
          <PlBreadcrumbItem href="/docs" render={<RouterLink href="/en/docs" />}>
            Docs
          </PlBreadcrumbItem>
          <PlBreadcrumbItem>Here</PlBreadcrumbItem>
        </PlBreadcrumb>
      );

      expect(screen.getByRole('link', { name: 'Docs' }).element()).toHaveAttribute(
        'href',
        '/en/docs'
      );
    });

    it("follows it from the keyboard, through the step's handler and the router's", async () => {
      const onClick = vi.fn();
      const onNavigate = vi.fn();
      const screen = await render(
        <PlBreadcrumb>
          <PlBreadcrumbItem
            onClick={onClick}
            render={<RouterLink href="/docs" onNavigate={onNavigate} />}
          >
            Docs
          </PlBreadcrumbItem>
          <PlBreadcrumbItem>Here</PlBreadcrumbItem>
        </PlBreadcrumb>
      );

      const link = screen.getByRole('link', { name: 'Docs' });

      (link.element() as HTMLElement).focus();
      await expect.element(link).toHaveFocus();
      await userEvent.keyboard('{Enter}');

      expect(onClick).toHaveBeenCalledOnce();
      expect(onNavigate).toHaveBeenCalledWith('/docs');
    });

    it('is not used by the current step or a disabled one, which go nowhere', async () => {
      const screen = await render(
        <PlBreadcrumb>
          <PlBreadcrumbItem disabled render={<RouterLink href="/docs" />}>
            Docs
          </PlBreadcrumbItem>
          <PlBreadcrumbItem render={<RouterLink href="/billing" />}>Billing</PlBreadcrumbItem>
        </PlBreadcrumb>
      );

      expect(document.querySelector('[data-router]')).toBeNull();

      // The disabled step is still announced as a link, one with no address.
      const docs = screen.getByRole('link', { name: 'Docs' }).element();

      expect(docs).toHaveAttribute('aria-disabled', 'true');
      expect(docs).not.toHaveAttribute('href');
      expect(screen.getByRole('link', { name: 'Billing' }).query()).toBeNull();
      expect(screen.getByText('Billing').element().closest('[aria-current]')).toHaveAttribute(
        'aria-current',
        'page'
      );
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

    it('hands the focus to the first step that came back', async () => {
      const screen = await render(<PlBreadcrumb maxItems={3}>{trail}</PlBreadcrumb>);
      const fold = screen.getByRole('button', { name: 'Show the hidden steps' });

      fold.element().focus();
      await expect.element(fold).toHaveFocus();
      await userEvent.keyboard('{Enter}');

      await expect.element(screen.getByRole('link', { name: 'Alpha' })).toHaveFocus();
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

    it('takes the address off the element a step renders its link on', async () => {
      await render(
        <PlBreadcrumb className="trail-under-test" structuredData baseUrl="https://example.com">
          <PlBreadcrumbItem render={<RouterLink href="/docs" />}>Docs</PlBreadcrumbItem>
          <PlBreadcrumbItem href="/a" render={<RouterLink href="/en/a" />}>
            A
          </PlBreadcrumbItem>
          <PlBreadcrumbItem>Here</PlBreadcrumbItem>
        </PlBreadcrumb>
      );

      const script = document.querySelector('.trail-under-test script');
      const data = JSON.parse(script?.textContent ?? '{}');

      expect(data.itemListElement[0].item).toBe('https://example.com/docs');
      expect(data.itemListElement[1].item).toBe('https://example.com/en/a');
    });
  });
});
