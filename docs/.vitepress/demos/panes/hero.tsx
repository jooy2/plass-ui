import type { ReactNode } from 'react';
import { PlPane, PlPanes } from 'plass-ui';

function Filled({ children }: { children: ReactNode }) {
  return (
    <div className="flex h-full items-center justify-center bg-(--plass-glass-press) p-4 text-sm text-(--plass-muted-fg)">
      {children}
    </div>
  );
}

export default function PanesHero() {
  return (
    <div className="h-56 w-full overflow-hidden rounded-(--plass-radius-lg)">
      <PlPanes>
        <PlPane defaultSize="180px" minSize="120px" maxSize="60%">
          <Filled>Sidebar</Filled>
        </PlPane>
        <PlPane>
          <Filled>Body — drag the handle</Filled>
        </PlPane>
      </PlPanes>
    </div>
  );
}
