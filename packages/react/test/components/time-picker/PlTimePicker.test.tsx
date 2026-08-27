import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlTimePicker } from 'plass-ui';

/** Half past nine on a fixed day, so nothing here depends on when it is run. */
const NINE_THIRTY = new Date(2026, 6, 27, 9, 30);

describe('PlTimePicker', () => {
  describe('rendering', () => {
    it('renders a trigger', async () => {
      const screen = await render(<PlTimePicker label="Doors" />);

      await expect.element(screen.getByRole('button', { name: 'Doors' })).toBeInTheDocument();
    });

    it('writes the chosen time the way the locale does', async () => {
      const screen = await render(<PlTimePicker locale="en-GB" defaultValue={NINE_THIRTY} />);

      await expect.element(screen.getByRole('button')).toHaveTextContent('9:30');
    });

    it('puts a 12-hour locale on a 12-hour dial', async () => {
      const screen = await render(<PlTimePicker locale="en-US" defaultValue={NINE_THIRTY} />);

      await expect.element(screen.getByRole('button')).toHaveTextContent('9:30 AM');
    });

    it('shows the placeholder while nothing is chosen', async () => {
      const screen = await render(<PlTimePicker placeholder="Pick a time" />);

      await expect.element(screen.getByText('Pick a time')).toBeInTheDocument();
    });

    it('reflects a changed value on re-render', async () => {
      const screen = await render(
        <PlTimePicker locale="en-GB" value={NINE_THIRTY} onValueChange={() => {}} />
      );

      await expect.element(screen.getByRole('button')).toHaveTextContent('9:30');

      await screen.rerender(
        <PlTimePicker
          locale="en-GB"
          value={new Date(2026, 6, 27, 17, 5)}
          onValueChange={() => {}}
        />
      );

      await expect.element(screen.getByRole('button')).toHaveTextContent('17:05');
    });
  });

  describe('the columns', () => {
    it('draws an hour column and a minute column', async () => {
      const screen = await render(
        <PlTimePicker locale="en-GB" defaultValue={NINE_THIRTY} defaultOpen />
      );

      await expect.element(screen.getByRole('listbox', { name: 'Hour' })).toBeInTheDocument();
      await expect.element(screen.getByRole('listbox', { name: 'Minute' })).toBeInTheDocument();
      expect(screen.getByRole('listbox', { name: 'Second' }).query()).toBeNull();
    });

    it('adds seconds when asked', async () => {
      const screen = await render(
        <PlTimePicker locale="en-GB" defaultValue={NINE_THIRTY} defaultOpen showSeconds />
      );

      await expect.element(screen.getByRole('listbox', { name: 'Second' })).toBeInTheDocument();
    });

    it('adds an AM/PM column on a 12-hour dial and none on a 24-hour one', async () => {
      const screen = await render(
        <PlTimePicker locale="en-US" defaultValue={NINE_THIRTY} defaultOpen />
      );

      await expect.element(screen.getByRole('listbox', { name: 'AM/PM' })).toBeInTheDocument();

      await screen.rerender(<PlTimePicker locale="en-GB" defaultValue={NINE_THIRTY} defaultOpen />);

      expect(screen.getByRole('listbox', { name: 'AM/PM' }).query()).toBeNull();
    });

    it('runs a 24-hour dial from 00 to 23', async () => {
      const screen = await render(
        <PlTimePicker locale="en-GB" defaultValue={NINE_THIRTY} defaultOpen />
      );
      const hours = screen.getByRole('listbox', { name: 'Hour' }).element();

      expect(hours.querySelectorAll('[role="option"]')).toHaveLength(24);
      expect(hours.firstElementChild?.textContent).toBe('00');
    });

    it('reads a 12-hour dial as 12, 1, 2 rather than 0, 1, 2', async () => {
      const screen = await render(
        <PlTimePicker locale="en-US" defaultValue={NINE_THIRTY} defaultOpen />
      );
      const hours = screen.getByRole('listbox', { name: 'Hour' }).element();

      expect(hours.querySelectorAll('[role="option"]')).toHaveLength(12);
      expect(hours.firstElementChild?.textContent).toBe('12');
    });

    it('steps the columns as far apart as it was told', async () => {
      const screen = await render(
        <PlTimePicker locale="en-GB" defaultValue={NINE_THIRTY} defaultOpen minuteStep={15} />
      );
      const minutes = screen.getByRole('listbox', { name: 'Minute' }).element();

      expect([...minutes.children].map((row) => row.textContent)).toEqual(['00', '15', '30', '45']);
    });

    it('marks the chosen row in each column', async () => {
      const screen = await render(
        <PlTimePicker locale="en-GB" defaultValue={NINE_THIRTY} defaultOpen />
      );

      const hour = screen
        .getByRole('listbox', { name: 'Hour' })
        .element()
        .querySelector('[aria-selected="true"]');

      expect(hour?.textContent).toBe('09');
    });

    it('marks nothing while there is no value', async () => {
      const screen = await render(<PlTimePicker locale="en-GB" defaultOpen />);

      expect(
        screen
          .getByRole('listbox', { name: 'Hour' })
          .element()
          .querySelector('[aria-selected="true"]')
      ).toBeNull();
    });
  });

  describe('choosing', () => {
    it('sets the hour and leaves the minutes alone', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlTimePicker
          locale="en-GB"
          defaultValue={NINE_THIRTY}
          defaultOpen
          onValueChange={onValueChange}
        />
      );

      const hours = screen.getByRole('listbox', { name: 'Hour' }).element();

      (hours.querySelectorAll('[role="option"]')[14] as HTMLElement).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalled());

      const chosen = onValueChange.mock.calls[0][0] as Date;

      expect(chosen.getHours()).toBe(14);
      expect(chosen.getMinutes()).toBe(30);
    });

    it('stays open, because a time is two answers', async () => {
      const screen = await render(
        <PlTimePicker locale="en-GB" defaultValue={NINE_THIRTY} defaultOpen />
      );

      const minutes = screen.getByRole('listbox', { name: 'Minute' }).element();

      (minutes.querySelectorAll('[role="option"]')[45] as HTMLElement).click();

      await expect.element(screen.getByRole('listbox', { name: 'Hour' })).toBeInTheDocument();
    });

    it('closes on the first touch when told to', async () => {
      const screen = await render(
        <PlTimePicker locale="en-GB" defaultValue={NINE_THIRTY} defaultOpen closeOnSelect />
      );

      const minutes = screen.getByRole('listbox', { name: 'Minute' }).element();

      (minutes.querySelectorAll('[role="option"]')[45] as HTMLElement).click();

      await vi.waitFor(() =>
        expect(screen.getByRole('listbox', { name: 'Hour' }).query()).toBeNull()
      );
    });

    it('moves the whole clock when the meridiem is switched', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlTimePicker
          locale="en-US"
          defaultValue={NINE_THIRTY}
          defaultOpen
          onValueChange={onValueChange}
        />
      );

      await screen.getByRole('option', { name: 'PM' }).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalled());

      expect((onValueChange.mock.calls[0][0] as Date).getHours()).toBe(21);
    });
  });

  describe('bounds', () => {
    it('leaves the hour available when only some of its minutes are', async () => {
      const screen = await render(
        <PlTimePicker
          locale="en-GB"
          defaultValue={NINE_THIRTY}
          defaultOpen
          minTime={new Date(2026, 6, 27, 9, 30)}
        />
      );

      const hours = screen.getByRole('listbox', { name: 'Hour' }).element();
      const nine = hours.querySelectorAll('[role="option"]')[9];

      // 9 covers 09:00:00–09:59:59, which overlaps what is allowed — hiding it
      // would make half past nine unreachable.
      expect(nine).not.toHaveAttribute('aria-disabled');
      expect(hours.querySelectorAll('[role="option"]')[8]).toHaveAttribute('aria-disabled', 'true');
    });

    it('greys out the minutes before the bound in that hour', async () => {
      const screen = await render(
        <PlTimePicker
          locale="en-GB"
          defaultValue={NINE_THIRTY}
          defaultOpen
          minTime={new Date(2026, 6, 27, 9, 30)}
        />
      );

      const minutes = screen.getByRole('listbox', { name: 'Minute' }).element();
      const rows = minutes.querySelectorAll('[role="option"]');

      expect(rows[25]).toHaveAttribute('aria-disabled', 'true');
      expect(rows[30]).not.toHaveAttribute('aria-disabled');
    });

    it('blocks the rows a rule says are unavailable', async () => {
      const screen = await render(
        <PlTimePicker
          locale="en-GB"
          defaultValue={NINE_THIRTY}
          defaultOpen
          shouldDisableTime={(value, unit) => unit === 'hour' && value.getHours() >= 12}
        />
      );

      const hours = screen.getByRole('listbox', { name: 'Hour' }).element();
      const rows = hours.querySelectorAll('[role="option"]');

      expect(rows[13]).toHaveAttribute('aria-disabled', 'true');
      expect(rows[9]).not.toHaveAttribute('aria-disabled');
    });

    it('does not commit a blocked row', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlTimePicker
          locale="en-GB"
          defaultValue={NINE_THIRTY}
          defaultOpen
          minTime={new Date(2026, 6, 27, 9, 0)}
          onValueChange={onValueChange}
        />
      );

      const hours = screen.getByRole('listbox', { name: 'Hour' }).element();

      (hours.querySelectorAll('[role="option"]')[3] as HTMLElement).click();

      expect(onValueChange).not.toHaveBeenCalled();
    });
  });

  describe('the footer', () => {
    it('offers Done while the popup stays open', async () => {
      const screen = await render(<PlTimePicker defaultValue={NINE_THIRTY} defaultOpen />);

      await expect.element(screen.getByRole('button', { name: 'Done' })).toBeInTheDocument();
    });

    it('offers no Done when the popup closes on the first touch', async () => {
      const screen = await render(
        <PlTimePicker defaultValue={NINE_THIRTY} defaultOpen closeOnSelect />
      );

      expect(screen.getByRole('button', { name: 'Done' }).query()).toBeNull();
    });

    it('jumps to now', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlTimePicker defaultValue={NINE_THIRTY} defaultOpen onValueChange={onValueChange} />
      );

      await screen.getByRole('button', { name: 'Now' }).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalled());

      const chosen = onValueChange.mock.calls[0][0] as Date;

      expect(chosen.getHours()).toBe(new Date().getHours());
    });

    it('writes a chosen time onto the reference day', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlTimePicker
          locale="en-GB"
          referenceDate={new Date(2026, 0, 15)}
          defaultOpen
          onValueChange={onValueChange}
        />
      );

      const hours = screen.getByRole('listbox', { name: 'Hour' }).element();

      (hours.querySelectorAll('[role="option"]')[7] as HTMLElement).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalled());

      const chosen = onValueChange.mock.calls[0][0] as Date;

      expect(chosen.getFullYear()).toBe(2026);
      expect(chosen.getMonth()).toBe(0);
      expect(chosen.getDate()).toBe(15);
      expect(chosen.getHours()).toBe(7);
    });
  });

  describe('states', () => {
    it('keeps a read-only picker focusable but unopenable', async () => {
      const screen = await render(<PlTimePicker readOnly defaultValue={NINE_THIRTY} />);

      expect(screen.getByRole('button').element()).not.toBeDisabled();

      await screen.getByRole('button').click();

      expect(screen.getByRole('listbox').query()).toBeNull();
    });
  });

  describe('forms', () => {
    it('submits the time as a local `HH:MM`', async () => {
      const onSubmit = vi.fn((event: React.FormEvent<HTMLFormElement>) => {
        event.preventDefault();
      });
      const screen = await render(
        <form onSubmit={onSubmit}>
          <PlTimePicker name="doors" defaultValue={NINE_THIRTY} />
          <button type="submit">Save</button>
        </form>
      );

      await screen.getByRole('button', { name: 'Save' }).click();

      const form = screen.getByRole('button', { name: 'Save' }).element().closest('form');

      expect(new FormData(form as HTMLFormElement).get('doors')).toBe('09:30');
    });

    it('adds the seconds when they are shown', async () => {
      const onSubmit = vi.fn((event: React.FormEvent<HTMLFormElement>) => {
        event.preventDefault();
      });
      const screen = await render(
        <form onSubmit={onSubmit}>
          <PlTimePicker name="doors" showSeconds defaultValue={new Date(2026, 6, 27, 9, 30, 5)} />
          <button type="submit">Save</button>
        </form>
      );

      await screen.getByRole('button', { name: 'Save' }).click();

      const form = screen.getByRole('button', { name: 'Save' }).element().closest('form');

      expect(new FormData(form as HTMLFormElement).get('doors')).toBe('09:30:05');
    });
  });
});
