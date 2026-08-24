import { useState } from 'react';
import { PlSlider } from 'plass-ui';

export default function SliderRange() {
  const [price, setPrice] = useState<number[]>([25, 75]);

  return (
    <PlSlider
      className="max-w-sm"
      label="Price"
      value={price}
      min={0}
      max={100}
      onValueChange={(next) => setPrice(next as number[])}
      showValue={(formatted) => `$${formatted[0]} – $${formatted[1]}`}
    />
  );
}
