import { useState } from 'react';
import {
  PlButton,
  PlCheckbox,
  PlSegment,
  PlSegmentedButton,
  PlSelect,
  PlTextField,
  PlassProvider,
  type PlassDensity,
  type PlassSize
} from 'plass-ui';

const cities = [
  { value: 'seoul', label: 'Seoul' },
  { value: 'busan', label: 'Busan' }
];

export default function ProviderDefaults() {
  const [size, setSize] = useState<PlassSize>('md');
  const [density, setDensity] = useState<PlassDensity>('default');

  return (
    <div className="flex w-full flex-col gap-5">
      <div className="flex flex-wrap gap-3">
        <PlSegmentedButton
          size="sm"
          aria-label="Size"
          value={size}
          onValueChange={(next) => setSize(next as PlassSize)}
        >
          {(['sm', 'md', 'lg'] as const).map((step) => (
            <PlSegment key={step} value={step}>
              {step}
            </PlSegment>
          ))}
        </PlSegmentedButton>

        <PlSegmentedButton
          size="sm"
          aria-label="Density"
          value={density}
          onValueChange={(next) => setDensity(next as PlassDensity)}
        >
          <PlSegment value="default">default</PlSegment>
          <PlSegment value="compact">compact</PlSegment>
        </PlSegmentedButton>
      </div>

      {/* Nothing below this line says `size` or `density`. */}
      <PlassProvider size={size} density={density}>
        <div className="flex flex-wrap items-end gap-3">
          <PlTextField label="Email" placeholder="ada@example.com" />
          <PlSelect items={cities} label="City" />
          <PlButton>Save</PlButton>
          <PlButton variant="glass" color="secondary">
            Cancel
          </PlButton>
        </div>

        <PlCheckbox label="Remember me" className="mt-3" />
      </PlassProvider>
    </div>
  );
}
