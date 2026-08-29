import { useState } from 'react';
import { PlAnimateGrow, PlBox, PlButton } from 'plass-ui';

export default function AnimateGrowPanel() {
  const [open, setOpen] = useState(false);

  return (
    <div className="flex w-full max-w-sm flex-col items-start gap-2">
      <PlButton size="sm" variant="glass" color="secondary" onClick={() => setOpen(!open)}>
        {open ? 'Hide options' : 'Show options'}
      </PlButton>

      {open ? (
        <PlAnimateGrow className="w-full" origin="top" from={0.92} duration={260}>
          <PlBox size="sm">Sort, group and column visibility.</PlBox>
        </PlAnimateGrow>
      ) : null}
    </div>
  );
}
