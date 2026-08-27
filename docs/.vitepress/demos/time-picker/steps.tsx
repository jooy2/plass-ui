import { PlTimePicker } from 'plass-ui';

const value = new Date(2026, 6, 27, 9, 30);

export default function TimePickerSteps() {
  return (
    <div className="flex flex-wrap gap-6">
      <PlTimePicker label="Every minute" defaultValue={value} />
      <PlTimePicker label="Every 15" minuteStep={15} defaultValue={value} />
      <PlTimePicker label="With seconds" showSeconds secondStep={5} defaultValue={value} />
    </div>
  );
}
