import { PlDatePicker } from 'plass-ui';

export default function DatePickerHero() {
  return (
    <PlDatePicker
      className="w-full max-w-xs"
      fullWidth
      label="Departure"
      description="Any day from today."
      placeholder="Pick a day"
      minDate={new Date()}
      clearable
    />
  );
}
