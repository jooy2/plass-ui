import { PlChip } from 'plass-ui';

export default function ChipSelected() {
  return (
    <div className="flex flex-col gap-4">
      {(['solid', 'glass', 'ghost'] as const).map((variant) => (
        <div key={variant} className="flex flex-wrap items-center gap-3">
          <span className="w-14 text-xs text-(--plass-muted-fg)">{variant}</span>
          <PlChip variant={variant} onClick={() => {}}>
            off
          </PlChip>
          <PlChip variant={variant} selected onClick={() => {}}>
            on
          </PlChip>
        </div>
      ))}
    </div>
  );
}
