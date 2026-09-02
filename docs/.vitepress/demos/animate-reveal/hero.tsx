import { useState } from 'react';
import { PlAnimateReveal, PlButton, PlTypography } from 'plass-ui';

export default function AnimateRevealHero() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <PlButton size="sm" variant="glass" color="secondary" onClick={() => setRun(run + 1)}>
        Play again
      </PlButton>

      <PlAnimateReveal key={run} render={<PlTypography level="h3" />}>
        Everything is where it was.
      </PlAnimateReveal>
    </div>
  );
}
