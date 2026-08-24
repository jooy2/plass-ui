import { useState } from 'react';
import { PlButton, PlSelect, type PlSelectValue } from 'plass-ui';

const items = [
  { value: 'light', label: 'Light' },
  { value: 'dark', label: 'Dark' },
  { value: 'system', label: 'Follow the system' }
];

export default function SelectControlled() {
  const [theme, setTheme] = useState<PlSelectValue | null>('system');

  return (
    <div className="flex flex-wrap items-end gap-3">
      <PlSelect label="Theme" items={items} value={theme} onValueChange={setTheme} />
      <PlButton variant="glass" color="secondary" onClick={() => setTheme('system')}>
        Reset
      </PlButton>
      <p className="text-xs text-(--plass-muted-fg)">value: {String(theme)}</p>
    </div>
  );
}
