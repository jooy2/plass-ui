import { PlDateRangePicker } from 'plass-ui';

export default function DateRangePickerBounds() {
  return (
    <div className="flex flex-col gap-6">
      <PlDateRangePicker
        label="From today on"
        startPlaceholder="Check in"
        endPlaceholder="Check out"
        minDate={new Date()}
      />

      <PlDateRangePicker
        label="Weekdays only"
        startPlaceholder="From"
        endPlaceholder="To"
        shouldDisableDate={(date) => date.getDay() === 0 || date.getDay() === 6}
      />
    </div>
  );
}
