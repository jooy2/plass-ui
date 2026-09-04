import { useState } from 'react';
import { PlMeter, PlSlider } from 'plass-ui';

export default function MeterThresholds() {
  const [used, setUsed] = useState(40);

  return (
    <div className="flex w-full max-w-sm flex-col gap-6">
      <PlMeter
        value={used}
        label="Disk used"
        showValue
        thresholds={[
          { from: 75, color: 'warning' },
          { from: 90, color: 'danger' }
        ]}
      />
      <PlSlider
        label="Drag to fill it"
        value={used}
        onValueChange={(next) => setUsed(next as number)}
      />
    </div>
  );
}
