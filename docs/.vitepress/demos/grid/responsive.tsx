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

export default function GridResponsive() {
  return (
    <PlGrid spacing={{ xs: 2, md: 4 }}>
      {['one', 'two', 'three', 'four', 'five', 'six'].map((name) => (
        <PlGridItem key={name} span={{ xs: 12, sm: 6, md: 4, xl: 2 }}>
          <Cell>{name}</Cell>
        </PlGridItem>
      ))}
    </PlGrid>
  );
}
