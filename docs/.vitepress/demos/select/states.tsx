import { PlSelect } from 'plass-ui';

const items = [
  { value: 'daily', label: 'Daily' },
  { value: 'weekly', label: 'Weekly' },
  { value: 'never', label: 'Never', disabled: true }
];

export default function SelectStates() {
  return (
    <div className="flex flex-wrap items-start gap-3">
      <PlSelect label="Default" items={items} defaultValue="weekly" />
      <PlSelect label="Read-only" items={items} defaultValue="weekly" readOnly />
      <PlSelect label="Disabled" items={items} defaultValue="weekly" disabled />
      <PlSelect label="Invalid" items={items} placeholder="Choose" error="Pick a cadence." />
    </div>
  );
}
