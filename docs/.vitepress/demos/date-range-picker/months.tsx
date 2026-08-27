import { PlDateRangePicker } from 'plass-ui';

const range = { start: new Date(2026, 6, 27), end: new Date(2026, 7, 4) };

export default function DateRangePickerMonths() {
  return (
    <div className="flex flex-col gap-6">
      <PlDateRangePicker label="Two months (the default)" defaultValue={range} />
      <PlDateRangePicker label="One" monthCount={1} defaultValue={range} />
    </div>
  );
}
