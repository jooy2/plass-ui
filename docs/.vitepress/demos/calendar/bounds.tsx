import { PlCalendar } from 'plass-ui';

export default function CalendarBounds() {
  return (
    <PlCalendar
      locale="en-GB"
      defaultMonth={new Date(2026, 6, 1)}
      minDate={new Date(2026, 6, 6)}
      maxDate={new Date(2026, 6, 24)}
      // A weekend is not a booking day.
      shouldDisableDate={(date) => date.getDay() === 0 || date.getDay() === 6}
    />
  );
}
