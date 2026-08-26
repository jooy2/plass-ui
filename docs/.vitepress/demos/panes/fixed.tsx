import type { ReactNode } from 'react';
import { PlPane, PlPanes } from 'plass-ui';

function Filled({ children }: { children: ReactNode }) {
  return (
    <div className="flex h-full items-center justify-center bg-(--plass-glass-press) p-3 text-xs text-(--plass-muted-fg)">
      {children}
    </div>
  );
}

export default function PanesFixed() {
  return (
    <div className="h-40 w-full overflow-hidden rounded-(--plass-radius-lg)">
      <PlPanes resizable={false}>
        <PlPane defaultSize={25}>
          <Filled>A quarter</Filled>
        </PlPane>
        <PlPane defaultSize={50}>
          <Filled>A half</Filled>
        </PlPane>
        <PlPane defaultSize={25}>
          <Filled>A quarter</Filled>
        </PlPane>
      </PlPanes>
    </div>
  );
}
