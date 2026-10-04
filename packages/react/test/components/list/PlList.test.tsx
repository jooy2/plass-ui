import { describe, expect, it, vi } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlList, PlListItem } from 'plass-ui';
import { RouterLink } from '../../support/router';

describe('PlList', () => {
  describe('the stack', () => {
    it('renders a list with its rows in it', async () => {
      const screen = await render(
        <PlList>
          <PlListItem>Inbox</PlListItem>
          <PlListItem>Drafts</PlListItem>
        </PlList>
      );

      await expect.element(screen.getByRole('list')).toBeInTheDocument();
      expect(screen.getByRole('listitem').all()).toHaveLength(2);
    });

    it('says `role="list"` out loud, because a reset takes it away', async () => {
      const screen = await render(
        <PlList>
          <PlListItem>Inbox</PlListItem>
        </PlList>
      );

      expect(screen.getByRole('list').element()).toHaveAttribute('role', 'list');
    });

    it('renders an ordered list when asked', async () => {
      const screen = await render(
        <PlList render={<ol />}>
          <PlListItem>First</PlListItem>
        </PlList>
      );

      expect(screen.getByRole('list').element().tagName).toBe('OL');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <PlList className="my-own-class">
          <PlListItem>Inbox</PlListItem>
        </PlList>
      );

      expect(screen.getByRole('list').element()).toHaveClass('my-own-class');
    });

    it('forwards unknown props to the element', async () => {
      const screen = await render(
        <PlList data-testid="stack">
          <PlListItem>Inbox</PlListItem>
        </PlList>
      );

      expect(screen.getByTestId('stack').element()).toBeInTheDocument();
    });
  });

  describe('a row', () => {
    it('renders its label and its description', async () => {
      const screen = await render(
        <PlList>
          <PlListItem description="Three unread">Inbox</PlListItem>
        </PlList>
      );

      await expect.element(screen.getByText('Inbox')).toBeInTheDocument();
      await expect.element(screen.getByText('Three unread')).toBeInTheDocument();
    });

    it('is not pressable on its own', async () => {
      const screen = await render(
        <PlList>
          <PlListItem>Inbox</PlListItem>
        </PlList>
      );

      expect(screen.getByRole('button').query()).toBeNull();
      expect(screen.getByRole('link').query()).toBeNull();
    });

    it('becomes a real button with `onClick`', async () => {
      const onClick = vi.fn();
      const screen = await render(
        <PlList>
          <PlListItem onClick={onClick}>Inbox</PlListItem>
        </PlList>
      );

      await screen.getByRole('button', { name: 'Inbox' }).click();

      expect(onClick).toHaveBeenCalledTimes(1);
    });

    it('becomes a real link with `href`', async () => {
      const screen = await render(
        <PlList>
          <PlListItem href="/inbox">Inbox</PlListItem>
        </PlList>
      );

      expect(screen.getByRole('link', { name: 'Inbox' }).element()).toHaveAttribute(
        'href',
        '/inbox'
      );
    });

    it('reports a chosen link as the current page and a chosen button as the current one', async () => {
      const screen = await render(
        <PlList>
          <PlListItem selected href="/inbox">
            Inbox
          </PlListItem>
          <PlListItem selected onClick={() => {}}>
            Drafts
          </PlListItem>
        </PlList>
      );

      expect(screen.getByRole('link', { name: 'Inbox' }).element()).toHaveAttribute(
        'aria-current',
        'page'
      );
      expect(screen.getByRole('button', { name: 'Drafts' }).element()).toHaveAttribute(
        'aria-current',
        'true'
      );
    });

    it("draws its link on the element `render` gives it, with the row's own marks", async () => {
      const screen = await render(
        <PlList>
          <PlListItem selected render={<RouterLink href="/inbox" />}>
            Inbox
          </PlListItem>
        </PlList>
      );

      const link = screen.getByRole('link', { name: 'Inbox' }).element();

      expect(link).toHaveAttribute('data-router');
      expect(link).toHaveAttribute('href', '/inbox');
      expect(link).toHaveAttribute('aria-current', 'page');
      expect(link).toHaveClass('cursor-pointer', 'bg-(--p-soft-press)');
    });

    it("follows a router's link from the keyboard, through the row's handler and the router's", async () => {
      const onClick = vi.fn();
      const onNavigate = vi.fn();
      const screen = await render(
        <PlList>
          <PlListItem
            href="/inbox"
            onClick={onClick}
            render={<RouterLink href="/en/inbox" onNavigate={onNavigate} />}
          >
            Inbox
          </PlListItem>
        </PlList>
      );

      const link = screen.getByRole('link', { name: 'Inbox' });

      // An `href` on the element wins over the row's own.
      expect(link.element()).toHaveAttribute('href', '/en/inbox');

      (link.element() as HTMLElement).focus();
      await expect.element(link).toHaveFocus();
      await userEvent.keyboard('{Enter}');

      expect(onClick).toHaveBeenCalledOnce();
      expect(onNavigate).toHaveBeenCalledWith('/en/inbox');
    });

    it("leaves a disabled row's `render` out, since the row is not a link", async () => {
      const screen = await render(
        <PlList>
          <PlListItem disabled render={<RouterLink href="/inbox" />}>
            Inbox
          </PlListItem>
        </PlList>
      );

      expect(screen.getByRole('link').query()).toBeNull();
      expect(document.querySelector('[data-router]')).toBeNull();
      expect(screen.getByText('Inbox').element().closest('[aria-disabled]')).not.toBeNull();
    });

    it('stops being pressable when disabled', async () => {
      const screen = await render(
        <PlList>
          <PlListItem disabled onClick={() => {}}>
            Inbox
          </PlListItem>
        </PlList>
      );

      expect(screen.getByRole('button').query()).toBeNull();
      expect(screen.getByText('Inbox').element().closest('[aria-disabled]')).not.toBeNull();
    });

    it('keeps `action` outside the pressable area', async () => {
      const screen = await render(
        <PlList>
          <PlListItem onClick={() => {}} action={<button type="button">Remove</button>}>
            Inbox
          </PlListItem>
        </PlList>
      );

      const row = screen.getByRole('button', { name: 'Inbox' }).element();

      expect(row.querySelector('button')).toBeNull();
      await expect.element(screen.getByRole('button', { name: 'Remove' })).toBeInTheDocument();
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(
        <PlList>
          <PlListItem>Inbox</PlListItem>
        </PlList>
      );

      await screen.rerender(
        <PlList>
          <PlListItem>Archive</PlListItem>
        </PlList>
      );

      await expect.element(screen.getByText('Archive')).toBeInTheDocument();
      expect(screen.getByText('Inbox').query()).toBeNull();
    });
  });

  describe('what a row inherits', () => {
    it('takes the stack’s dividers rather than its own', async () => {
      const screen = await render(
        <PlList dividers>
          <PlListItem>Inbox</PlListItem>
          <PlListItem>Drafts</PlListItem>
        </PlList>
      );

      expect(screen.getByRole('list').element().className).toContain('li+li');
    });
  });
});
