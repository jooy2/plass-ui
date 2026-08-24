import { useState } from 'react';
import { PlButton, PlOverlay, PlTypography } from 'plass-ui';

export default function OverlayDismissible() {
  const [open, setOpen] = useState(false);

  return (
    <div className="flex flex-wrap gap-2">
      <PlButton size="sm" onClick={() => setOpen(true)}>
        Open a dismissible one
      </PlButton>

      <PlOverlay
        dismissible
        tone="glass"
        open={open}
        onOpenChange={setOpen}
        label="Press anywhere to close"
      >
        <PlTypography level="lead" color="primary">
          Press anywhere, or Escape.
        </PlTypography>
      </PlOverlay>
    </div>
  );
}
