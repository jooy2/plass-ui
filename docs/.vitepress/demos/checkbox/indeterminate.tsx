import { useState } from 'react';
import { PlCheckbox } from 'plass-ui';

const scopes = ['Read', 'Write', 'Delete'];

export default function CheckboxIndeterminate() {
  const [granted, setGranted] = useState<string[]>(['Read']);

  const all = granted.length === scopes.length;
  const some = granted.length > 0 && !all;

  return (
    <div className="flex flex-col gap-3">
      <PlCheckbox
        label="All scopes"
        checked={all}
        indeterminate={some}
        onCheckedChange={(next) => setGranted(next ? scopes : [])}
      />
      <div className="ms-6 flex flex-col gap-2">
        {scopes.map((scope) => (
          <PlCheckbox
            key={scope}
            label={scope}
            checked={granted.includes(scope)}
            onCheckedChange={(next) =>
              setGranted((current) =>
                next ? [...current, scope] : current.filter((value) => value !== scope)
              )
            }
          />
        ))}
      </div>
    </div>
  );
}
