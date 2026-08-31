import { PlCard, PlCalendar } from 'plass-ui';

export default function CalendarVariants() {
  return (
    <div className="flex flex-wrap items-start justify-center gap-4">
      <PlCalendar locale="en-GB" size="sm" defaultMonth={new Date(2026, 6, 1)} />

      <PlCard className="p-3">
        <PlCalendar
          locale="en-GB"
          size="sm"
          variant="ghost"
          elevation={0}
          defaultMonth={new Date(2026, 6, 1)}
        />
      </PlCard>
    </div>
  );
}
