import { useState } from 'react';
import { PlButton, PlOverlay, PlTypography } from 'plass-ui';

export default function OverlayAlign() {
  const [align, setAlign] = useState<'start' | 'center' | 'end' | null>(null);

  return (
    <div className="flex flex-wrap gap-2">
      {(['start', 'center', 'end'] as const).map((one) => (
        <PlButton
          key={one}
          size="sm"
          variant="glass"
          color="secondary"
          onClick={() => setAlign(one)}
        >
          {one}
        </PlButton>
      ))}

      <PlOverlay
        dismissible
        align={align ?? 'center'}
        open={align !== null}
        onOpenChange={(next) => !next && setAlign(null)}
        label={`Aligned to ${align}`}
      >
        <PlTypography level="h4" color="primary">
          {align}
        </PlTypography>
      </PlOverlay>
    </div>
  );
}
