import { useState } from 'react';
import { PlNumberField, PlTypography } from 'plass-ui';

export default function NumberFieldFormat() {
  const [value, setValue] = useState<number | null>(0.185);

  return (
    <div className="flex w-full max-w-md flex-col gap-4">
      <PlNumberField
        fullWidth
        label="Commission"
        value={value}
        onValueChange={setValue}
        step={0.005}
        smallStep={0.001}
        locale="en-US"
        format={{ style: 'percent', maximumFractionDigits: 2 }}
      />
      <PlTypography level="caption">
        The field shows a percentage; the value is {String(value)}.
      </PlTypography>
    </div>
  );
}
