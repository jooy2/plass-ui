import { PlCard, PlChip, PlTypography, usePlBreakpoint, usePlBreakpointValue } from 'plass-ui';

const rungs = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function BreakpointDemo() {
  const at = usePlBreakpoint();
  const columns = usePlBreakpointValue({ xs: 1, sm: 2, lg: 4 });

  return (
    <PlCard className="w-full">
      <div className="flex flex-col gap-4">
        <div className="flex flex-wrap gap-2">
          {rungs.map((rung) => (
            <PlChip key={rung} variant={rung === at ? 'solid' : 'glass'} size="sm">
              {rung}
            </PlChip>
          ))}
        </div>

        <PlTypography level="body">
          The window is on <strong>{at}</strong>, so <code>{'{ xs: 1, sm: 2, lg: 4 }'}</code>{' '}
          resolves to <strong>{columns}</strong>. Narrow the browser and both change.
        </PlTypography>

        <div className="grid gap-2" style={{ gridTemplateColumns: `repeat(${columns}, 1fr)` }}>
          {Array.from({ length: 4 }, (_, index) => (
            <div
              key={index}
              className="rounded-(--plass-radius-sm) bg-(--plass-glass-press) p-3 text-center text-sm"
            >
              {index + 1}
            </div>
          ))}
        </div>
      </div>
    </PlCard>
  );
}
