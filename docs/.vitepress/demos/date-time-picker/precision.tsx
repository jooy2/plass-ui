import { PlDatePicker, PlDateTimePicker } from 'plass-ui';

const now = new Date();

export default function DateTimePickerPrecision() {
  return (
    <div className="flex flex-col gap-6">
      <PlDatePicker
        label="PlDatePicker — the bound is a day"
        placeholder="Pick a day"
        minDate={now}
      />

      <PlDateTimePicker
        label="PlDateTimePicker — the bound is a moment"
        placeholder="Pick a moment"
        minDate={now}
      />
    </div>
  );
}
