import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlFooter, PlPageLayout } from 'plass-ui';

describe('PlFooter', () => {
  describe('the element', () => {
    it('is a real footer, which is the contentinfo landmark', async () => {
      const screen = await render(<PlFooter>© 2026 Acme</PlFooter>);

      await expect.element(screen.getByRole('contentinfo')).toHaveTextContent('© 2026 Acme');
    });

    it('takes a name, for the page that has two of them', async () => {
      const screen = await render(<PlFooter label="Site">© 2026 Acme</PlFooter>);

      await expect.element(screen.getByRole('contentinfo', { name: 'Site' })).toBeVisible();
    });

    it('renders something else when asked', async () => {
      const screen = await render(<PlFooter render={<div />}>© 2026 Acme</PlFooter>);

      expect(screen.getByRole('contentinfo').query()).toBeNull();
    });

    it('has no slots at all — the content is whatever it was given', async () => {
      const screen = await render(
        <PlFooter>
          <nav>Links</nav>
          <p>© 2026 Acme</p>
        </PlFooter>
      );

      const inner = screen.getByRole('contentinfo').element().firstElementChild!;

      expect(inner.children).toHaveLength(2);
    });
  });

  describe('the sheet', () => {
    it('is never dyed, whatever colour it is given', async () => {
      const screen = await render(
        <PlFooter data-testid="bar" color="danger">
          © 2026
        </PlFooter>
      );

      const style = screen.getByTestId('bar').element().getAttribute('style') ?? '';

      expect(style).not.toContain('--p-fill');
      expect(style).toContain('--plass-danger-ring');
    });

    it('rules its top edge by default and can be told not to', async () => {
      const screen = await render(<PlFooter data-testid="bar">© 2026</PlFooter>);

      expect(screen.getByTestId('bar').element()).toHaveClass('border-t');

      await screen.rerender(
        <PlFooter data-testid="bar" divider={false}>
          © 2026
        </PlFooter>
      );

      expect(screen.getByTestId('bar').element()).not.toHaveClass('border-t');
    });

    it('is static by default — the opposite of a header', async () => {
      const screen = await render(<PlFooter data-testid="bar">© 2026</PlFooter>);

      const element = screen.getByTestId('bar').element();

      expect(element).not.toHaveClass('sticky');
      expect(element).not.toHaveClass('fixed');
    });

    it('can be kept in reach instead', async () => {
      const screen = await render(
        <PlFooter data-testid="bar" position="sticky">
          Save
        </PlFooter>
      );

      const element = screen.getByTestId('bar').element();

      expect(element).toHaveClass('sticky');
      expect(element).toHaveClass('bottom-0');
    });
  });

  describe('the content box', () => {
    it('pads on both axes, on the sheet ladder', async () => {
      const screen = await render(<PlFooter data-testid="bar">© 2026</PlFooter>);

      const inner = screen.getByTestId('bar').element().firstElementChild!;

      expect(inner).toHaveClass('px-5');
      expect(inner).toHaveClass('py-5');
    });

    it('packs tighter on compact', async () => {
      const screen = await render(
        <PlFooter data-testid="bar" density="compact">
          © 2026
        </PlFooter>
      );

      const inner = screen.getByTestId('bar').element().firstElementChild!;

      expect(inner).toHaveClass('px-3.5');
    });

    it('gives the padding up when it is told to', async () => {
      const screen = await render(
        <PlFooter data-testid="bar" padded={false}>
          © 2026
        </PlFooter>
      );

      const inner = screen.getByTestId('bar').element().firstElementChild!;

      expect(inner.className).not.toMatch(/\bpx-/);
    });

    it('holds the content to a measure while the sheet spans the window', async () => {
      const screen = await render(
        <PlFooter data-testid="bar" maxWidth="lg">
          © 2026
        </PlFooter>
      );

      const bar = screen.getByTestId('bar').element();
      const inner = bar.firstElementChild!;

      expect(bar).toHaveClass('w-full');
      expect(inner).toHaveClass('max-w-[64rem]');
      expect(inner).toHaveClass('mx-auto');
    });
  });

  describe('inside a PlPageLayout', () => {
    // Nothing loads Tailwind into the test run, so the bar's height and its
    // `position` are written inline. What is being tested is the registration.
    it('makes the page reserve the height a fixed footer takes out of the flow', async () => {
      const screen = await render(
        <PlPageLayout
          data-testid="layout"
          footer={
            <PlFooter position="fixed" style={{ position: 'fixed', bottom: 0, height: 56 }}>
              © 2026
            </PlFooter>
          }
        >
          Body
        </PlPageLayout>
      );

      const layout = screen.getByTestId('layout').element() as HTMLElement;

      await expect
        .poll(() => layout.style.getPropertyValue('--p-layout-footer-inset'))
        .toBe('56px');
    });

    it('reserves nothing for the static footer it is by default', async () => {
      const screen = await render(
        <PlPageLayout data-testid="layout" footer={<PlFooter>© 2026</PlFooter>}>
          Body
        </PlPageLayout>
      );

      const layout = screen.getByTestId('layout').element() as HTMLElement;

      await expect.poll(() => layout.style.getPropertyValue('--p-layout-footer-inset')).toBe('0px');
    });

    it('is still a sheet with no layout above it', async () => {
      const screen = await render(<PlFooter>© 2026 Acme</PlFooter>);

      await expect.element(screen.getByRole('contentinfo')).toHaveTextContent('© 2026 Acme');
    });
  });
});
