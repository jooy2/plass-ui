import { useState } from 'react';
import { PlButton, PlStep, PlStepper, PlTypography } from 'plass-ui';

export default function StepperVertical() {
  const [active, setActive] = useState(0);

  return (
    <div className="w-full max-w-md">
      <PlStepper orientation="vertical" active={active} onActiveChange={setActive}>
        {[
          ['Pick a plan', 'Ten seats on the team plan.'],
          ['Add a card', 'Charged on the first of the month.'],
          ['Invite the team', 'You can do this later.']
        ].map(([label, body], index) => (
          <PlStep key={label} label={label}>
            <div className="flex flex-col items-start gap-2">
              <PlTypography level="body">{body}</PlTypography>
              <PlButton size="sm" onClick={() => setActive(index + 1)} disabled={index === 2}>
                Continue
              </PlButton>
            </div>
          </PlStep>
        ))}
      </PlStepper>
    </div>
  );
}
