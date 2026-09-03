import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlButton, PlHeader, PlPageLayout } from 'plass-ui';

describe('PlHeader', () => {
  describe('the element', () => {
    it('is a real header, which is the banner landmark', async () => {
      const screen = await render(<PlHeader brand="Acme" />);

      await expect.element(screen.getByRole('banner')).toBeVisible();
    });

    it('takes a name, for the page that has two of them', async () => {
      const screen = await render(<PlHeader label="Site" brand="Acme" />);

      await expect.element(screen.getByRole('banner', { name: 'Site' })).toBeVisible();
    });

    it('renders something else when asked', async () => {
      const screen = await render(<PlHeader render={<div />} brand="Acme" />);

      expect(screen.getByRole('banner').query()).toBeNull();
    });
  });

  describe('the three slots', () => {
    it('lays them out in order', async () => {
      const screen = await render(
        <PlHeader brand="Acme" actions={<PlButton>Sign in</PlButton>}>
          <span>Docs</span>
        </PlHeader>
      );

      expect(screen.getByRole('banner').element().textContent).toBe('AcmeDocsSign in');
    });

    it('draws nothing for a slot nobody filled', async () => {
      const screen = await render(<PlHeader brand="Acme" />);

      expect(screen.getByRole('banner').element().querySelectorAll('div > div')).toHaveLength(1);
    });

    it('gives both ends an equal share when the middle is centred', async () => {
      const screen = await render(
        <PlHeader align="center" brand="Acme" actions={<span>Sign in</span>}>
          <span>Docs</span>
        </PlHeader>
      );

      const row = screen.getByRole('banner').element().firstElementChild!;

      // Equal ends by construction, so a logo that grows by one character does
      // not move the navigation.
      expect(row.children[0]).toHaveClass('flex-1');
      expect(row.children[2]).toHaveClass('flex-1');
    });

    it('still holds the leading half open when there is no brand', async () => {
      const screen = await render(
        <PlHeader align="center" actions={<span>Sign in</span>}>
          <span>Docs</span>
        </PlHeader>
      );

      const row = screen.getByRole('banner').element().firstElementChild!;

      expect(row.children[0]).toHaveAttribute('aria-hidden', 'true');
      expect(row.children[0]).toHaveClass('flex-1');
    });

    it('leaves the ends alone on the two packed alignments', async () => {
      const screen = await render(
        <PlHeader align="end" brand="Acme">
          <span>Docs</span>
        </PlHeader>
      );

      const row = screen.getByRole('banner').element().firstElementChild!;

      expect(row.children[0]).toHaveClass('shrink-0');
      expect(row.children[1]).toHaveClass('justify-end');
    });
  });

  describe('the sheet', () => {
    it('is never dyed, whatever colour it is given', async () => {
      const screen = await render(<PlHeader data-testid="bar" color="danger" brand="Acme" />);

      const style = screen.getByTestId('bar').element().getAttribute('style') ?? '';

      expect(style).not.toContain('--p-fill');
      expect(style).toContain('--plass-danger-ring');
    });

    it('rules its bottom edge by default and can be told not to', async () => {
      const screen = await render(<PlHeader data-testid="bar" brand="Acme" />);

      expect(screen.getByTestId('bar').element()).toHaveClass('border-b');

      await screen.rerender(<PlHeader data-testid="bar" divider={false} brand="Acme" />);

      expect(screen.getByTestId('bar').element()).not.toHaveClass('border-b');
    });

    it('is sticky by default and can be pinned or let go', async () => {
      const screen = await render(<PlHeader data-testid="bar" brand="Acme" />);

      expect(screen.getByTestId('bar').element()).toHaveClass('sticky');

      await screen.rerender(<PlHeader data-testid="bar" position="fixed" brand="Acme" />);

      expect(screen.getByTestId('bar').element()).toHaveClass('fixed');

      await screen.rerender(<PlHeader data-testid="bar" position="static" brand="Acme" />);

      const element = screen.getByTestId('bar').element();

      expect(element).not.toHaveClass('sticky');
      expect(element).not.toHaveClass('fixed');
    });
  });

  describe('the row', () => {
    it('keeps a floor a control can sit inside', async () => {
      const screen = await render(<PlHeader brand="Acme" />);

      const row = screen.getByRole('banner').element().firstElementChild!;

      expect(row).toHaveClass('min-h-16');
      expect(row).toHaveClass('py-3');
    });

    it('holds the row to a measure while the sheet spans the window', async () => {
      const screen = await render(<PlHeader data-testid="bar" maxWidth="lg" brand="Acme" />);

      const bar = screen.getByTestId('bar').element();
      const row = bar.firstElementChild!;

      expect(bar).toHaveClass('w-full');
      // One measure ladder, carried as a slot rather than a class per rung —
      // the same one a `PlContainer` under this bar reads, so the two line up
      // on one edge.
      expect(row).toHaveClass('plass-container');
      expect((row as HTMLElement).style.getPropertyValue('--p-maxw-xs')).toBe('64rem');
      expect(row).toHaveClass('mx-auto');
    });

    it('packs tighter on compact without moving the floor', async () => {
      const screen = await render(<PlHeader data-testid="bar" density="compact" brand="Acme" />);

      const row = screen.getByTestId('bar').element().firstElementChild!;

      expect(row).toHaveClass('px-3.5');
      expect(row).toHaveClass('min-h-16');
    });

    it('gives the gutter up when it is told to', async () => {
      const screen = await render(<PlHeader data-testid="bar" padded={false} brand="Acme" />);

      const row = screen.getByTestId('bar').element().firstElementChild!;

      expect(row.className).not.toMatch(/\bpx-/);
    });
  });

  describe('inside a PlPageLayout', () => {
    // Nothing loads Tailwind into the test run, so the bar's height and its
    // `position` are written inline here. What is being tested is the
    // registration — that the layout is handed this element and measures it —
    // not what the stylesheet says the element is.
    it('hands the layout its height so the columns start below it', async () => {
      const screen = await render(
        <PlPageLayout
          data-testid="layout"
          header={<PlHeader style={{ position: 'sticky', top: 0, height: 64 }} brand="Acme" />}
        >
          Body
        </PlPageLayout>
      );

      const layout = screen.getByTestId('layout').element() as HTMLElement;

      // Sticky is still in the flow, so nothing is reserved for it — but it is
      // across the top of the window, so a column has to start under it.
      await expect.poll(() => layout.style.getPropertyValue('--p-layout-header')).toBe('64px');
      expect(layout.style.getPropertyValue('--p-layout-header-inset')).toBe('0px');
    });

    it('makes the page reserve its height when it is fixed instead', async () => {
      const screen = await render(
        <PlPageLayout
          data-testid="layout"
          header={
            <PlHeader
              position="fixed"
              style={{ position: 'fixed', top: 0, height: 48 }}
              brand="Acme"
            />
          }
        >
          Body
        </PlPageLayout>
      );

      const layout = screen.getByTestId('layout').element() as HTMLElement;

      await expect
        .poll(() => layout.style.getPropertyValue('--p-layout-header-inset'))
        .toBe('48px');
    });

    it('takes nothing off the columns when it only spans the content', async () => {
      const screen = await render(
        <PlPageLayout
          data-testid="layout"
          headerSpan="content"
          header={<PlHeader style={{ position: 'sticky', top: 0, height: 64 }} brand="Acme" />}
        >
          Body
        </PlPageLayout>
      );

      const layout = screen.getByTestId('layout').element() as HTMLElement;

      await expect.poll(() => layout.style.getPropertyValue('--p-layout-header')).toBe('0px');
    });

    it('is still a bar with no layout above it', async () => {
      const screen = await render(<PlHeader brand="Acme" />);

      await expect.element(screen.getByRole('banner')).toHaveTextContent('Acme');
    });
  });
});
