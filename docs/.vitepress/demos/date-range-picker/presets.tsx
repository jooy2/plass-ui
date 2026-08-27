import { PlDateRangePicker } from 'plass-ui';

/** Days back from today, at midnight. */
function daysAgo(count: number) {
  const now = new Date();

  return new Date(now.getFullYear(), now.getMonth(), now.getDate() - count);
}

export default function DateRangePickerPresets() {
  return (
    <PlDateRangePicker
      label="Reporting period"
      startPlaceholder="From"
      endPlaceholder="To"
      maxDate={new Date()}
      presets={[
        { label: 'Last 7 days', value: () => ({ start: daysAgo(6), end: new Date() }) },
        { label: 'Last 30 days', value: () => ({ start: daysAgo(29), end: new Date() }) },
        {
          label: 'This month',
          value: () => {
            const now = new Date();

            return { start: new Date(now.getFullYear(), now.getMonth(), 1), end: now };
          }
        }
      ]}
    />
  );
}
