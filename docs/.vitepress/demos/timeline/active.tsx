import { useState } from 'react';
import { PlButton, PlTimeline, PlTimelineItem } from 'plass-ui';

const steps = ['Account', 'Payment', 'Review', 'Done'];

export default function TimelineActive() {
  const [active, setActive] = useState(1);

  return (
    <div className="flex w-full max-w-md flex-col gap-5">
      <PlTimeline active={active}>
        {steps.map((step) => (
          <PlTimelineItem key={step} title={step} />
        ))}
      </PlTimeline>

      <div className="flex gap-2">
        <PlButton
          size="sm"
          variant="glass"
          color="secondary"
          onClick={() => setActive(Math.max(0, active - 1))}
        >
          Back
        </PlButton>
        <PlButton size="sm" onClick={() => setActive(Math.min(steps.length, active + 1))}>
          Next
        </PlButton>
      </div>
    </div>
  );
}
