import { PlDateRangePicker } from 'plass-ui';

export default function DateRangePickerHero() {
  return (
    <PlDateRangePicker
      label="Stay"
      description="Two months at a time, because a range usually crosses one."
      startPlaceholder="Check in"
      endPlaceholder="Check out"
      minDate={new Date()}
      clearable
    />
  );
}
