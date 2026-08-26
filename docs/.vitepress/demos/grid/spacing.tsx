import type { ReactNode } from 'react';
import { PlGrid, PlGridItem, PlTypography } from 'plass-ui';

/** Something to see the layout with — a grid item draws nothing at all. */
function Cell({ children }: { children: ReactNode }) {
  return (
    <div className="rounded-(--plass-radius-sm) bg-(--plass-glass-press) px-3 py-2 text-center text-sm">
      {children}
    </div>
  );
}

export default function GridSpacing() {
  return (
    <div className="flex w-full flex-col gap-4">
      {[0, 2, 6].map((spacing) => (
        <div key={spacing} className="flex flex-col gap-1">
          <PlTypography level="caption">spacing={spacing}</PlTypography>
          <PlGrid spacing={spacing}>
            {[3, 3, 3, 3].map((span, index) => (
              <PlGridItem key={index} span={span}>
                <Cell>{span}</Cell>
              </PlGridItem>
            ))}
          </PlGrid>
        </div>
      ))}
    </div>
  );
}
