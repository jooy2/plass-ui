import { useState } from 'react';
import { PlCombobox } from 'plass-ui';

const tags = [
  { value: 'bug', label: 'bug' },
  { value: 'docs', label: 'documentation' },
  { value: 'a11y', label: 'accessibility' },
  { value: 'perf', label: 'performance' },
  { value: 'design', label: 'design' }
];

export default function ComboboxMultiple() {
  const [value, setValue] = useState<(string | number)[]>(['a11y']);

  return (
    <PlCombobox
      className="w-full max-w-sm"
      fullWidth
      multiple
      label="Labels"
      placeholder="Add a label…"
      items={tags}
      value={value}
      onValueChange={setValue}
    />
  );
}
