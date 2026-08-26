import type { ReactNode } from 'react';
import { PlPane, PlPanes } from 'plass-ui';

function Filled({ children }: { children: ReactNode }) {
  return (
    <div className="flex h-full items-center justify-center bg-(--plass-glass-press) p-3 text-xs text-(--plass-muted-fg)">
      {children}
    </div>
  );
}

export default function PanesOrientation() {
  return (
    <div className="h-56 w-full overflow-hidden rounded-(--plass-radius-lg)">
      <PlPanes>
        <PlPane defaultSize={40}>
          <Filled>Left</Filled>
        </PlPane>
        <PlPane>
          <PlPanes orientation="vertical">
            <PlPane>
              <Filled>Top right</Filled>
            </PlPane>
            <PlPane>
              <Filled>Bottom right</Filled>
            </PlPane>
          </PlPanes>
        </PlPane>
      </PlPanes>
    </div>
  );
}
