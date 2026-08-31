import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlDatePicker } from 'plass-ui';
import { fullDate, mediumDate, monthAndYear } from '../../support/dates';

/** A fixed day to work against, so nothing here depends on when it is run. */
const JULY_27 = new Date(2026, 6, 27);
const JULY_15 = new Date(2026, 6, 15);
const JULY_18 = new Date(2026, 6, 18);
const AUGUST_3 = new Date(2026, 7, 3);

describe('PlDatePicker', () => {
  describe('rendering', () => {
    it('renders a trigger', async () => {
      const screen = await render(<PlDatePicker label="Departure" />);

      await expect.element(screen.getByRole('button', { name: 'Departure' })).toBeInTheDocument();
    });

    it('shows the placeholder while nothing is chosen', async () => {
      const screen = await render(<PlDatePicker placeholder="Pick a day" />);

      await expect.element(screen.getByText('Pick a day')).toBeInTheDocument();
    });

    it('writes the chosen date the way the locale does', async () => {
      const screen = await render(<PlDatePicker locale="en-GB" defaultValue={JULY_27} />);

      await expect.element(screen.getByRole('button')).toHaveTextContent(mediumDate(JULY_27));
    });

    it('takes an Intl format', async () => {
      const screen = await render(
        <PlDatePicker locale="en-GB" defaultValue={JULY_27} format={{ dateStyle: 'full' }} />
      );

      await expect.element(screen.getByRole('button')).toHaveTextContent(fullDate(JULY_27));
    });

    it('renders the label, the description and the error', async () => {
      const screen = await render(
        <PlDatePicker label="Departure" description="When you leave." error="Pick a day." />
      );

      await expect.element(screen.getByText('When you leave.')).toBeInTheDocument();
      await expect.element(screen.getByText('Pick a day.')).toBeInTheDocument();
    });

    it('marks the trigger invalid when there is an error', async () => {
      const screen = await render(<PlDatePicker error="Pick a day." />);

      expect(screen.getByRole('button').element()).toHaveAttribute('aria-invalid', 'true');
    });

    it('reflects a changed value on re-render', async () => {
      const screen = await render(
        <PlDatePicker locale="en-GB" value={JULY_27} onValueChange={() => {}} />
      );

      await expect.element(screen.getByRole('button')).toHaveTextContent(mediumDate(JULY_27));

      await screen.rerender(
        <PlDatePicker locale="en-GB" value={AUGUST_3} onValueChange={() => {}} />
      );

      await expect.element(screen.getByRole('button')).toHaveTextContent(mediumDate(AUGUST_3));
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      await render(<PlDatePicker className="my-own-class" />);

      expect(document.querySelector('.my-own-class')).not.toBeNull();
    });
  });

  describe('the calendar', () => {
    it('opens on the chosen month', async () => {
      const screen = await render(
        <PlDatePicker locale="en-GB" defaultValue={JULY_27} defaultOpen />
      );

      await expect
        .element(screen.getByRole('button', { name: 'Choose a month' }))
        .toHaveTextContent('July');
      await expect
        .element(screen.getByRole('button', { name: 'Choose a year' }))
        .toHaveTextContent('2026');
    });

    it('always draws six weeks, so stepping a month never resizes it', async () => {
      const screen = await render(
        <PlDatePicker locale="en-GB" defaultValue={new Date(2026, 1, 1)} defaultOpen />
      );

      // Six rows of seven, plus the header row of weekday names.
      await vi.waitFor(() => expect(screen.getByRole('row').elements()).toHaveLength(7));
    });

    it('chooses a day', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlDatePicker
          locale="en-GB"
          defaultValue={JULY_27}
          defaultOpen
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('gridcell', { name: fullDate(JULY_15) }).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalled());

      const chosen = onValueChange.mock.calls[0][0] as Date;

      expect(chosen.getFullYear()).toBe(2026);
      expect(chosen.getMonth()).toBe(6);
      expect(chosen.getDate()).toBe(15);
    });

    it('keeps the time of day a value already carried', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlDatePicker
          locale="en-GB"
          defaultValue={new Date(2026, 6, 27, 9, 30)}
          defaultOpen
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('gridcell', { name: fullDate(JULY_15) }).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalled());

      const chosen = onValueChange.mock.calls[0][0] as Date;

      expect(chosen.getHours()).toBe(9);
      expect(chosen.getMinutes()).toBe(30);
    });

    it('steps a month at a time', async () => {
      const screen = await render(
        <PlDatePicker locale="en-GB" defaultValue={JULY_27} defaultOpen />
      );

      await screen.getByRole('button', { name: 'Next month' }).click();

      await expect
        .element(screen.getByRole('button', { name: 'Choose a month' }))
        .toHaveTextContent('August');
    });

    it('opens the month grid and the year grid from the header', async () => {
      const screen = await render(
        <PlDatePicker locale="en-GB" defaultValue={JULY_27} defaultOpen />
      );

      await screen.getByRole('button', { name: 'Choose a year' }).click();

      // Twelve years at a time, so any year at all is three clicks away.
      await expect.element(screen.getByRole('gridcell', { name: '2020' })).toBeInTheDocument();

      await screen.getByRole('gridcell', { name: '2020' }).click();

      // Choosing a year drops into the month grid rather than back to the days.
      await expect
        .element(screen.getByRole('gridcell', { name: 'March 2020' }))
        .toBeInTheDocument();
    });

    it('writes the header in the order the locale does', async () => {
      const screen = await render(<PlDatePicker locale="ko" defaultValue={JULY_27} defaultOpen />);
      const header = screen.getByRole('button', { name: 'Choose a year' }).element();
      const monthButton = screen.getByRole('button', { name: 'Choose a month' }).element();

      // `2026년 7월`: the year comes first in Korean.
      expect(
        header.compareDocumentPosition(monthButton) & Node.DOCUMENT_POSITION_FOLLOWING
      ).toBeTruthy();
    });
  });

  describe('bounds', () => {
    it('blocks a day before `minDate`', async () => {
      const screen = await render(
        <PlDatePicker
          locale="en-GB"
          defaultValue={JULY_27}
          defaultOpen
          minDate={new Date(2026, 6, 20)}
        />
      );

      await expect
        .element(screen.getByRole('gridcell', { name: fullDate(JULY_15) }))
        .toHaveAttribute('aria-disabled', 'true');
    });

    it('blocks a day after `maxDate`', async () => {
      const screen = await render(
        <PlDatePicker
          locale="en-GB"
          defaultValue={new Date(2026, 6, 1)}
          defaultOpen
          maxDate={new Date(2026, 6, 10)}
        />
      );

      await expect
        .element(screen.getByRole('gridcell', { name: fullDate(JULY_15) }))
        .toHaveAttribute('aria-disabled', 'true');
    });

    it('blocks the days a rule says are unavailable', async () => {
      const screen = await render(
        <PlDatePicker
          locale="en-GB"
          defaultValue={JULY_27}
          defaultOpen
          shouldDisableDate={(date) => date.getDay() === 0 || date.getDay() === 6}
        />
      );

      await expect
        .element(screen.getByRole('gridcell', { name: fullDate(JULY_18) }))
        .toHaveAttribute('aria-disabled', 'true');
      await expect
        .element(screen.getByRole('gridcell', { name: fullDate(JULY_15) }))
        .not.toHaveAttribute('aria-disabled');
    });

    it('does not commit a blocked day', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlDatePicker
          locale="en-GB"
          defaultValue={JULY_27}
          defaultOpen
          minDate={new Date(2026, 6, 20)}
          onValueChange={onValueChange}
        />
      );

      // A raw DOM click rather than the driver's: Playwright refuses to press
      // something carrying `aria-disabled`, which is itself half the guarantee.
      // The other half is the component's own guard, and this is what reaches it.
      (screen.getByRole('gridcell', { name: fullDate(JULY_15) }).element() as HTMLElement).click();

      expect(onValueChange).not.toHaveBeenCalled();
    });
  });

  describe('precision', () => {
    it('opens a month picker on the month grid, with no day grid under it', async () => {
      const screen = await render(
        <PlDatePicker locale="en-GB" precision="month" defaultValue={JULY_27} defaultOpen />
      );

      await expect.element(screen.getByRole('gridcell', { name: 'July 2026' })).toBeInTheDocument();

      // The day grid is unreachable, and so is the button that would open it.
      expect(screen.getByRole('gridcell', { name: fullDate(JULY_27) }).query()).toBeNull();
      expect(screen.getByRole('button', { name: 'Choose a month' }).query()).toBeNull();
    });

    it('commits the 1st of the month it was handed', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlDatePicker
          locale="en-GB"
          precision="month"
          defaultValue={JULY_27}
          defaultOpen
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('gridcell', { name: 'October 2026' }).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalled());

      const chosen = onValueChange.mock.calls[0][0] as Date;

      expect(chosen.getFullYear()).toBe(2026);
      expect(chosen.getMonth()).toBe(9);
      expect(chosen.getDate()).toBe(1);
    });

    it('still reaches every year, and comes back to the months', async () => {
      const screen = await render(
        <PlDatePicker locale="en-GB" precision="month" defaultValue={JULY_27} defaultOpen />
      );

      await screen.getByRole('button', { name: 'Choose a year' }).click();
      await screen.getByRole('gridcell', { name: '2020' }).click();

      await expect
        .element(screen.getByRole('gridcell', { name: 'March 2020' }))
        .toBeInTheDocument();
    });

    it('opens a year picker on the year grid and commits 1 January', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlDatePicker
          locale="en-GB"
          precision="year"
          defaultValue={JULY_27}
          defaultOpen
          onValueChange={onValueChange}
        />
      );

      expect(screen.getByRole('gridcell', { name: 'July 2026' }).query()).toBeNull();

      await screen.getByRole('gridcell', { name: '2020' }).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalled());

      const chosen = onValueChange.mock.calls[0][0] as Date;

      expect(chosen.getFullYear()).toBe(2020);
      expect(chosen.getMonth()).toBe(0);
      expect(chosen.getDate()).toBe(1);
    });

    it('writes the trigger at the precision it asked for', async () => {
      const screen = await render(
        <PlDatePicker locale="en-GB" precision="month" defaultValue={JULY_27} />
      );

      await expect.element(screen.getByRole('button')).toHaveTextContent(monthAndYear(JULY_27));

      await screen.rerender(
        <PlDatePicker locale="en-GB" precision="year" defaultValue={JULY_27} />
      );

      await expect.element(screen.getByRole('button')).toHaveTextContent('2026');
    });

    it('reads the bounds at the same precision', async () => {
      const screen = await render(
        <PlDatePicker
          locale="en-GB"
          precision="month"
          defaultValue={JULY_27}
          defaultOpen
          // Mid-July, so July itself is still reachable and June is not.
          minDate={JULY_15}
        />
      );

      await expect
        .element(screen.getByRole('gridcell', { name: 'June 2026' }))
        .toHaveAttribute('aria-disabled', 'true');
      await expect
        .element(screen.getByRole('gridcell', { name: 'July 2026' }))
        .not.toHaveAttribute('aria-disabled');
    });

    it('renames the footer shortcut after the unit it jumps to', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlDatePicker
          precision="month"
          defaultOpen
          defaultValue={JULY_27}
          onValueChange={onValueChange}
        />
      );

      expect(screen.getByRole('button', { name: 'Today' }).query()).toBeNull();

      await screen.getByRole('button', { name: 'This month' }).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalled());

      const chosen = onValueChange.mock.calls[0][0] as Date;
      const now = new Date();

      expect(chosen.getMonth()).toBe(now.getMonth());
      expect(chosen.getDate()).toBe(1);
    });

    it('submits the two shorter spellings', async () => {
      const screen = await render(
        <form>
          <PlDatePicker name="expiry" precision="month" defaultValue={JULY_27} />
        </form>
      );

      const read = () =>
        new FormData(screen.getByRole('button').element().closest('form') as HTMLFormElement).get(
          'expiry'
        );

      expect(read()).toBe('2026-07');

      await screen.rerender(
        <form>
          <PlDatePicker name="expiry" precision="year" defaultValue={JULY_27} />
        </form>
      );

      expect(read()).toBe('2026');
    });
  });

  describe('the footer', () => {
    it('jumps to today', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlDatePicker defaultOpen onValueChange={onValueChange} defaultValue={JULY_27} />
      );

      await screen.getByRole('button', { name: 'Today' }).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalled());

      const chosen = onValueChange.mock.calls[0][0] as Date;
      const now = new Date();

      expect(chosen.getDate()).toBe(now.getDate());
      expect(chosen.getMonth()).toBe(now.getMonth());
    });

    it('offers a × only when asked', async () => {
      const screen = await render(<PlDatePicker defaultValue={JULY_27} />);

      expect(screen.getByRole('button', { name: 'Clear' }).query()).toBeNull();

      await screen.rerender(<PlDatePicker defaultValue={JULY_27} clearable />);

      await expect.element(screen.getByRole('button', { name: 'Clear' })).toBeInTheDocument();
    });

    it('empties the picker', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlDatePicker defaultValue={JULY_27} clearable onValueChange={onValueChange} />
      );

      await screen.getByRole('button', { name: 'Clear' }).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalledWith(null));
    });

    it('takes the caller’s own words', async () => {
      const screen = await render(
        <PlDatePicker defaultOpen defaultValue={JULY_27} labels={{ today: '오늘' }} />
      );

      await expect.element(screen.getByRole('button', { name: '오늘' })).toBeInTheDocument();
    });
  });

  describe('states', () => {
    it('disables the trigger', async () => {
      const screen = await render(<PlDatePicker disabled />);

      expect(screen.getByRole('button').element()).toBeDisabled();
    });

    it('keeps a read-only picker focusable but unopenable', async () => {
      const screen = await render(<PlDatePicker readOnly defaultValue={JULY_27} />);

      expect(screen.getByRole('button').element()).not.toBeDisabled();

      await screen.getByRole('button').click();

      expect(screen.getByRole('grid').query()).toBeNull();
    });
  });

  describe('forms', () => {
    it('submits the day as a local `YYYY-MM-DD`, never as UTC', async () => {
      const onSubmit = vi.fn((event: React.FormEvent<HTMLFormElement>) => {
        event.preventDefault();
      });
      const screen = await render(
        <form onSubmit={onSubmit}>
          <PlDatePicker name="departure" defaultValue={JULY_27} />
          <button type="submit">Save</button>
        </form>
      );

      await screen.getByRole('button', { name: 'Save' }).click();

      const form = screen.getByRole('button', { name: 'Save' }).element().closest('form');

      expect(new FormData(form as HTMLFormElement).get('departure')).toBe('2026-07-27');
    });
  });
});
