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

export default function GridHero() {
  return (
    <PlGrid spacing={3}>
      <PlGridItem span={{ xs: 12, sm: 6, lg: 3 }}>
        <Cell>3</Cell>
      </PlGridItem>
      <PlGridItem span={{ xs: 12, sm: 6, lg: 3 }}>
        <Cell>3</Cell>
      </PlGridItem>
      <PlGridItem span={{ xs: 12, sm: 6, lg: 3 }}>
        <Cell>3</Cell>
      </PlGridItem>
      <PlGridItem span={{ xs: 12, sm: 6, lg: 3 }}>
        <Cell>3</Cell>
      </PlGridItem>
      <PlGridItem span={{ xs: 12, md: 8 }}>
        <Cell>8</Cell>
      </PlGridItem>
      <PlGridItem span={{ xs: 12, md: 4 }}>
        <Cell>4</Cell>
      </PlGridItem>
    </PlGrid>
  );
}
