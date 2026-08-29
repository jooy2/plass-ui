import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlTextLink } from 'plass-ui';

describe('PlTextLink', () => {
  describe('rendering', () => {
    it('renders an anchor with the href on it', async () => {
      const screen = await render(<PlTextLink href="/pricing">Pricing</PlTextLink>);
      const link = screen.getByRole('link', { name: 'Pricing' }).element();

      expect(link.tagName).toBe('A');
      expect(link).toHaveAttribute('href', '/pricing');
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(<PlTextLink href="/a">Before</PlTextLink>);

      await screen.rerender(<PlTextLink href="/a">After</PlTextLink>);

      await expect.element(screen.getByRole('link', { name: 'After' })).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <PlTextLink href="/a" className="my-own-class">
          Pricing
        </PlTextLink>
      );

      expect(screen.getByRole('link').element()).toHaveClass('my-own-class', 'plass-link');
    });

    it('forwards unknown props to the anchor', async () => {
      const screen = await render(
        <PlTextLink href="/a" download="report.pdf">
          Report
        </PlTextLink>
      );

      expect(screen.getByRole('link').element()).toHaveAttribute('download', 'report.pdf');
    });

    it('renders as another element when `render` says so', async () => {
      const screen = await render(
        <PlTextLink href="/pricing" render={<span role="link" />}>
          Pricing
        </PlTextLink>
      );

      expect(screen.getByRole('link', { name: 'Pricing' }).element().tagName).toBe('SPAN');
    });
  });

  describe('new tabs', () => {
    it('opens in a new tab and protects the opener', async () => {
      const screen = await render(
        <PlTextLink href="https://example.com" newTab>
          Docs
        </PlTextLink>
      );
      const link = screen.getByRole('link').element();

      expect(link).toHaveAttribute('target', '_blank');
      expect(link.getAttribute('rel')?.split(' ')).toEqual(
        expect.arrayContaining(['noopener', 'noreferrer'])
      );
    });

    it("keeps a caller's own `rel` and adds the protection to it", async () => {
      const screen = await render(
        <PlTextLink href="https://example.com" newTab rel="nofollow">
          Sponsor
        </PlTextLink>
      );
      const rel = screen.getByRole('link').element().getAttribute('rel')?.split(' ');

      expect(rel).toEqual(expect.arrayContaining(['nofollow', 'noopener', 'noreferrer']));
    });

    it('sets no `rel` at all on a same-tab link', async () => {
      const screen = await render(<PlTextLink href="/pricing">Pricing</PlTextLink>);

      expect(screen.getByRole('link').element()).not.toHaveAttribute('rel');
    });

    it('says "new tab" to a screen reader as well as drawing the arrow', async () => {
      const screen = await render(
        <PlTextLink href="https://example.com" newTab>
          Docs
        </PlTextLink>
      );

      await expect
        .element(screen.getByRole('link', { name: 'Docs (opens in a new tab)' }))
        .toBeInTheDocument();
    });

    it('takes a different wording for that line', async () => {
      const screen = await render(
        <PlTextLink href="https://example.com" newTab newTabLabel="(새 탭에서 열림)">
          Docs
        </PlTextLink>
      );

      await expect
        .element(screen.getByRole('link', { name: 'Docs (새 탭에서 열림)' }))
        .toBeInTheDocument();
    });
  });

  describe('the mark after the label', () => {
    it('draws the external arrow on a new-tab link', async () => {
      await render(
        <PlTextLink className="link-under-test" href="https://example.com" newTab>
          Docs
        </PlTextLink>
      );

      expect(document.querySelector('.link-under-test svg')).not.toBeNull();
    });

    it('draws nothing on an ordinary link', async () => {
      await render(
        <PlTextLink className="link-under-test" href="/pricing">
          Pricing
        </PlTextLink>
      );

      expect(document.querySelector('.link-under-test svg')).toBeNull();
    });

    it('can be turned off on a new-tab link', async () => {
      await render(
        <PlTextLink className="link-under-test" href="https://example.com" newTab icon={false}>
          Docs
        </PlTextLink>
      );

      expect(document.querySelector('.link-under-test svg')).toBeNull();
    });

    it('takes a node of its own', async () => {
      const screen = await render(
        <PlTextLink href="/pricing" icon={<span>↗</span>}>
          Pricing
        </PlTextLink>
      );

      await expect.element(screen.getByText('↗')).toBeInTheDocument();
    });
  });

  describe('startIcon', () => {
    it('draws nothing unless something is put there', async () => {
      await render(
        <PlTextLink className="link-under-test" href="/pricing">
          Pricing
        </PlTextLink>
      );

      expect(document.querySelector('.link-under-test svg')).toBeNull();
    });

    it('puts the mark in front of the label', async () => {
      await render(
        <PlTextLink className="link-under-test" href="/pricing" startIcon={<span>★</span>}>
          Pricing
        </PlTextLink>
      );

      const link = document.querySelector('.link-under-test') as HTMLElement;

      expect(link.textContent).toBe('★Pricing');
    });

    it('sits on the same link as the destination mark', async () => {
      const screen = await render(
        <PlTextLink
          className="link-under-test"
          href="https://example.com"
          newTab
          startIcon={<span>★</span>}
        >
          Docs
        </PlTextLink>
      );

      const link = document.querySelector('.link-under-test') as HTMLElement;

      await expect.element(screen.getByText('★')).toBeInTheDocument();
      // The leading mark, the label, then the arrow the new tab put there.
      expect(link.querySelector('svg')).toBeInTheDocument();
      expect(link.textContent?.startsWith('★Docs')).toBe(true);
    });
  });

  describe('underline', () => {
    it('draws the line by default', async () => {
      const screen = await render(<PlTextLink href="/a">Pricing</PlTextLink>);

      expect(screen.getByRole('link').element()).toHaveClass('[&.plass-link]:underline');
    });

    it('holds it back until hover when asked', async () => {
      const screen = await render(
        <PlTextLink href="/a" underline="hover">
          Pricing
        </PlTextLink>
      );

      expect(screen.getByRole('link').element()).toHaveClass(
        '[&.plass-link]:hover:underline',
        '[&.plass-link]:no-underline'
      );
    });
  });
});
