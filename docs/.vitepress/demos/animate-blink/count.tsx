import { useState } from 'react';
import { PlAnimateBlink, PlBox, PlButton } from 'plass-ui';

export default function AnimateBlinkCount() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <PlButton size="sm" variant="glass" color="secondary" onClick={() => setRun(run + 1)}>
        Draw attention to it
      </PlButton>

      <PlAnimateBlink key={run} repeat={3} min={0.25} duration={600}>
        <PlBox size="sm" color="warning">
          Two fields still need an answer.
        </PlBox>
      </PlAnimateBlink>
    </div>
  );
}
