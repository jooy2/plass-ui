import { PlDateTimePicker } from 'plass-ui';

const value = new Date(2026, 6, 27, 9, 30);

export default function DateTimePickerStates() {
  return (
    <div className="flex flex-col gap-6">
      <PlDateTimePicker label="Error" error="Pick a moment." placeholder="Pick a moment" />
      <PlDateTimePicker label="Read-only" readOnly defaultValue={value} />
      <PlDateTimePicker label="Disabled" disabled defaultValue={value} />
    </div>
  );
}
