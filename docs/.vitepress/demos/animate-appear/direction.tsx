import { useState } from 'react';
import { PlAnimateAppear, PlBox, PlButton } from 'plass-ui';

const steps = ['Account', 'Verify', 'Profile'];

export default function AnimateAppearDirection() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <PlButton size="sm" variant="glass" color="secondary" onClick={() => setRun(run + 1)}>
        Play again
      </PlButton>

      <div className="flex flex-wrap items-start justify-center gap-8">
        <PlAnimateAppear
          key={`down-${run}`}
          from="left"
          distance={20}
          className="flex flex-col gap-2"
        >
          {steps.map((step) => (
            <PlBox key={step} size="sm">
              {step}
            </PlBox>
          ))}
        </PlAnimateAppear>

        <PlAnimateAppear
          key={`up-${run}`}
          from="left"
          distance={20}
          reverse
          className="flex flex-col gap-2"
        >
          {steps.map((step) => (
            <PlBox key={step} size="sm">
              {step}
            </PlBox>
          ))}
        </PlAnimateAppear>
      </div>
    </div>
  );
}
