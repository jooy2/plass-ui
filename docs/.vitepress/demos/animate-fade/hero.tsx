import { useState } from 'react';
import { PlAnimateFade, PlButton, PlCard } from 'plass-ui';

export default function AnimateFadeHero() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <PlButton size="sm" variant="glass" color="secondary" onClick={() => setRun(run + 1)}>
        Play again
      </PlButton>

      <PlAnimateFade key={run} duration={700}>
        <PlCard size="sm" title="Deployment finished">
          Two services restarted, no errors.
        </PlCard>
      </PlAnimateFade>
    </div>
  );
}
