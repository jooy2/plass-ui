import type { ReactNode } from 'react';
import { PlPane, PlPanes, PlTypography } from 'plass-ui';

function Filled({ children }: { children: ReactNode }) {
  return (
    <div className="flex h-full items-center justify-center bg-(--plass-glass-press) text-xs text-(--plass-muted-fg)">
      {children}
    </div>
  );
}

export default function PanesSizes() {
  return (
    <div className="flex w-full flex-col gap-3">
      {(['xs', 'md', 'xl'] as const).map((size) => (
        <div key={size} className="flex flex-col gap-1">
          <PlTypography level="caption">size={size}</PlTypography>
          <div className="h-20 w-full overflow-hidden rounded-(--plass-radius-md)">
            <PlPanes size={size} color="info">
              <PlPane>
                <Filled>One</Filled>
              </PlPane>
              <PlPane>
                <Filled>Two</Filled>
              </PlPane>
            </PlPanes>
          </div>
        </div>
      ))}
    </div>
  );
}
