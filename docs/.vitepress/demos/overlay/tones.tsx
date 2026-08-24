import { useState } from 'react';
import { PlButton, PlOverlay, PlTypography } from 'plass-ui';

const tones = ['scrim', 'glass', 'solid', 'clear'] as const;

export default function OverlayTones() {
  const [tone, setTone] = useState<(typeof tones)[number] | null>(null);

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-wrap gap-2">
        {tones.map((one) => (
          <PlButton
            key={one}
            size="sm"
            variant="glass"
            color="secondary"
            onClick={() => setTone(one)}
          >
            {one}
          </PlButton>
        ))}
      </div>

      <PlTypography level="caption">Press one, then press the sheet to close it.</PlTypography>

      <PlOverlay
        dismissible
        tone={tone ?? 'scrim'}
        open={tone !== null}
        onOpenChange={(next) => !next && setTone(null)}
        label={`The ${tone} overlay`}
      >
        <PlTypography level="h4" color="primary">
          {tone}
        </PlTypography>
      </PlOverlay>
    </div>
  );
}
