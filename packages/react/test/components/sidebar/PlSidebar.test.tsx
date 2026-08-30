import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlHeader, PlPageLayout, PlSidebar, PlSidebarTrigger } from 'plass-ui';

// The browser the suite runs in is 414px wide, so a breakpoint of `md` always
// collapses and `none` never does. Both paths are therefore reachable without
// resizing anything.
describe('PlSidebar', () => {
  describe('as a column', () => {
    it('is a real aside, which is the complementary landmark', async () => {
      const screen = await render(
        <PlSidebar collapseBelow="none">
          <nav>Links</nav>
        </PlSidebar>
      );

      await expect.element(screen.getByRole('complementary')).toHaveTextContent('Links');
    });

    it('is named, because two unnamed ones are two regions called the same thing', async () => {
      const screen = await render(<PlSidebar collapseBelow="none">Links</PlSidebar>);

      await expect.element(screen.getByRole('complementary', { name: 'Sidebar' })).toBeVisible();

      await screen.rerender(
        <PlSidebar collapseBelow="none" label="Filters">
          Links
        </PlSidebar>
      );

      await expect.element(screen.getByRole('complementary', { name: 'Filters' })).toBeVisible();
    });

    it('takes the width its size implies, and any length it is given', async () => {
      const screen = await render(<PlSidebar collapseBelow="none">Links</PlSidebar>);

      const column = screen.getByRole('complementary').element() as HTMLElement;

      expect(column.style.getPropertyValue('--p-sidebar-w')).toBe('16rem');

      await screen.rerender(
        <PlSidebar collapseBelow="none" width={220}>
          Links
        </PlSidebar>
      );

      expect(
        (screen.getByRole('complementary').element() as HTMLElement).style.getPropertyValue(
          '--p-sidebar-w'
        )
      ).toBe('220px');
    });

    it('rules the inner edge, which is the one facing the content', async () => {
      const screen = await render(<PlSidebar collapseBelow="none">Links</PlSidebar>);

      expect(screen.getByRole('complementary').element()).toHaveClass('border-e');

      await screen.rerender(
        <PlSidebar collapseBelow="none" side="end">
          Links
        </PlSidebar>
      );

      expect(screen.getByRole('complementary').element()).toHaveClass('border-s');

      await screen.rerender(
        <PlSidebar collapseBelow="none" divider={false}>
          Links
        </PlSidebar>
      );

      const column = screen.getByRole('complementary').element();

      expect(column).not.toHaveClass('border-e');
      expect(column).not.toHaveClass('border-s');
    });

    it('is never dyed, whatever colour it is given', async () => {
      const screen = await render(
        <PlSidebar collapseBelow="none" color="danger">
          Links
        </PlSidebar>
      );

      const style = screen.getByRole('complementary').element().getAttribute('style') ?? '';

      expect(style).not.toContain('--p-fill');
      expect(style).toContain('--plass-danger-ring');
    });

    it('holds its place while the page scrolls, and can be told not to', async () => {
      const screen = await render(<PlSidebar collapseBelow="none">Links</PlSidebar>);

      expect(screen.getByRole('complementary').element()).toHaveClass('sticky');

      await screen.rerender(
        <PlSidebar collapseBelow="none" sticky={false}>
          Links
        </PlSidebar>
      );

      expect(screen.getByRole('complementary').element()).not.toHaveClass('sticky');
    });

    it('is simply as tall as the layout when only the content scrolls', async () => {
      const screen = await render(
        <PlPageLayout scroll="content" collapseBelow="none" sidebar={<PlSidebar>Links</PlSidebar>}>
          Body
        </PlPageLayout>
      );

      const column = screen.getByRole('complementary').element();

      expect(column).toHaveClass('h-full');
      expect(column).not.toHaveClass('sticky');
    });

    it('pads its content and can be told not to', async () => {
      const screen = await render(<PlSidebar collapseBelow="none">Links</PlSidebar>);

      expect(screen.getByRole('complementary').element().firstElementChild!).toHaveClass('px-5');

      await screen.rerender(
        <PlSidebar collapseBelow="none" padded={false}>
          Links
        </PlSidebar>
      );

      expect(screen.getByRole('complementary').element().firstElementChild!.className).not.toMatch(
        /\bpx-/
      );
    });

    it('takes the side the layout slot puts it on, with no prop of its own', async () => {
      const screen = await render(
        <PlPageLayout collapseBelow="none" endSidebar={<PlSidebar>Contents</PlSidebar>}>
          Body
        </PlPageLayout>
      );

      // The trailing slot, so the rule is on the leading edge.
      expect(screen.getByRole('complementary').element()).toHaveClass('border-s');
    });
  });

  describe('the resize handle', () => {
    it('is not there until it is asked for', async () => {
      const screen = await render(<PlSidebar collapseBelow="none">Links</PlSidebar>);

      expect(screen.getByRole('separator').query()).toBeNull();
    });

    it('is a named vertical separator and a tab stop', async () => {
      const screen = await render(
        <PlSidebar collapseBelow="none" resizable>
          Links
        </PlSidebar>
      );

      const handle = screen.getByRole('separator').element();

      expect(handle).toHaveAttribute('aria-orientation', 'vertical');
      expect(handle).toHaveAttribute('aria-label', 'Resize sidebar');
      expect(handle).toHaveAttribute('tabindex', '0');
    });

    it('moves the edge on an arrow key and reports the width', async () => {
      const onResize = vi.fn();
      const onResizeEnd = vi.fn();

      const screen = await render(
        <PlSidebar
          collapseBelow="none"
          resizable
          width={200}
          onResize={onResize}
          onResizeEnd={onResizeEnd}
        >
          Links
        </PlSidebar>
      );

      // Nothing loads Tailwind into the test run, so the handle has no width
      // to click on. The key handling is what this is about, and the event is
      // the same event a real press would deliver.
      const handle = screen.getByRole('separator').element();

      handle.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true }));

      // A key press is a whole gesture on its own: both callbacks fire.
      expect(onResize).toHaveBeenCalled();
      expect(onResizeEnd).toHaveBeenCalled();
    });

    it('clamps what a drag or a key press may set', async () => {
      const onResizeEnd = vi.fn();

      const screen = await render(
        <PlSidebar collapseBelow="none" resizable maxWidth={200} onResizeEnd={onResizeEnd}>
          Links
        </PlSidebar>
      );

      screen
        .getByRole('separator')
        .element()
        .dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true }));

      expect(onResizeEnd).toHaveBeenLastCalledWith(200);

      const other = vi.fn();

      await screen.rerender(
        <PlSidebar collapseBelow="none" resizable minWidth={600} maxWidth={800} onResizeEnd={other}>
          Links
        </PlSidebar>
      );

      screen
        .getByRole('separator')
        .element()
        .dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowLeft', bubbles: true }));

      expect(other).toHaveBeenLastCalledWith(600);
    });
  });

  describe('as a drawer', () => {
    it('is not in the document while it is closed', async () => {
      const screen = await render(
        <PlSidebar collapseBelow="md">
          <nav>Links</nav>
        </PlSidebar>
      );

      expect(screen.getByRole('complementary').query()).toBeNull();
      expect(screen.getByRole('dialog').query()).toBeNull();
    });

    it('is a dialog once it is opened, named by the sidebar', async () => {
      const screen = await render(
        <PlSidebar collapseBelow="md" open>
          <nav>Links</nav>
        </PlSidebar>
      );

      await expect.element(screen.getByRole('dialog', { name: 'Sidebar' })).toBeVisible();
    });

    it('takes a title instead, once it has covered the page', async () => {
      const screen = await render(
        <PlSidebar collapseBelow="md" open title="Navigation">
          <nav>Links</nav>
        </PlSidebar>
      );

      await expect.element(screen.getByRole('dialog', { name: 'Navigation' })).toBeVisible();
    });

    it('renders its children once, not twice', async () => {
      const screen = await render(
        <PlSidebar collapseBelow="md" open>
          <span>Links</span>
        </PlSidebar>
      );

      await expect.element(screen.getByText('Links')).toBeVisible();
      expect(screen.getByText('Links').elements()).toHaveLength(1);
    });

    it('reports a close through onOpenChange', async () => {
      const onOpenChange = vi.fn();

      const screen = await render(
        <PlSidebar collapseBelow="md" open onOpenChange={onOpenChange}>
          Links
        </PlSidebar>
      );

      (screen.getByRole('button', { name: 'Close sidebar' }).element() as HTMLElement).click();

      await expect.poll(() => onOpenChange.mock.calls.length).toBeGreaterThan(0);
      expect(onOpenChange).toHaveBeenCalledWith(false);
    });
  });
});

