import { useState } from 'react';
import { PlAnimateGrow, PlButton, PlCard } from 'plass-ui';

export default function AnimateGrowHero() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <PlButton size="sm" variant="glass" color="secondary" onClick={() => setRun(run + 1)}>
        Play again
      </PlButton>

      <PlAnimateGrow key={run} duration={520}>
        <PlCard size="sm" title="Filters">
          Three of nine rows match.
        </PlCard>
      </PlAnimateGrow>
    </div>
  );
}
