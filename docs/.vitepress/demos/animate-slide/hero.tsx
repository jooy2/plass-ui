import { useState } from 'react';
import { PlAnimateSlide, PlButton, PlCard } from 'plass-ui';

export default function AnimateSlideHero() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <PlButton size="sm" variant="glass" color="secondary" onClick={() => setRun(run + 1)}>
        Play again
      </PlButton>

      <div className="w-full max-w-sm overflow-hidden">
        <PlAnimateSlide key={run} from="right" duration={520}>
          <PlCard size="sm" title="New message">
            Ada replied to your review.
          </PlCard>
        </PlAnimateSlide>
      </div>
    </div>
  );
}
