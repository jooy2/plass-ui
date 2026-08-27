import { PlCombobox } from 'plass-ui';

const cities = [
  { value: 'seoul', label: 'Seoul' },
  { value: 'lisbon', label: 'Lisbon' },
  { value: 'quito', label: 'Quito', disabled: true }
];

export default function ComboboxStates() {
  return (
    <div className="flex w-full max-w-xs flex-col gap-6">
      <PlCombobox fullWidth label="Error" error="Pick a city." items={cities} />
      <PlCombobox fullWidth label="Read-only" readOnly defaultValue="seoul" items={cities} />
      <PlCombobox fullWidth label="Disabled" disabled defaultValue="seoul" items={cities} />
    </div>
  );
}
