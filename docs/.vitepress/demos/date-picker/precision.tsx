import { PlDatePicker } from 'plass-ui';

export default function DatePickerPrecision() {
  return (
    <div className="flex w-full max-w-xs flex-col gap-6">
      <PlDatePicker fullWidth label="A birthday" placeholder="Pick a day" />

      <PlDatePicker
        fullWidth
        precision="month"
        label="A card's expiry"
        placeholder="Pick a month"
      />

      <PlDatePicker fullWidth precision="year" label="A model year" placeholder="Pick a year" />
    </div>
  );
}
