import { useState } from 'react';
import { PlCalendar } from 'plass-ui';

export default function CalendarHero() {
  const [value, setValue] = useState<Date | null>(new Date(2026, 6, 27));

  return (
    <div className="flex flex-col items-center gap-3">
      <PlCalendar locale="en-GB" value={value} onValueChange={setValue} />
      <span className="text-sm text-(--plass-muted-fg)">
        {value ? value.toDateString() : 'Nothing chosen'}
      </span>
    </div>
  );
}
