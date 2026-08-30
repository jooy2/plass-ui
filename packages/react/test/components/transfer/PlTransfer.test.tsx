import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlTransfer, type PlTransferItem } from 'plass-ui';

const items: PlTransferItem[] = [
  { value: 'name', label: 'Name' },
  { value: 'email', label: 'Email' },
  { value: 'role', label: 'Role' },
  { value: 'id', label: 'Identifier', disabled: true }
];

/*
 * Nothing loads Tailwind into the test run, so a checkbox's tick and an icon
 * button are boxes with no size — Playwright will not click either of them.
 * Every press here is a DOM click on the real element, which is the same event
 * a pointer would deliver and the path CLAUDE.md already documents for the
 * components whose visible part is a styled `<span>`.
 */
function press(element: Element | null | undefined) {
  (element as HTMLElement).click();
}

describe('PlTransfer', () => {
  describe('the two lists', () => {
    it('puts everything on the leading side to begin with', async () => {
      const screen = await render(<PlTransfer items={items} />);

      await expect.element(screen.getByText('Available')).toBeVisible();
      await expect.element(screen.getByText('Selected')).toBeVisible();
      expect(screen.getByRole('checkbox', { name: 'Name' }).query()).not.toBeNull();
    });

    it('shows what has already been chosen on the trailing side', async () => {
      const screen = await render(<PlTransfer items={items} defaultValue={['email']} />);

      // The count in each heading says how many of that list are ticked out of
      // how many it holds.
      await expect.element(screen.getByText('0/3')).toBeVisible();
      await expect.element(screen.getByText('0/1')).toBeVisible();
    });

    it('takes headings of its own', async () => {
      const screen = await render(
        <PlTransfer items={items} sourceLabel="Columns" targetLabel="In the report" />
      );

      await expect.element(screen.getByText('Columns')).toBeVisible();
      await expect.element(screen.getByText('In the report')).toBeVisible();
    });

    it('says so when a list is empty', async () => {
      const screen = await render(<PlTransfer items={items} emptyLabel="Nothing yet" />);

      await expect.element(screen.getByText('Nothing yet')).toBeVisible();
    });
  });

  describe('moving', () => {
    it('sends the ticked rows across and drops their ticks', async () => {
      const onValueChange = vi.fn();

      const screen = await render(<PlTransfer items={items} onValueChange={onValueChange} />);

      press(screen.getByRole('checkbox', { name: 'Email' }).element());
      press(screen.getByRole('button', { name: 'Move to selected' }).element());

      await expect.poll(() => onValueChange.mock.calls.at(-1)?.[0]).toEqual(['email']);
      // The row arrived; it is not still waiting to be sent.
      expect(
        screen.getByRole('checkbox', { name: 'Email' }).element().getAttribute('aria-checked')
      ).toBe('false');
    });

    it('keeps the order of items on both sides', async () => {
      const onValueChange = vi.fn();

      const screen = await render(
        <PlTransfer items={items} defaultValue={['role']} onValueChange={onValueChange} />
      );

      press(screen.getByRole('checkbox', { name: 'Name' }).element());
      press(screen.getByRole('button', { name: 'Move to selected' }).element());

      // `name` comes before `role` in `items`, so it comes before it here.
      await expect.poll(() => onValueChange.mock.calls.at(-1)?.[0]).toEqual(['name', 'role']);
    });

    it('sends them back again', async () => {
      const onValueChange = vi.fn();

      const screen = await render(
        <PlTransfer items={items} defaultValue={['email']} onValueChange={onValueChange} />
      );

      press(screen.getByRole('checkbox', { name: 'Email' }).element());
      press(screen.getByRole('button', { name: 'Move to available' }).element());

      await expect.poll(() => onValueChange.mock.calls.at(-1)?.[0]).toEqual([]);
    });

    it('leaves the arrows disabled until something is ticked', async () => {
      const screen = await render(<PlTransfer items={items} />);

      const send = screen.getByRole('button', { name: 'Move to selected' });

      expect(send.element()).toBeDisabled();

      press(screen.getByRole('checkbox', { name: 'Name' }).element());

      await expect.poll(() => send.element().hasAttribute('disabled')).toBe(false);
    });

    it('never moves a disabled row', async () => {
      const screen = await render(<PlTransfer items={items} />);

      expect(screen.getByRole('checkbox', { name: 'Identifier' }).element()).toHaveAttribute(
        'data-disabled'
      );
    });

    it('answers with what a controlled pair is given', async () => {
      const onValueChange = vi.fn();

      const screen = await render(
        <PlTransfer items={items} value={[]} onValueChange={onValueChange} />
      );

      press(screen.getByRole('checkbox', { name: 'Name' }).element());
      press(screen.getByRole('button', { name: 'Move to selected' }).element());

      await expect.poll(() => onValueChange.mock.calls.at(-1)?.[0]).toEqual(['name']);
      // All four rows are still on the leading side: the value is the caller's
      // now, and the tick went with the press whether or not it was accepted.
      await expect.element(screen.getByText('0/4')).toBeVisible();
    });
  });

  describe('the heading tick', () => {
    it('ticks every movable row in its own list', async () => {
      const screen = await render(<PlTransfer items={items} />);

      press(screen.getByRole('checkbox', { name: 'Select all' }).elements()[0]);

      // Three movable rows; the disabled one is not one of them.
      await expect.element(screen.getByText('3/4')).toBeVisible();
    });

    it('is disabled when its list has nothing movable in it', async () => {
      const screen = await render(<PlTransfer items={[]} />);

      for (const box of screen.getByRole('checkbox', { name: 'Select all' }).elements()) {
        expect(box).toHaveAttribute('data-disabled');
      }
    });
  });

  describe('searching', () => {
    it('is off until it is asked for', async () => {
      const screen = await render(<PlTransfer items={items} />);

      expect(screen.getByRole('textbox').query()).toBeNull();
    });

    it('narrows one list without touching the other', async () => {
      const screen = await render(<PlTransfer items={items} searchable defaultValue={['role']} />);

      await screen.getByRole('textbox', { name: 'Search' }).first().fill('ema');

      await expect.poll(() => screen.getByRole('checkbox', { name: 'Name' }).query()).toBeNull();
      expect(screen.getByRole('checkbox', { name: 'Email' }).query()).not.toBeNull();
      // The trailing list still holds its own row.
      expect(screen.getByRole('checkbox', { name: 'Role' }).query()).not.toBeNull();
    });

    it('folds accents and case, so cafe finds Café', async () => {
      const screen = await render(
        <PlTransfer items={[{ value: 'cafe', label: 'Café' }]} searchable />
      );

      await screen.getByRole('textbox', { name: 'Search' }).first().fill('CAFE');

      await expect
        .poll(() => screen.getByRole('checkbox', { name: 'Café' }).query())
        .not.toBeNull();
    });

    it('keeps a row whose label is not a string, which no filter could match', async () => {
      const screen = await render(
        <PlTransfer items={[{ value: 'x', label: <em>Emphatic</em> }]} searchable />
      );

      await screen.getByRole('textbox', { name: 'Search' }).first().fill('zzz');

      await expect.element(screen.getByText('Emphatic')).toBeVisible();
    });
  });

  describe('the shell', () => {
    it('is never dyed, whatever colour it is given', async () => {
      const screen = await render(<PlTransfer data-testid="pair" items={items} color="danger" />);

      const panel = screen.getByTestId('pair').element().firstElementChild as HTMLElement;

      expect(panel.getAttribute('style') ?? '').not.toContain('--p-fill');
      expect(panel.getAttribute('style') ?? '').toContain('--plass-danger-ring');
    });

    it('takes a height for each list', async () => {
      const screen = await render(<PlTransfer data-testid="pair" items={items} height="12rem" />);

      const scroller = screen
        .getByTestId('pair')
        .element()
        .querySelector<HTMLElement>('.overflow-y-auto');

      expect(scroller?.style.height).toBe('12rem');
    });

    it('stops everything at once when it is disabled', async () => {
      const screen = await render(<PlTransfer items={items} disabled />);

      for (const box of screen.getByRole('checkbox').elements()) {
        expect(box).toHaveAttribute('data-disabled');
      }
      for (const button of screen.getByRole('button').elements()) {
        expect(button).toBeDisabled();
      }
    });
  });
});
