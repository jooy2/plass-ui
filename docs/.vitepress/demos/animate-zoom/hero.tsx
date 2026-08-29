import { useState } from 'react';
import { PlAnimateZoom, PlButton, PlCard, PlTypography } from 'plass-ui';

export default function AnimateZoomHero() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <PlButton size="sm" variant="glass" color="secondary" onClick={() => setRun(run + 1)}>
        Play again
      </PlButton>

      <PlAnimateZoom key={run} duration={420}>
        <PlCard size="sm" title="Payment received">
          <PlTypography level="h3">£1,240.00</PlTypography>
        </PlCard>
      </PlAnimateZoom>
    </div>
  );
}
