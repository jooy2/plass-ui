import type { ReactNode } from 'react';
import { PlGrid, PlGridItem } from 'plass-ui';

/** Something to see the layout with — a grid item draws nothing at all. */
function Cell({ children }: { children: ReactNode }) {
  return (
    <div className="rounded-(--plass-radius-sm) bg-(--plass-glass-press) px-3 py-2 text-center text-sm">
      {children}
    </div>
  );
}

export default function GridOffset() {
  return (
    <div className="flex w-full flex-col gap-3">
      <PlGrid>
        <PlGridItem span={4} offset={4}>
          <Cell>span 4, offset 4</Cell>
        </PlGridItem>
      </PlGrid>
      <PlGrid>
        <PlGridItem span={4}>
          <Cell>span 4</Cell>
        </PlGridItem>
        <PlGridItem span={4} offset={4}>
          <Cell>span 4, offset 4</Cell>
        </PlGridItem>
      </PlGrid>
    </div>
  );
}
