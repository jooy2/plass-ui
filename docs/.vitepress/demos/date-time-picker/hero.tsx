import { PlDateTimePicker } from 'plass-ui';

export default function DateTimePickerHero() {
  return (
    <PlDateTimePicker
      label="Starts"
      description="Not before now."
      placeholder="Pick a moment"
      minDate={new Date()}
      minuteStep={15}
      clearable
    />
  );
}
