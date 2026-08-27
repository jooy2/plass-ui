import { PlDatePicker } from 'plass-ui';

const value = new Date(2026, 6, 27);

export default function DatePickerFormat() {
  return (
    <div className="flex w-full max-w-xs flex-col gap-4">
      <PlDatePicker fullWidth label="medium (the default)" defaultValue={value} />
      <PlDatePicker fullWidth label="full" defaultValue={value} format={{ dateStyle: 'full' }} />
      <PlDatePicker
        fullWidth
        label="Its own parts"
        defaultValue={value}
        format={{ year: 'numeric', month: 'long' }}
      />
    </div>
  );
}
