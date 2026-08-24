import { useState } from 'react';
import { PlButton, PlTextField } from 'plass-ui';

export default function TextFieldValidation() {
  const [value, setValue] = useState('acme inc');
  const message = value.includes(' ') ? 'Spaces are not allowed.' : undefined;

  return (
    <div className="flex w-full max-w-sm items-end gap-3">
      <PlTextField
        fullWidth
        label="Workspace"
        value={value}
        error={message}
        description={message ? undefined : 'Letters, numbers and dashes.'}
        onChange={(event) => setValue(event.target.value)}
      />
      <PlButton disabled={Boolean(message)}>Create</PlButton>
    </div>
  );
}
