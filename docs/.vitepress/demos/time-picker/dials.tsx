import { PlTimePicker } from 'plass-ui';

const value = new Date(2026, 6, 27, 21, 5);

export default function TimePickerDials() {
  return (
    <div className="flex flex-wrap gap-6">
      <PlTimePicker label="en-US (12 hours)" locale="en-US" defaultValue={value} />
      <PlTimePicker label="en-GB (24 hours)" locale="en-GB" defaultValue={value} />
      <PlTimePicker label="Forced to 12" locale="en-GB" hour12 defaultValue={value} />
    </div>
  );
}
