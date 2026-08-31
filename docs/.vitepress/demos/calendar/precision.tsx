import { PlCalendar } from 'plass-ui';

export default function CalendarPrecision() {
  return (
    <div className="flex flex-wrap items-start justify-center gap-4">
      <PlCalendar locale="en-GB" precision="month" defaultMonth={new Date(2026, 6, 1)} />
      <PlCalendar locale="en-GB" precision="year" defaultMonth={new Date(2026, 6, 1)} />
    </div>
  );
}
