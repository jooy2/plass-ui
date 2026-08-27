import { PlDatePicker } from 'plass-ui';

const value = new Date(2026, 6, 27);

export default function DatePickerStates() {
  return (
    <div className="flex w-full max-w-xs flex-col gap-6">
      <PlDatePicker fullWidth label="Error" error="Pick a day." placeholder="Pick a day" />
      <PlDatePicker fullWidth label="Read-only" readOnly defaultValue={value} />
      <PlDatePicker fullWidth label="Disabled" disabled defaultValue={value} />
    </div>
  );
}
