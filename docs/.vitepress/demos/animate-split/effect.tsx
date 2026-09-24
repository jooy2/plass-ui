import { useState } from 'react';
import { PlAnimateSplit, PlButton } from 'plass-ui';

const effects = ['fade', 'slide', 'grow', 'zoom', 'reveal'] as const;

export default function AnimateSplitEffect() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <PlButton size="sm" variant="glass" color="secondary" onClick={() => setRun(run + 1)}>
        Play again
      </PlButton>

      {effects.map((effect) => (
        <PlAnimateSplit
          key={`${effect}-${run}`}
          className="text-xl font-semibold"
          effect={effect}
          stagger={80}
        >
          {`Every word arrives by ${effect}`}
        </PlAnimateSplit>
      ))}
    </div>
  );
}
