import { useState } from 'react';
import { PlButton, PlCard, PlPortal } from 'plass-ui';

export default function PortalHero() {
  const [open, setOpen] = useState(false);

  return (
    <div className="w-full max-w-md">
      {/* The clipping box a portal exists to get out of. */}
      <div className="h-28 overflow-hidden rounded-(--plass-radius-md) border border-(--plass-border) p-4">
        <p className="mb-3 text-sm text-(--plass-muted-fg)">This box clips whatever it contains.</p>
        <PlButton size="sm" onClick={() => setOpen((was) => !was)}>
          {open ? 'Take it back' : 'Send a note to the body'}
        </PlButton>
      </div>

      {open ? (
        <PlPortal className="fixed inset-x-4 bottom-4 z-(--plass-z-portal) flex justify-center">
          <PlCard className="max-w-sm">
            <p className="text-sm">
              Rendered inside the clipped box and painted on <code>document.body</code>, so nothing
              cuts it off.
            </p>
          </PlCard>
        </PlPortal>
      ) : null}
    </div>
  );
}
