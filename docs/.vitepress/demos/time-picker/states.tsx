import { PlTimePicker } from 'plass-ui';

const value = new Date(2026, 6, 27, 9, 30);

export default function TimePickerStates() {
  return (
    <div className="flex flex-wrap gap-6">
      <PlTimePicker label="Error" error="Pick a time." placeholder="Pick a time" />
      <PlTimePicker label="Read-only" readOnly defaultValue={value} />
      <PlTimePicker label="Disabled" disabled defaultValue={value} />
    </div>
  );
}
