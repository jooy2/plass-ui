import { useState } from 'react';
import { PlAnimateZoom, PlBox, PlButton, PlTypography } from 'plass-ui';

export default function AnimateZoomResult() {
  const [score, setScore] = useState<number | null>(null);

  return (
    <div className="flex flex-col items-center gap-4">
      <PlButton size="sm" onClick={() => setScore(score === null ? 92 : null)}>
        {score === null ? 'Run the check' : 'Reset'}
      </PlButton>

      {score === null ? null : (
        <PlAnimateZoom duration={380}>
          <PlBox size="lg" color="success">
            <PlTypography level="h2">{score}</PlTypography>
          </PlBox>
        </PlAnimateZoom>
      )}
    </div>
  );
}
