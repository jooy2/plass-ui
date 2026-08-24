import { useState } from 'react';
import { PlTextField } from 'plass-ui';

export default function TextFieldControlled() {
  const [value, setValue] = useState('');

  return (
    <div className="grid w-full max-w-sm gap-2">
      <PlTextField
        label="Display name"
        value={value}
        maxLength={24}
        placeholder="Ada Lovelace"
        onChange={(event) => setValue(event.target.value)}
      />
      <p className="text-xs text-(--plass-muted-fg)">{value.length}/24</p>
    </div>
  );
}
