import { useState } from 'react';
import { PlAnimateSplit, PlButton } from 'plass-ui';

export default function AnimateSplitStagger() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <PlButton size="sm" variant="glass" color="secondary" onClick={() => setRun(run + 1)}>
        Play again
      </PlButton>

      <PlAnimateSplit
        key={`quick-${run}`}
        className="text-xl font-semibold"
        effect="slide"
        stagger={40}
      >
        Forty milliseconds between words
      </PlAnimateSplit>

      <PlAnimateSplit
        key={`slow-${run}`}
        className="text-xl font-semibold"
        effect="slide"
        stagger={160}
      >
        A hundred and sixty between words
      </PlAnimateSplit>

      <PlAnimateSplit
        key={`reverse-${run}`}
        className="text-xl font-semibold"
        effect="slide"
        stagger={80}
        reverse
      >
        From the last word back to the first
      </PlAnimateSplit>
    </div>
  );
}
