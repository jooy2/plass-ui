import { useState } from 'react';
import { PlButton, PlDrawer } from 'plass-ui';

type Side = 'left' | 'right' | 'top' | 'bottom';

export default function DrawerSides() {
  const [side, setSide] = useState<Side | null>(null);

  return (
    <>
      <div className="flex flex-wrap gap-2">
        {(['left', 'right', 'top', 'bottom'] as const).map((edge) => (
          <PlButton key={edge} variant="glass" onClick={() => setSide(edge)}>
            {edge}
          </PlButton>
        ))}
      </div>

      <PlDrawer
        side={side ?? 'left'}
        open={side !== null}
        onOpenChange={(next) => !next && setSide(null)}
        title={`side="${side ?? 'left'}"`}
        description="Square against the window, cut on the free side."
      >
        A top or bottom panel is as tall as what is in it, up to 85% of the window.
      </PlDrawer>
    </>
  );
}
