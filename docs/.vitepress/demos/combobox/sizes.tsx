import { PlCombobox } from 'plass-ui';

const cities = [
  { value: 'seoul', label: 'Seoul' },
  { value: 'lisbon', label: 'Lisbon' }
];

const sizes = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function ComboboxSizes() {
  return (
    <div className="flex w-full max-w-xs flex-col gap-4">
      {sizes.map((size) => (
        <PlCombobox key={size} fullWidth size={size} placeholder={size} items={cities} />
      ))}
    </div>
  );
}
