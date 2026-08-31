import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlCalendar } from 'plass-ui';
import { fullDate } from '../../support/dates';

/** Fixed days to work against, so nothing here depends on when it is run. */
const JULY_27 = new Date(2026, 6, 27);
const JULY_15 = new Date(2026, 6, 15);
const JULY_18 = new Date(2026, 6, 18);
const AUGUST_3 = new Date(2026, 7, 3);

describe('PlCalendar', () => {
  describe('rendering', () => {
    it('draws a grid without anything having to be opened', async () => {
      const screen = await render(<PlCalendar locale="en-GB" defaultMonth={JULY_27} />);

      // The whole difference from a PlDatePicker: there is no trigger.
      await expect.element(screen.getByRole('grid')).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Departure' }).query()).toBeNull();
    });

    it('opens on the month of its value', async () => {
      const screen = await render(<PlCalendar locale="en-GB" defaultValue={AUGUST_3} />);

      await expect
        .element(screen.getByRole('gridcell', { name: fullDate(AUGUST_3) }))
        .toBeVisible();
    });

    it('opens on defaultMonth when there is no value', async () => {
      const screen = await render(<PlCalendar locale="en-GB" defaultMonth={JULY_27} />);

      await expect.element(screen.getByRole('gridcell', { name: fullDate(JULY_15) })).toBeVisible();
    });
  });

  describe('choosing a day', () => {
    it('reports the day that was pressed', async () => {
      const onValueChange = vi.fn();

      const screen = await render(
        <PlCalendar locale="en-GB" defaultMonth={JULY_27} onValueChange={onValueChange} />
      );

      await screen.getByRole('gridcell', { name: fullDate(JULY_15) }).click();

      expect(onValueChange).toHaveBeenCalledTimes(1);
      expect(onValueChange.mock.calls[0][0]).toEqual(JULY_15);
    });

    it('keeps its own value when nothing controls it', async () => {
      const screen = await render(<PlCalendar locale="en-GB" defaultMonth={JULY_27} />);

      await screen.getByRole('gridcell', { name: fullDate(JULY_15) }).click();

      await expect
        .element(screen.getByRole('gridcell', { name: fullDate(JULY_15) }))
        .toHaveAttribute('aria-selected', 'true');
    });

    it('does not move a controlled value on its own', async () => {
      const screen = await render(
        <PlCalendar
          locale="en-GB"
          defaultMonth={JULY_27}
          value={JULY_18}
          onValueChange={() => {}}
        />
      );

      await screen.getByRole('gridcell', { name: fullDate(JULY_15) }).click();

      await expect
        .element(screen.getByRole('gridcell', { name: fullDate(JULY_18) }))
        .toHaveAttribute('aria-selected', 'true');
    });

    it('reflects a changed value on re-render', async () => {
      const screen = await render(
        <PlCalendar locale="en-GB" value={JULY_18} onValueChange={() => {}} />
      );

      await screen.rerender(<PlCalendar locale="en-GB" value={JULY_15} onValueChange={() => {}} />);

      await expect
        .element(screen.getByRole('gridcell', { name: fullDate(JULY_15) }))
        .toHaveAttribute('aria-selected', 'true');
    });

    it('keeps the time of day a value already carried', async () => {
      const onValueChange = vi.fn();
      const withTime = new Date(2026, 6, 27, 14, 30);

      const screen = await render(
        <PlCalendar locale="en-GB" defaultValue={withTime} onValueChange={onValueChange} />
      );

      await screen.getByRole('gridcell', { name: fullDate(JULY_15) }).click();

      const next = onValueChange.mock.calls[0][0] as Date;

      expect([next.getHours(), next.getMinutes()]).toEqual([14, 30]);
    });
  });

  describe('the month on screen', () => {
    it('moves with its own header', async () => {
      const screen = await render(<PlCalendar locale="en-GB" defaultMonth={JULY_27} />);

      await screen.getByRole('button', { name: 'Next month' }).click();

      await expect
        .element(screen.getByRole('gridcell', { name: fullDate(AUGUST_3) }))
        .toBeVisible();
    });

    it('reports the month it moved to', async () => {
      const onMonthChange = vi.fn();

      const screen = await render(
        <PlCalendar locale="en-GB" defaultMonth={JULY_27} onMonthChange={onMonthChange} />
      );

      await screen.getByRole('button', { name: 'Next month' }).click();

      expect(onMonthChange).toHaveBeenCalledTimes(1);
      expect((onMonthChange.mock.calls[0][0] as Date).getMonth()).toBe(7);
    });

    it('stays where a controlling caller put it', async () => {
      const screen = await render(
        <PlCalendar locale="en-GB" month={new Date(2026, 6, 1)} onMonthChange={() => {}} />
      );

      await screen.getByRole('button', { name: 'Next month' }).click();

      // Controlled: the header asked, and nothing answered.
      await expect.element(screen.getByRole('gridcell', { name: fullDate(JULY_15) })).toBeVisible();
    });
  });

  describe('precision', () => {
    it('stops at the month grid when asked for a month', async () => {
      const onValueChange = vi.fn();

      const screen = await render(
        <PlCalendar
          locale="en-GB"
          precision="month"
          defaultMonth={JULY_27}
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('gridcell', { name: 'October 2026' }).click();

      const next = onValueChange.mock.calls[0][0] as Date;

      // The 1st of October, never whichever day the cursor was resting on.
      expect([next.getFullYear(), next.getMonth(), next.getDate()]).toEqual([2026, 9, 1]);
      expect(screen.getByRole('gridcell', { name: fullDate(JULY_15) }).query()).toBeNull();
    });
  });

  describe('bounds', () => {
    it('blocks a day outside minDate', async () => {
      const screen = await render(
        <PlCalendar locale="en-GB" defaultMonth={JULY_27} minDate={JULY_18} />
      );

      await expect
        .element(screen.getByRole('gridcell', { name: fullDate(JULY_15) }))
        .toHaveAttribute('aria-disabled', 'true');
    });

    it('blocks the days shouldDisableDate rejects', async () => {
      const screen = await render(
        <PlCalendar
          locale="en-GB"
          defaultMonth={JULY_27}
          shouldDisableDate={(date) => date.getDate() === 15}
        />
      );

      await expect
        .element(screen.getByRole('gridcell', { name: fullDate(JULY_15) }))
        .toHaveAttribute('aria-disabled', 'true');
      await expect
        .element(screen.getByRole('gridcell', { name: fullDate(JULY_18) }))
        .not.toHaveAttribute('aria-disabled', 'true');
    });
  });

  describe('disabled', () => {
    it('takes the whole grid out of reach', async () => {
      await render(<PlCalendar locale="en-GB" defaultMonth={JULY_27} disabled className="cal" />);

      // `inert` is one attribute rather than a `disabled` on forty-two cells.
      expect(document.querySelector('.cal')).toHaveAttribute('inert');
    });

    it('is reachable again when it is not disabled', async () => {
      await render(<PlCalendar locale="en-GB" defaultMonth={JULY_27} className="cal" />);

      expect(document.querySelector('.cal')).not.toHaveAttribute('inert');
    });
  });

  describe('in a form', () => {
    it('submits nothing until it has a value', async () => {
      await render(<PlCalendar locale="en-GB" defaultMonth={JULY_27} name="departure" />);

      expect(document.querySelector<HTMLInputElement>('input[name="departure"]')!.value).toBe('');
    });

    it('spells the day the way a native date input does', async () => {
      await render(<PlCalendar locale="en-GB" defaultValue={JULY_27} name="departure" />);

      expect(document.querySelector<HTMLInputElement>('input[name="departure"]')!.value).toBe(
        '2026-07-27'
      );
    });

    it('spells a month without the day', async () => {
      await render(
        <PlCalendar locale="en-GB" precision="month" defaultValue={JULY_27} name="expiry" />
      );

      expect(document.querySelector<HTMLInputElement>('input[name="expiry"]')!.value).toBe(
        '2026-07'
      );
    });

    it('has no hidden input without a name', async () => {
      await render(<PlCalendar locale="en-GB" defaultValue={JULY_27} />);

      expect(document.querySelector('input[type="hidden"]')).toBeNull();
    });
  });

  describe('caller styling', () => {
    it('keeps a caller-supplied class alongside its own', async () => {
      await render(<PlCalendar locale="en-GB" className="my-own-class" />);

      expect(document.querySelector('.my-own-class')).toHaveClass('inline-flex');
    });

    it('applies a caller style over the tokens it sets', async () => {
      await render(<PlCalendar locale="en-GB" className="cal" style={{ width: '300px' }} />);

      expect(document.querySelector<HTMLElement>('.cal')!.style.width).toBe('300px');
    });
  });
});
