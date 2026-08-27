import { PlDateTimePicker } from 'plass-ui';

const value = new Date(2026, 6, 27, 9, 30);

export default function DateTimePickerSteps() {
  return (
    <div className="flex flex-col gap-6">
      <PlDateTimePicker label="Every 15 minutes" minuteStep={15} defaultValue={value} />
      <PlDateTimePicker label="With seconds" showSeconds secondStep={15} defaultValue={value} />
    </div>
  );
}
