import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlDateRangePicker, type PlDateRange } from 'plass-ui';
import { fullDate, mediumDate } from '../../support/dates';

const JULY = { start: new Date(2026, 6, 10), end: new Date(2026, 6, 20) };
const JULY_15 = new Date(2026, 6, 15);
const AUGUST_1 = new Date(2026, 7, 1);
const AUGUST_5 = new Date(2026, 7, 5);

describe('PlDateRangePicker', () => {
  describe('rendering', () => {
    it('renders a trigger', async () => {
      const screen = await render(<PlDateRangePicker label="Stay" />);

      await expect.element(screen.getByRole('button', { name: 'Stay' })).toBeInTheDocument();
    });

    it('writes both ends', async () => {
      const screen = await render(<PlDateRangePicker locale="en-GB" defaultValue={JULY} />);
      const trigger = screen.getByRole('button').element();

      expect(trigger.textContent).toContain(mediumDate(JULY.start));
      expect(trigger.textContent).toContain(mediumDate(JULY.end));
    });

    it('shows a placeholder in each half', async () => {
      const screen = await render(
        <PlDateRangePicker startPlaceholder="Check in" endPlaceholder="Check out" />
      );

      await expect.element(screen.getByText('Check in')).toBeInTheDocument();
      await expect.element(screen.getByText('Check out')).toBeInTheDocument();
    });

    it('reflects a changed value on re-render', async () => {
      const screen = await render(
        <PlDateRangePicker locale="en-GB" value={JULY} onValueChange={() => {}} />
      );

      expect(screen.getByRole('button').element().textContent).toContain(mediumDate(JULY.start));

      await screen.rerender(
        <PlDateRangePicker
          locale="en-GB"
          value={{ start: AUGUST_1, end: AUGUST_5 }}
          onValueChange={() => {}}
        />
      );

      expect(screen.getByRole('button').element().textContent).toContain(mediumDate(AUGUST_1));
    });
  });

  describe('the two panels', () => {
    it('shows two months, a month apart', async () => {
      const screen = await render(
        <PlDateRangePicker locale="en-GB" defaultValue={JULY} defaultOpen />
      );

      await vi.waitFor(() =>
        expect(screen.getByRole('button', { name: 'Choose a month' }).elements()).toHaveLength(2)
      );

      const [left, right] = screen.getByRole('button', { name: 'Choose a month' }).elements();

      expect(left.textContent).toContain('July');
      expect(right.textContent).toContain('August');
    });

    it('shows one when asked', async () => {
      const screen = await render(
        <PlDateRangePicker locale="en-GB" defaultValue={JULY} defaultOpen monthCount={1} />
      );

      await vi.waitFor(() =>
        expect(screen.getByRole('button', { name: 'Choose a month' }).elements()).toHaveLength(1)
      );
    });

    it('gives the pair one back stepper and one forward stepper', async () => {
      const screen = await render(
        <PlDateRangePicker locale="en-GB" defaultValue={JULY} defaultOpen />
      );

      await vi.waitFor(() =>
        expect(screen.getByRole('button', { name: 'Previous month' }).elements()).toHaveLength(1)
      );
      expect(screen.getByRole('button', { name: 'Next month' }).elements()).toHaveLength(1);
    });

    it('moves both panels together', async () => {
      const screen = await render(
        <PlDateRangePicker locale="en-GB" defaultValue={JULY} defaultOpen />
      );

      await screen.getByRole('button', { name: 'Next month' }).click();

      await vi.waitFor(() => {
        const [left, right] = screen.getByRole('button', { name: 'Choose a month' }).elements();

        expect(left.textContent).toContain('August');
        expect(right.textContent).toContain('September');
      });
    });

    it('draws no outside days, so no day is in the popup twice', async () => {
      const screen = await render(
        <PlDateRangePicker locale="en-GB" defaultValue={JULY} defaultOpen />
      );

      // 1 August is the first day of the right panel; the left panel leaves a
      // hole where its trailing days would be rather than naming it twice.
      await vi.waitFor(() =>
        expect(screen.getByRole('gridcell', { name: fullDate(AUGUST_1) }).elements()).toHaveLength(
          1
        )
      );
    });
  });

  describe('choosing', () => {
    it('takes the first click as the start and leaves the end open', async () => {
      const onValueChange = vi.fn<(value: PlDateRange) => void>();
      const screen = await render(
        <PlDateRangePicker
          locale="en-GB"
          defaultMonth={JULY.start}
          defaultOpen
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('gridcell', { name: fullDate(JULY_15) }).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalled());

      const first = onValueChange.mock.calls[0][0];

      expect(first.start?.getDate()).toBe(15);
      expect(first.end).toBeNull();
    });

    it('takes the second click as the end', async () => {
      const onValueChange = vi.fn<(value: PlDateRange) => void>();
      const screen = await render(
        <PlDateRangePicker
          locale="en-GB"
          defaultMonth={JULY.start}
          defaultOpen
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('gridcell', { name: fullDate(JULY_15) }).click();
      await screen.getByRole('gridcell', { name: fullDate(JULY.end) }).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalledTimes(2));

      const second = onValueChange.mock.calls[1][0];

      expect(second.start?.getDate()).toBe(15);
      expect(second.end?.getDate()).toBe(20);
    });

    it('accepts a range clicked backwards, in the order it was meant', async () => {
      const onValueChange = vi.fn<(value: PlDateRange) => void>();
      const screen = await render(
        <PlDateRangePicker
          locale="en-GB"
          defaultMonth={JULY.start}
          defaultOpen
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('gridcell', { name: fullDate(JULY.end) }).click();
      await screen.getByRole('gridcell', { name: fullDate(JULY_15) }).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalledTimes(2));

      const second = onValueChange.mock.calls[1][0];

      expect(second.start?.getDate()).toBe(15);
      expect(second.end?.getDate()).toBe(20);
    });

    it('bands the days between the two ends', async () => {
      const screen = await render(
        <PlDateRangePicker locale="en-GB" defaultValue={JULY} defaultOpen />
      );

      const between = screen.getByRole('gridcell', { name: fullDate(JULY_15) }).element();

      // Inside a range, not chosen: the soft wash rather than the gradient.
      expect(between.className).toContain('bg-(--p-soft)');
      expect(between.getAttribute('aria-selected')).toBe('false');
    });

    it('marks both ends as chosen', async () => {
      const screen = await render(
        <PlDateRangePicker locale="en-GB" defaultValue={JULY} defaultOpen />
      );

      await expect
        .element(screen.getByRole('gridcell', { name: fullDate(JULY.start) }))
        .toHaveAttribute('aria-selected', 'true');
      await expect
        .element(screen.getByRole('gridcell', { name: fullDate(JULY.end) }))
        .toHaveAttribute('aria-selected', 'true');
    });

    it('says which end it is asking for', async () => {
      const screen = await render(
        <PlDateRangePicker locale="en-GB" defaultMonth={JULY.start} defaultOpen />
      );

      await expect.element(screen.getByText('Start')).toBeInTheDocument();

      await screen.getByRole('gridcell', { name: fullDate(JULY_15) }).click();

      await expect.element(screen.getByText('End')).toBeInTheDocument();
    });
  });

  describe('presets', () => {
    it('offers them beside the calendars', async () => {
      const screen = await render(
        <PlDateRangePicker
          locale="en-GB"
          defaultMonth={JULY.start}
          defaultOpen
          presets={[{ label: 'That week', value: JULY }]}
        />
      );

      await expect.element(screen.getByRole('button', { name: 'That week' })).toBeInTheDocument();
    });

    it('commits the whole range at once', async () => {
      const onValueChange = vi.fn<(value: PlDateRange) => void>();
      const screen = await render(
        <PlDateRangePicker
          locale="en-GB"
          defaultMonth={JULY.start}
          defaultOpen
          onValueChange={onValueChange}
          presets={[{ label: 'That week', value: JULY }]}
        />
      );

      await screen.getByRole('button', { name: 'That week' }).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalledWith(JULY));
    });

    it('computes a range that depends on today, when it is taken', async () => {
      const onValueChange = vi.fn<(value: PlDateRange) => void>();
      const screen = await render(
        <PlDateRangePicker
          defaultOpen
          onValueChange={onValueChange}
          presets={[
            {
              label: 'Today',
              value: () => ({ start: new Date(), end: new Date() })
            }
          ]}
        />
      );

      await screen.getByRole('button', { name: 'Today' }).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalled());

      const range = onValueChange.mock.calls[0][0];

      expect(range.start?.getDate()).toBe(new Date().getDate());
    });
  });

  describe('states', () => {
    it('keeps a read-only picker focusable but unopenable', async () => {
      const screen = await render(<PlDateRangePicker readOnly defaultValue={JULY} />);

      expect(screen.getByRole('button').element()).not.toBeDisabled();

      await screen.getByRole('button').click();

      expect(screen.getByRole('grid').query()).toBeNull();
    });

    it('empties both ends', async () => {
      const onValueChange = vi.fn<(value: PlDateRange) => void>();
      const screen = await render(
        <PlDateRangePicker defaultValue={JULY} clearable onValueChange={onValueChange} />
      );

      await screen.getByRole('button', { name: 'Clear' }).click();

      await vi.waitFor(() =>
        expect(onValueChange).toHaveBeenCalledWith({ start: null, end: null })
      );
    });
  });

  describe('forms', () => {
    it('submits both ends under one name', async () => {
      const onSubmit = vi.fn((event: React.FormEvent<HTMLFormElement>) => {
        event.preventDefault();
      });
      const screen = await render(
        <form onSubmit={onSubmit}>
          <PlDateRangePicker name="stay" defaultValue={JULY} />
          <button type="submit">Save</button>
        </form>
      );

      await screen.getByRole('button', { name: 'Save' }).click();

      const form = screen.getByRole('button', { name: 'Save' }).element().closest('form');

      expect(new FormData(form as HTMLFormElement).getAll('stay')).toEqual([
        '2026-07-10',
        '2026-07-20'
      ]);
    });
  });
});
