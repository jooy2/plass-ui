import type { ReactNode } from 'react';
import { PlFlex } from 'plass-ui';

/** Something to see the axis with — a flex box draws nothing at all. */
function Cell({ children }: { children: ReactNode }) {
  return (
    <div className="rounded-(--plass-radius-sm) bg-(--plass-glass-press) px-4 py-2 text-center text-sm">
      {children}
    </div>
  );
}

export default function FlexDirection() {
  return (
    <PlFlex direction="vertical" spacing={4} className="w-full max-w-md">
      <PlFlex spacing={2}>
        <Cell>one</Cell>
        <Cell>two</Cell>
        <Cell>three</Cell>
      </PlFlex>

      <PlFlex spacing={2} reverse>
        <Cell>one</Cell>
        <Cell>two</Cell>
        <Cell>three</Cell>
      </PlFlex>

      <PlFlex direction="vertical" spacing={2}>
        <Cell>one</Cell>
        <Cell>two</Cell>
      </PlFlex>
    </PlFlex>
  );
}
