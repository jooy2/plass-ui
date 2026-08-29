import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlPagination } from 'plass-ui';

/**
 * Clicks a link and reports whether the component cancelled the navigation.
 *
 * The listener is on `document`, which React's own root handler has already run
 * by the time the event reaches it — so `defaultPrevented` there is the
 * component's answer. It then cancels the press itself, or the test browser
 * would leave the page for `/posts?page=3` and take the runner with it.
 */
function clickAndReadCancellation(link: Element): boolean {
  let cancelled = false;

  const stop = (event: MouseEvent) => {
    cancelled = event.defaultPrevented;
    event.preventDefault();
  };

  document.addEventListener('click', stop);
  link.dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true }));
  document.removeEventListener('click', stop);

  return cancelled;
}

describe('PlPagination', () => {
  describe('rendering', () => {
    it('renders a named navigation landmark holding a list', async () => {
      const screen = await render(<PlPagination count={5} />);

      await expect
        .element(screen.getByRole('navigation', { name: 'Pagination' }))
        .toBeInTheDocument();
      await expect.element(screen.getByRole('list')).toBeInTheDocument();
    });

    it('renders nothing at all when there is one page or none', async () => {
      const screen = await render(<PlPagination count={1} />);

      expect(screen.getByRole('navigation').query()).toBeNull();
    });

    it('renders every page when they all fit', async () => {
      const screen = await render(<PlPagination count={5} />);

      for (const page of [1, 2, 3, 4, 5]) {
        await expect
          .element(screen.getByRole('button', { name: `Page ${page}` }))
          .toBeInTheDocument();
      }
    });

    it('marks the current page with `aria-current`', async () => {
      const screen = await render(<PlPagination count={5} defaultPage={3} />);

      expect(screen.getByRole('button', { name: 'Page 3' }).element()).toHaveAttribute(
        'aria-current',
        'page'
      );
      expect(screen.getByRole('button', { name: 'Page 2' }).element()).not.toHaveAttribute(
        'aria-current'
      );
    });

    it('keeps the slot count constant as the window slides', async () => {
      // Counted off the DOM rather than by role: an ellipsis is `aria-hidden`,
      // so the number of *listitems* is exactly what changes here.
      const screen = await render(
        <PlPagination className="row-under-test" count={20} defaultPage={1} showArrows={false} />
      );
      const slots = () => document.querySelectorAll('.row-under-test li').length;
      const atStart = slots();

      await screen.rerender(
        <PlPagination className="row-under-test" count={20} page={10} showArrows={false} />
      );

      expect(atStart).toBe(7);
      expect(slots()).toBe(atStart);
    });

    it('fills a one-page gap with the page rather than an ellipsis', async () => {
      // Boundary 1, siblings 1, seven pages: the gap either side is exactly one
      // page wide, so no ellipsis is drawn.
      await render(<PlPagination count={7} defaultPage={4} showArrows={false} />);

      expect(document.body.textContent).not.toContain('…');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<PlPagination count={5} className="my-own-class" />);

      expect(screen.getByRole('navigation').element()).toHaveClass('my-own-class');
    });
  });

  describe('steppers', () => {
    it('shows the two arrows by default and hides the edge jumps', async () => {
      const screen = await render(<PlPagination count={9} defaultPage={5} />);

      await expect
        .element(screen.getByRole('button', { name: 'Previous page' }))
        .toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Next page' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'First page' }).query()).toBeNull();
    });

    it('shows the edge jumps when asked', async () => {
      const screen = await render(<PlPagination count={9} defaultPage={5} showEdges />);

      await expect.element(screen.getByRole('button', { name: 'First page' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Last page' })).toBeInTheDocument();
    });

    it('disables the backward steppers on the first page', async () => {
      const screen = await render(<PlPagination count={9} defaultPage={1} showEdges />);

      expect(screen.getByRole('button', { name: 'Previous page' }).element()).toBeDisabled();
      expect(screen.getByRole('button', { name: 'First page' }).element()).toBeDisabled();
      expect(screen.getByRole('button', { name: 'Next page' }).element()).toBeEnabled();
    });

    it('disables the forward steppers on the last page', async () => {
      const screen = await render(<PlPagination count={9} defaultPage={9} showEdges />);

      expect(screen.getByRole('button', { name: 'Next page' }).element()).toBeDisabled();
      expect(screen.getByRole('button', { name: 'Last page' }).element()).toBeDisabled();
    });
  });

  describe('changing page', () => {
    it('moves the current page when a number is pressed, uncontrolled', async () => {
      const screen = await render(<PlPagination count={5} />);

      await screen.getByRole('button', { name: 'Page 4' }).click();

      expect(screen.getByRole('button', { name: 'Page 4' }).element()).toHaveAttribute(
        'aria-current',
        'page'
      );
    });

    it('reports the new page to `onPageChange`', async () => {
      const onPageChange = vi.fn();
      const screen = await render(<PlPagination count={5} onPageChange={onPageChange} />);

      await screen.getByRole('button', { name: 'Page 3' }).click();

      expect(onPageChange).toHaveBeenCalledWith(3);
    });

    it('steps by one from the arrows', async () => {
      const onPageChange = vi.fn();
      const screen = await render(
        <PlPagination count={9} defaultPage={5} onPageChange={onPageChange} />
      );

      await screen.getByRole('button', { name: 'Next page' }).click();

      expect(onPageChange).toHaveBeenCalledWith(6);
    });

    it('obeys `page` rather than the press when controlled', async () => {
      const screen = await render(<PlPagination count={5} page={2} onPageChange={() => {}} />);

      await screen.getByRole('button', { name: 'Page 4' }).click();

      expect(screen.getByRole('button', { name: 'Page 2' }).element()).toHaveAttribute(
        'aria-current',
        'page'
      );
    });

    it('does not fire when the current page is pressed again', async () => {
      const onPageChange = vi.fn();
      const screen = await render(
        <PlPagination count={5} defaultPage={2} onPageChange={onPageChange} />
      );

      await screen.getByRole('button', { name: 'Page 2' }).click();

      expect(onPageChange).not.toHaveBeenCalled();
    });

    it('disables every control when the row is disabled', async () => {
      const screen = await render(<PlPagination count={5} disabled />);

      for (const button of screen.getByRole('button').elements()) {
        expect(button).toBeDisabled();
      }
    });
  });

  describe('links', () => {
    it('renders the pages as real links when `getPageHref` is given', async () => {
      const screen = await render(
        <PlPagination count={5} getPageHref={(page) => `/posts?page=${page}`} />
      );
      const link = screen.getByRole('link', { name: 'Page 3' }).element();

      expect(link.tagName).toBe('A');
      expect(link).toHaveAttribute('href', '/posts?page=3');
    });

    it('wears the element `renderLink` returns, with the address already built', async () => {
      const RouterLink = (props: React.ComponentPropsWithoutRef<'a'>) => (
        <a data-router="" {...props} />
      );
      const screen = await render(
        <PlPagination
          count={5}
          getPageHref={(page) => `/posts?page=${page}`}
          renderLink={(_page, href) => <RouterLink href={href} />}
        />
      );
      const link = screen.getByRole('link', { name: 'Page 3' }).element();

      expect(link).toHaveAttribute('data-router');
      expect(link).toHaveAttribute('href', '/posts?page=3');
    });

    it('hands `renderLink` the page beside its address', async () => {
      const seen: Array<[number, string]> = [];
      await render(
        <PlPagination
          count={3}
          getPageHref={(page) => `/posts?page=${page}`}
          renderLink={(page, href) => {
            seen.push([page, href]);
            return <a href={href} />;
          }}
        />
      );

      expect(seen).toContainEqual([3, '/posts?page=3']);
    });

    it('keeps `rel` on a `renderLink` stepper', async () => {
      const screen = await render(
        <PlPagination
          count={9}
          defaultPage={5}
          getPageHref={(page) => `/posts?page=${page}`}
          renderLink={(_page, href) => <a data-router="" href={href} />}
        />
      );

      expect(screen.getByRole('link', { name: 'Next page' }).element()).toHaveAttribute(
        'rel',
        'next'
      );
    });

    it('leaves the current page a button, since a link cannot be disabled', async () => {
      const screen = await render(
        <PlPagination count={5} defaultPage={2} getPageHref={(page) => `/posts?page=${page}`} />
      );

      expect(screen.getByRole('link', { name: 'Page 2' }).query()).toBeNull();
      expect(screen.getByRole('button', { name: 'Page 2' }).element().tagName).toBe('BUTTON');
    });

    it('marks the two arrows with `rel`', async () => {
      const screen = await render(
        <PlPagination count={9} defaultPage={5} getPageHref={(page) => `/posts?page=${page}`} />
      );

      expect(screen.getByRole('link', { name: 'Previous page' }).element()).toHaveAttribute(
        'rel',
        'prev'
      );
      expect(screen.getByRole('link', { name: 'Next page' }).element()).toHaveAttribute(
        'rel',
        'next'
      );
    });

    it('lets the link navigate on its own when no handler is given', async () => {
      const screen = await render(
        <PlPagination count={5} getPageHref={(page) => `/posts?page=${page}`} />
      );

      expect(clickAndReadCancellation(screen.getByRole('link', { name: 'Page 3' }).element())).toBe(
        false
      );
    });

    it('cancels the navigation when a handler wants the press', async () => {
      const onPageChange = vi.fn();
      const screen = await render(
        <PlPagination
          count={5}
          onPageChange={onPageChange}
          getPageHref={(page) => `/posts?page=${page}`}
        />
      );

      expect(clickAndReadCancellation(screen.getByRole('link', { name: 'Page 3' }).element())).toBe(
        true
      );
      expect(onPageChange).toHaveBeenCalledWith(3);
    });
  });
});
