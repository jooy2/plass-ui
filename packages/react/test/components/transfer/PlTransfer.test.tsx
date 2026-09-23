import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlTransfer, PlassProvider, type PlTransferItem } from 'plass-ui';
import { ko } from '../../../src/locales/ko.js';

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

    it('falls back to the label pack for a heading left empty', async () => {
      const screen = await render(
        <PlassProvider labels={{ transferAvailable: '사용 가능', transferSelected: '선택됨' }}>
          <PlTransfer items={items} sourceLabel="" targetLabel="" />
        </PlassProvider>
      );

      // An empty heading used to be the English word, whatever pack the page
      // was reading.
      await expect.element(screen.getByText('사용 가능')).toBeVisible();
      await expect.element(screen.getByText('선택됨')).toBeVisible();
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

    it('hands the focus to the first row that arrived and says how many moved', async () => {
      const screen = await render(<PlTransfer items={items} />);

      press(screen.getByRole('checkbox', { name: 'Email' }).element());
      press(screen.getByRole('checkbox', { name: 'Role' }).element());

      const send = screen.getByRole('button', { name: 'Move to selected' }).element();

      await expect.poll(() => send.hasAttribute('disabled')).toBe(false);
      (send as HTMLElement).focus();
      press(send);

      // The arrow is disabled by the move, and would have dropped the focus to
      // the page.
      await expect
        .poll(
          () => document.activeElement === screen.getByRole('checkbox', { name: 'Email' }).element()
        )
        .toBe(true);
      await expect
        .poll(() => screen.container.querySelector('[aria-live="polite"]')?.textContent)
        .toBe('2 items moved to Selected');
    });

    it('keeps the focus in the list the rows were sent to when they are refused', async () => {
      const screen = await render(<PlTransfer items={items} value={[]} onValueChange={() => {}} />);

      press(screen.getByRole('checkbox', { name: 'Name' }).element());
      press(screen.getByRole('button', { name: 'Move to selected' }).element());

      await expect.poll(() => document.activeElement?.getAttribute('role')).toBe('group');

      const heading = document.getElementById(
        document.activeElement?.getAttribute('aria-labelledby') ?? ''
      );

      expect(heading?.textContent).toBe('Selected');
      // Nothing moved, so nothing is said.
      expect(screen.container.querySelector('[aria-live="polite"]')?.textContent).toBe('');
    });

    it('says the count in the words it was given', async () => {
      const screen = await render(
        <PlTransfer
          items={items}
          targetLabel="In the report"
          movedLabel={(count, list) => `${list}: +${count}`}
        />
      );

      press(screen.getByRole('checkbox', { name: 'Name' }).element());
      press(screen.getByRole('button', { name: 'Move to selected' }).element());

      await expect
        .poll(() => screen.container.querySelector('[aria-live="polite"]')?.textContent)
        .toBe('In the report: +1');
    });

    it('names a list whose heading is an element by the words it draws', async () => {
      const screen = await render(
        <PlTransfer
          items={items}
          targetLabel={
            <>
              In the <strong>report</strong>
            </>
          }
        />
      );

      press(screen.getByRole('checkbox', { name: 'Name' }).element());
      press(screen.getByRole('button', { name: 'Move to selected' }).element());

      // It used to be the pack's "Selected", a name the page never shows.
      await expect
        .poll(() => screen.container.querySelector('[aria-live="polite"]')?.textContent)
        .toBe('1 item moved to In the report');
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

    it('turns both arrows towards their own lists under RTL', async () => {
      const screen = await render(<PlTransfer items={items} />);

      // Nothing loads Tailwind here, so the turn is read off the classes: the
      // arrow to the selected list turns only under RTL, the one back only
      // outside it.
      const glyph = (name: string) =>
        screen.getByRole('button', { name }).element().querySelector('svg')?.parentElement
          ?.className;

      expect(glyph('Move to selected')).toContain('rtl:rotate-180');
      expect(glyph('Move to selected')).not.toMatch(/(^|\s)rotate-180/);
      expect(glyph('Move to available')).toMatch(/(^|\s)rotate-180(\s|$)/);
      expect(glyph('Move to available')).toContain('rtl:rotate-0');
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

    it('drops the tick of a row whose item is gone', async () => {
      const screen = await render(<PlTransfer items={items} />);

      press(screen.getByRole('checkbox', { name: 'Role' }).element());

      await expect.element(screen.getByText('1/4')).toBeVisible();

      await screen.rerender(<PlTransfer items={items.filter((item) => item.value !== 'role')} />);
      await expect.element(screen.getByText('0/3')).toBeVisible();

      await screen.rerender(<PlTransfer items={items} />);

      // The row is back, and it is not still waiting to be moved.
      await expect.element(screen.getByText('0/4')).toBeVisible();
      expect(
        screen.getByRole('checkbox', { name: 'Role' }).element().getAttribute('aria-checked')
      ).toBe('false');
      expect(screen.getByRole('button', { name: 'Move to selected' }).element()).toBeDisabled();
    });
  });

  describe('the heading tick', () => {
    it('ticks every movable row in its own list', async () => {
      const screen = await render(<PlTransfer items={items} />);

      press(screen.getByRole('checkbox', { name: 'Select all in Available' }).element());

      // Three movable rows; the disabled one is not one of them.
      await expect.element(screen.getByText('3/4')).toBeVisible();
    });

    it('is disabled when its list has nothing movable in it', async () => {
      const screen = await render(<PlTransfer items={[]} />);

      for (const name of ['Select all in Available', 'Select all in Selected']) {
        expect(screen.getByRole('checkbox', { name }).element()).toHaveAttribute('data-disabled');
      }
    });

    it("is named by a sentence with its own list's heading in it", async () => {
      const screen = await render(<PlTransfer items={items} />);

      await expect
        .element(screen.getByRole('checkbox', { name: 'Select all in Available' }))
        .toBeInTheDocument();
      await expect
        .element(screen.getByRole('checkbox', { name: 'Select all in Selected' }))
        .toBeInTheDocument();
    });

    it('puts `selectAllLabel` before a heading that is a node as well as a string', async () => {
      const screen = await render(
        <PlTransfer
          items={items}
          selectAllLabel="Tick all of"
          sourceLabel="Columns"
          targetLabel={<strong>Shown</strong>}
        />
      );

      await expect
        .element(screen.getByRole('checkbox', { name: 'Tick all of Columns' }))
        .toBeInTheDocument();
      await expect
        .element(screen.getByRole('checkbox', { name: 'Tick all of Shown' }))
        .toBeInTheDocument();
    });

    it("lets the label pack put the list's name where its language puts it", async () => {
      const screen = await render(
        <PlassProvider labels={ko}>
          <PlTransfer items={items} />
        </PlassProvider>
      );

      // Korean says the list before the verb. Joining the pack's `selectAll`
      // and the heading used to read "전체 선택 사용 가능".
      await expect
        .element(screen.getByRole('checkbox', { name: '‘사용 가능’ 목록 전체 선택' }))
        .toBeInTheDocument();
      await expect
        .element(screen.getByRole('checkbox', { name: '‘선택됨’ 목록 전체 선택' }))
        .toBeInTheDocument();
    });

    it("calls a heading with no words by the pack's name for its list", async () => {
      const screen = await render(
        <PlTransfer items={items} targetLabel={<svg aria-hidden="true" data-testid="mark" />} />
      );

      await expect
        .element(screen.getByRole('checkbox', { name: 'Select all in Selected' }))
        .toBeInTheDocument();
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
