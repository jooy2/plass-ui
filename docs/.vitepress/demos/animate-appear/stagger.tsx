import { useState } from 'react';
import { PlAnimateAppear, PlButton, PlChip } from 'plass-ui';

export default function AnimateAppearStagger() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <PlButton size="sm" variant="glass" color="secondary" onClick={() => setRun(run + 1)}>
        Play again
      </PlButton>

      <div className="flex flex-col gap-3">
        {[40, 140].map((stagger) => (
          <PlAnimateAppear
            key={`${run}-${stagger}`}
            stagger={stagger}
            className="flex flex-wrap items-center gap-2"
          >
            {['one', 'two', 'three', 'four', 'five'].map((word) => (
              <PlChip key={word}>{word}</PlChip>
            ))}
          </PlAnimateAppear>
        ))}
      </div>
    </div>
  );
}
