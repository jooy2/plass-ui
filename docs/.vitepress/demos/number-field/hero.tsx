import { useState } from 'react';
import { PlNumberField } from 'plass-ui';

export default function NumberFieldHero() {
  const [quantity, setQuantity] = useState<number | null>(2);

  return (
    <div className="flex w-full max-w-md flex-col gap-4">
      <PlNumberField
        fullWidth
        label="Quantity"
        description="Up to twelve per order."
        min={1}
        max={12}
        value={quantity}
        onValueChange={setQuantity}
      />

      <PlNumberField
        fullWidth
        label="Budget"
        defaultValue={1240}
        step={10}
        locale="en-US"
        format={{ style: 'currency', currency: 'USD' }}
      />
    </div>
  );
}
