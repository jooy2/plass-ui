import { PlCombobox } from 'plass-ui';

const cities = [
  { value: 'seoul', label: 'Seoul' },
  { value: 'lisbon', label: 'Lisbon' },
  { value: 'quito', label: 'Quito' }
];

export default function ComboboxCustom() {
  return (
    <div className="flex w-full max-w-xs flex-col gap-6">
      <PlCombobox
        fullWidth
        label="Anything goes"
        description="Type a city that is not listed."
        placeholder="Search…"
        items={cities}
      />

      <PlCombobox
        fullWidth
        allowCustom={false}
        label="A closed set"
        description="Only these three."
        placeholder="Search…"
        items={cities}
      />
    </div>
  );
}
