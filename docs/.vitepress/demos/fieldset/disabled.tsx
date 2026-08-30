import { useState } from 'react';
import { PlCheckbox, PlFieldset, PlSwitch, PlTextField } from 'plass-ui';

export default function FieldsetDisabled() {
  const [same, setSame] = useState(true);

  return (
    <div className="flex w-full max-w-sm flex-col gap-4">
      <PlSwitch label="Same as shipping address" checked={same} onCheckedChange={setSame} />

      <PlFieldset legend="Billing address" disabled={same}>
        <PlTextField label="Street" fullWidth />
        <PlCheckbox label="This is a business address" />
      </PlFieldset>
    </div>
  );
}
