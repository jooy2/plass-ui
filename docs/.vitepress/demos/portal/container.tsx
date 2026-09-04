import { useRef } from 'react';
import { PlChip, PlPortal } from 'plass-ui';

export default function PortalContainer() {
  // `null` on the render that creates it, which is why the container is
  // resolved after mount rather than read off the props.
  const host = useRef<HTMLDivElement>(null);

  return (
    <div className="flex w-full max-w-md flex-col gap-4">
      <div className="rounded-(--plass-radius-md) border border-dashed border-(--plass-border) p-4">
        <p className="mb-2 text-sm text-(--plass-muted-fg)">Written here.</p>
        <PlPortal container={host}>
          <PlChip color="success">A chip that was written above</PlChip>
        </PlPortal>
      </div>

      <div
        ref={host}
        className="rounded-(--plass-radius-md) border border-(--plass-border) p-4"
        aria-label="The host"
      >
        <p className="mb-2 text-sm text-(--plass-muted-fg)">Drawn here.</p>
      </div>
    </div>
  );
}