describe('PlSidebarTrigger', () => {
  it('renders nothing outside a layout, because there is nothing to open', async () => {
    const screen = await render(<PlSidebarTrigger />);

    expect(screen.getByRole('button').query()).toBeNull();
  });

  it('is a named button that reports what it is about to do', async () => {
    const screen = await render(
      <PlPageLayout header={<PlHeader brand={<PlSidebarTrigger />} />} sidebar={<PlSidebar />}>
        Body
      </PlPageLayout>
    );

    const button = screen.getByRole('button', { name: 'Open sidebar' });

    await expect.element(button).toHaveAttribute('aria-expanded', 'false');
  });

  it('opens the layout sidebar it names, and says so afterwards', async () => {
    const screen = await render(
      <PlPageLayout
        header={<PlHeader brand={<PlSidebarTrigger data-testid="trigger" />} />}
        sidebar={<PlSidebar />}
      >
        Body
      </PlPageLayout>
    );

    (screen.getByTestId('trigger').element() as HTMLElement).click();

    // Found by its test id rather than by role: the open drawer is modal, so
    // everything outside it — the bar the trigger is in included — is hidden
    // from the accessibility tree, which is exactly what should happen.
    await expect
      .poll(() => screen.getByTestId('trigger').element().getAttribute('aria-expanded'))
      .toBe('true');
    expect(screen.getByTestId('trigger').element()).toHaveAttribute('aria-label', 'Close sidebar');
  });

  it('opens the trailing sidebar when it is told to', async () => {
    const screen = await render(
      <PlPageLayout
        header={<PlHeader brand={<PlSidebarTrigger side="end" label="Open contents" />} />}
        endSidebar={<PlSidebar label="Contents" />}
      >
        Body
      </PlPageLayout>
    );

    (screen.getByRole('button', { name: 'Open contents' }).element() as HTMLElement).click();

    await expect.element(screen.getByRole('dialog', { name: 'Contents' })).toBeVisible();
  });

  it('is hidden at and above the width the sidebar comes back at', async () => {
    const screen = await render(
      <PlPageLayout
        collapseBelow="lg"
        header={<PlHeader brand={<PlSidebarTrigger />} />}
        sidebar={<PlSidebar />}
      >
        Body
      </PlPageLayout>
    );

    // A media query rather than a piece of state, so the button is in the
    // markup a server sends rather than popping in a moment later.
    await expect.element(screen.getByRole('button')).toHaveClass('lg:hidden');
  });
});
