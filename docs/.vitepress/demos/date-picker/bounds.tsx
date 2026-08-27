import { PlDatePicker } from 'plass-ui';

const today = new Date();
const inThreeWeeks = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 21);

export default function DatePickerBounds() {
  return (
    <div className="flex w-full max-w-xs flex-col gap-6">
      <PlDatePicker
        fullWidth
        label="Within three weeks"
        placeholder="Pick a day"
        minDate={today}
        maxDate={inThreeWeeks}
      />

      <PlDatePicker
        fullWidth
        label="Weekdays only"
        placeholder="Pick a day"
        shouldDisableDate={(date) => date.getDay() === 0 || date.getDay() === 6}
      />
    </div>
  );
}
