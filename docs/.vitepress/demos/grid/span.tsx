import type { ReactNode } from 'react';
import { PlGrid, PlGridItem } from 'plass-ui';

const ROWS = [[12], [6, 6], [4, 4, 4], [3, 3, 3, 3], [8, 4]];

/** Something to see the layout with — a grid item draws nothing at all. */
function Cell({ children }: { children: ReactNode }) {
  return (
    <div className="rounded-(--plass-radius-sm) bg-(--plass-glass-press) px-3 py-2 text-center text-sm">
      {children}
    </div>
  );
}

export default function GridSpan() {
  return (
    <div className="flex w-full flex-col gap-3">
      {ROWS.map((row) => (
        <PlGrid key={row.join('-')} spacing={2}>
          {row.map((span, index) => (
            <PlGridItem key={`${span}-${index}`} span={span}>
              <Cell>{span}</Cell>
            </PlGridItem>
          ))}
        </PlGrid>
      ))}
    </div>
  );
}
