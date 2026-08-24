import { useState } from 'react';
import { PlButton, PlRadio, PlRadioGroup } from 'plass-ui';

export default function RadioGroupControlled() {
  const [theme, setTheme] = useState<unknown>('system');

  return (
    <div className="flex flex-col items-start gap-3">
      <PlRadioGroup label="Theme" orientation="horizontal" value={theme} onValueChange={setTheme}>
        <PlRadio value="light" label="Light" />
        <PlRadio value="dark" label="Dark" />
        <PlRadio value="system" label="System" />
      </PlRadioGroup>

      <div className="flex items-center gap-3">
        <PlButton size="sm" variant="glass" color="secondary" onClick={() => setTheme('system')}>
          Reset
        </PlButton>
        <p className="text-xs text-(--plass-muted-fg)">value: {String(theme)}</p>
      </div>
    </div>
  );
}
