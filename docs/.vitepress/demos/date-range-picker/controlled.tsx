import { useState } from 'react';
import { PlDateRangePicker, type PlDateRange } from 'plass-ui';

export default function DateRangePickerControlled() {
  const [range, setRange] = useState<PlDateRange>({ start: null, end: null });

  const nights =
    range.start && range.end
      ? Math.round((range.end.getTime() - range.start.getTime()) / 86_400_000)
      : null;

  return (
    <div className="flex flex-col items-start gap-3">
      <PlDateRangePicker
        label="Stay"
        startPlaceholder="Check in"
        endPlaceholder="Check out"
        value={range}
        onValueChange={setRange}
        clearable
      />

      <p className="text-sm text-(--plass-muted-fg)">
        {nights === null ? 'Pick both ends.' : `${nights} night${nights === 1 ? '' : 's'}.`}
      </p>
    </div>
  );
}
