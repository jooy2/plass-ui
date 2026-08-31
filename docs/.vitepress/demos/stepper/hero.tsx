import { useState } from 'react';
import { PlButton, PlStep, PlStepper, PlTextField } from 'plass-ui';

export default function StepperHero() {
  const [active, setActive] = useState(1);

  return (
    <div className="flex w-full max-w-2xl flex-col gap-4">
      <PlStepper active={active} onActiveChange={setActive}>
        <PlStep label="Account" description="Email and password">
          <PlTextField label="Email" placeholder="ada@example.com" fullWidth />
        </PlStep>
        <PlStep label="Verify" description="Six digits">
          <PlTextField label="Code" placeholder="000000" fullWidth />
        </PlStep>
        <PlStep label="Profile" optional>
          <PlTextField label="Display name" placeholder="Ada" fullWidth />
        </PlStep>
      </PlStepper>

      <div className="flex justify-between">
        <PlButton
          variant="ghost"
          color="secondary"
          disabled={active === 0}
          onClick={() => setActive((n) => n - 1)}
        >
          Back
        </PlButton>
        <PlButton disabled={active === 2} onClick={() => setActive((n) => n + 1)}>
          Next
        </PlButton>
      </div>
    </div>
  );
}
