import { PlTimePicker } from 'plass-ui';

export default function TimePickerHero() {
  return (
    <PlTimePicker
      className="w-full max-w-3xs"
      fullWidth
      label="Doors"
      description="Fifteen minutes at a time."
      placeholder="Pick a time"
      minuteStep={15}
      clearable
    />
  );
}
