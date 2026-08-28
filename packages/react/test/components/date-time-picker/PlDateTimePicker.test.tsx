import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlDateTimePicker } from 'plass-ui';
import { fullDate, mediumDate } from '../../support/dates';

/** Half past nine on 27 July 2026, so nothing here depends on when it is run. */
const MOMENT = new Date(2026, 6, 27, 9, 30);
const JULY_15 = new Date(2026, 6, 15);
const JULY_26 = new Date(2026, 6, 26);
const AUGUST_3 = new Date(2026, 7, 3, 14, 0);

describe('PlDateTimePicker', () => {
  describe('rendering', () => {
    it('renders a trigger', async () => {
      const screen = await render(<PlDateTimePicker label="Starts" />);

      await expect.element(screen.getByRole('button', { name: 'Starts' })).toBeInTheDocument();
    });

    it('writes the day and the time together', async () => {
      const screen = await render(<PlDateTimePicker locale="en-GB" defaultValue={MOMENT} />);
      const trigger = screen.getByRole('button').element();

      expect(trigger.textContent).toContain(mediumDate(MOMENT));
      expect(trigger.textContent).toContain('9:30');
    });

    it('shows the placeholder while nothing is chosen', async () => {
      const screen = await render(<PlDateTimePicker placeholder="Pick a moment" />);

      await expect.element(screen.getByText('Pick a moment')).toBeInTheDocument();
    });

    it('reflects a changed value on re-render', async () => {
      const screen = await render(
        <PlDateTimePicker locale="en-GB" value={MOMENT} onValueChange={() => {}} />
      );

      expect(screen.getByRole('button').element().textContent).toContain(mediumDate(MOMENT));

      await screen.rerender(
        <PlDateTimePicker locale="en-GB" value={AUGUST_3} onValueChange={() => {}} />
      );

      expect(screen.getByRole('button').element().textContent).toContain(mediumDate(AUGUST_3));
    });
  });

  describe('the popup', () => {
    it('holds a calendar and a clock side by side', async () => {
      const screen = await render(
        <PlDateTimePicker locale="en-GB" defaultValue={MOMENT} defaultOpen />
      );

      await expect.element(screen.getByRole('grid')).toBeInTheDocument();
      await expect.element(screen.getByRole('listbox', { name: 'Hour' })).toBeInTheDocument();
      await expect.element(screen.getByRole('listbox', { name: 'Minute' })).toBeInTheDocument();
    });

    it('measures both panels off one cell ladder', async () => {
      const screen = await render(
        <PlDateTimePicker locale="en-GB" defaultValue={MOMENT} defaultOpen />
      );

      // The calendar's grid is seven cells tall counting its header, and the
      // clock's columns are seven of the same cell — which is what makes the
      // popup one rectangle rather than two of different heights pushed
      // together. Both read the height off `--p-cell`, so the assertion is that
      // they are given the same one. (Heights themselves cannot be measured
      // here: no component test loads the stylesheet.)
      const cellOf = (element: Element) =>
        (element.closest('[style*="--p-cell"]') as HTMLElement | null)?.style.getPropertyValue(
          '--p-cell'
        );

      const calendar = cellOf(screen.getByRole('grid').element());
      const clock = cellOf(screen.getByRole('listbox', { name: 'Hour' }).element());

      expect(calendar).toBeTruthy();
      expect(clock).toBe(calendar);
    });
  });

  describe('choosing', () => {
    it('changes the day and leaves the clock alone', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlDateTimePicker
          locale="en-GB"
          defaultValue={MOMENT}
          defaultOpen
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('gridcell', { name: fullDate(JULY_15) }).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalled());

      const chosen = onValueChange.mock.calls[0][0] as Date;

      expect(chosen.getDate()).toBe(15);
      expect(chosen.getHours()).toBe(9);
      expect(chosen.getMinutes()).toBe(30);
    });

    it('changes the clock and leaves the day alone', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlDateTimePicker
          locale="en-GB"
          defaultValue={MOMENT}
          defaultOpen
          onValueChange={onValueChange}
        />
      );

      const hours = screen.getByRole('listbox', { name: 'Hour' }).element();

      (hours.querySelectorAll('[role="option"]')[14] as HTMLElement).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalled());

      const chosen = onValueChange.mock.calls[0][0] as Date;

      expect(chosen.getDate()).toBe(27);
      expect(chosen.getHours()).toBe(14);
    });

    it('stays open after a day, because a moment is two answers', async () => {
      const screen = await render(
        <PlDateTimePicker locale="en-GB" defaultValue={MOMENT} defaultOpen />
      );

      await screen.getByRole('gridcell', { name: fullDate(JULY_15) }).click();

      await expect.element(screen.getByRole('listbox', { name: 'Hour' })).toBeInTheDocument();
    });

    it('closes after a day when told to', async () => {
      const screen = await render(
        <PlDateTimePicker locale="en-GB" defaultValue={MOMENT} defaultOpen closeOnSelect />
      );

      await screen.getByRole('gridcell', { name: fullDate(JULY_15) }).click();

      await vi.waitFor(() => expect(screen.getByRole('grid').query()).toBeNull());
    });

    it('writes the clock onto today while no day has been chosen', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlDateTimePicker locale="en-GB" defaultOpen onValueChange={onValueChange} />
      );

      const hours = screen.getByRole('listbox', { name: 'Hour' }).element();

      (hours.querySelectorAll('[role="option"]')[7] as HTMLElement).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalled());

      const chosen = onValueChange.mock.calls[0][0] as Date;

      expect(chosen.getDate()).toBe(new Date().getDate());
      expect(chosen.getHours()).toBe(7);
    });
  });

  describe('bounds', () => {
    it('leaves the bound day selectable and greys out the hours before it', async () => {
      const screen = await render(
        <PlDateTimePicker
          locale="en-GB"
          defaultValue={new Date(2026, 6, 27, 12, 0)}
          defaultOpen
          minDate={new Date(2026, 6, 27, 9, 30)}
        />
      );

      // The 27th itself is still available — the bound is inside it.
      await expect
        .element(screen.getByRole('gridcell', { name: fullDate(MOMENT) }))
        .not.toHaveAttribute('aria-disabled');

      const hours = screen.getByRole('listbox', { name: 'Hour' }).element();
      const rows = hours.querySelectorAll('[role="option"]');

      expect(rows[8]).toHaveAttribute('aria-disabled', 'true');
      expect(rows[9]).not.toHaveAttribute('aria-disabled');
    });

    it('blocks the day before the bound entirely', async () => {
      const screen = await render(
        <PlDateTimePicker
          locale="en-GB"
          defaultValue={new Date(2026, 6, 27, 12, 0)}
          defaultOpen
          minDate={new Date(2026, 6, 27, 9, 30)}
        />
      );

      await expect
        .element(screen.getByRole('gridcell', { name: fullDate(JULY_26) }))
        .toHaveAttribute('aria-disabled', 'true');
    });

    it('blocks the rows a rule says are unavailable', async () => {
      const screen = await render(
        <PlDateTimePicker
          locale="en-GB"
          defaultValue={MOMENT}
          defaultOpen
          shouldDisableTime={(value, unit) => unit === 'hour' && value.getHours() < 8}
        />
      );

      const hours = screen.getByRole('listbox', { name: 'Hour' }).element();

      expect(hours.querySelectorAll('[role="option"]')[3]).toHaveAttribute('aria-disabled', 'true');
    });
  });

  describe('the footer', () => {
    it('always offers Done, because the popup stays up', async () => {
      const screen = await render(<PlDateTimePicker defaultValue={MOMENT} defaultOpen />);

      await expect.element(screen.getByRole('button', { name: 'Done' })).toBeInTheDocument();
    });

    it('jumps to this moment without closing', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlDateTimePicker defaultValue={MOMENT} defaultOpen onValueChange={onValueChange} />
      );

      await screen.getByRole('button', { name: 'Now' }).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalled());

      const chosen = onValueChange.mock.calls[0][0] as Date;

      expect(chosen.getDate()).toBe(new Date().getDate());
      // Still up: Now is a shortcut, not an answer.
      await expect.element(screen.getByRole('grid')).toBeInTheDocument();
    });
  });

  describe('forms', () => {
    it('submits the moment as a local `YYYY-MM-DDTHH:MM`, never as UTC', async () => {
      const onSubmit = vi.fn((event: React.FormEvent<HTMLFormElement>) => {
        event.preventDefault();
      });
      const screen = await render(
        <form onSubmit={onSubmit}>
          <PlDateTimePicker name="starts" defaultValue={MOMENT} />
          <button type="submit">Save</button>
        </form>
      );

      await screen.getByRole('button', { name: 'Save' }).click();

      const form = screen.getByRole('button', { name: 'Save' }).element().closest('form');

      expect(new FormData(form as HTMLFormElement).get('starts')).toBe('2026-07-27T09:30');
    });
  });
});
