import { useState } from 'react';
import { PlAnimateHeadline, PlSegment, PlSegmentedButton, PlTypography } from 'plass-ui';

const steps = ['Create an account', 'Confirm your email', 'Invite your team'];

export default function AnimateHeadlineControlled() {
  const [step, setStep] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <PlSegmentedButton
        size="sm"
        value={String(step)}
        aria-label="Step"
        onValueChange={(value) => setStep(Number(value))}
      >
        <PlSegment value="0">1</PlSegment>
        <PlSegment value="1">2</PlSegment>
        <PlSegment value="2">3</PlSegment>
      </PlSegmentedButton>

      <PlAnimateHeadline index={step}>
        {steps.map((text) => (
          <PlTypography key={text} level="h5">
            {text}
          </PlTypography>
        ))}
      </PlAnimateHeadline>
    </div>
  );
}
