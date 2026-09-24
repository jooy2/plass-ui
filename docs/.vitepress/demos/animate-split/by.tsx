import { useState } from 'react';
import { PlAnimateSplit, PlButton } from 'plass-ui';

export default function AnimateSplitBy() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <PlButton size="sm" variant="glass" color="secondary" onClick={() => setRun(run + 1)}>
        Play again
      </PlButton>

      <PlAnimateSplit
        key={`word-${run}`}
        className="text-2xl font-semibold"
        effect="slide"
        stagger={90}
      >
        Cut into words
      </PlAnimateSplit>

      <PlAnimateSplit
        key={`character-${run}`}
        by="character"
        className="text-2xl font-semibold"
        effect="slide"
        stagger={30}
      >
        Cut into characters
      </PlAnimateSplit>
    </div>
  );
}
