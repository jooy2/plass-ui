import { useState } from 'react';
import { PlAnimateReveal, PlButton, PlChip } from 'plass-ui';
const sides = ['left', 'right', 'top', 'bottom'] as const;

export default function AnimateRevealSides() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <PlButton size="sm" variant="glass" color="secondary" onClick={() => setRun(run + 1)}>
        Play again
      </PlButton>

      <div className="flex flex-wrap items-center justify-center gap-3">
        {sides.map((side) => (
          <PlAnimateReveal key={`${side}-${run}`} from={side}>
            <PlChip>{side}</PlChip>
          </PlAnimateReveal>
        ))}
      </div>
    </div>
  );
}
