import { useState } from 'react';
import { PlAlert, PlButton } from 'plass-ui';

export default function AlertDismiss() {
  const [open, setOpen] = useState(true);

  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      {open ? (
        <PlAlert color="warning" title="Storage is nearly full" onClose={() => setOpen(false)}>
          92% of your quota is in use.
        </PlAlert>
      ) : (
        <PlButton size="sm" variant="glass" onClick={() => setOpen(true)}>
          Bring it back
        </PlButton>
      )}
    </div>
  );
}
