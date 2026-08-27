import { PlCombobox } from 'plass-ui';

const frameworks = [
  { value: 'react', label: 'React' },
  { value: 'vue', label: 'Vue' },
  { value: 'svelte', label: 'Svelte' },
  { value: 'solid', label: 'Solid' },
  { value: 'angular', label: 'Angular' }
];

export default function ComboboxHero() {
  return (
    <PlCombobox
      className="w-full max-w-xs"
      fullWidth
      label="Framework"
      description="Type to filter, or add your own."
      placeholder="Search…"
      items={frameworks}
    />
  );
}
