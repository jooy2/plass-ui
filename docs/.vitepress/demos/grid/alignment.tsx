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

export default function GridAlignment() {
  return (
    <PlGrid spacing={3} alignItems="center">
      <PlGridItem span={4}>
        <Cell>
          centred
          <br />
          against
          <br />
          the tall one
        </Cell>
      </PlGridItem>
      <PlGridItem span={4}>
        <Cell>centred</Cell>
      </PlGridItem>
      <PlGridItem span={4} alignSelf="end">
        <Cell>alignSelf end</Cell>
      </PlGridItem>
    </PlGrid>
  );
}
