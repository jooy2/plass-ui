import type { ReactNode } from 'react';
import { useState } from 'react';
import { PlPane, PlPanes, PlTypography } from 'plass-ui';

function Filled({ children }: { children: ReactNode }) {
  return (
    <div className="flex h-full items-center justify-center bg-(--plass-glass-press) p-3 text-xs text-(--plass-muted-fg)">
      {children}
    </div>
  );
}

export default function PanesConstraints() {
  const [sizes, setSizes] = useState<number[]>([]);

  return (
    <div className="flex w-full flex-col gap-2">
      <div className="h-40 w-full overflow-hidden rounded-(--plass-radius-lg)">
        <PlPanes onResize={setSizes} onResizeEnd={setSizes}>
          <PlPane defaultSize={30} minSize="20%" maxSize="50%">
            <Filled>20% – 50%</Filled>
          </PlPane>
          <PlPane>
            <Filled>Whatever is left</Filled>
          </PlPane>
        </PlPanes>
      </div>
      <PlTypography level="caption">
        {sizes.length > 0
          ? sizes.map((share) => `${Math.round(share)}%`).join(' · ')
          : 'Drag the handle to see the shares'}
      </PlTypography>
    </div>
  );
}
