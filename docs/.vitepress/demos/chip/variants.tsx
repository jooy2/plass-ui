import { PlChip } from 'plass-ui';

export default function ChipVariants() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      {(['solid', 'glass', 'ghost'] as const).map((variant) => (
        <PlChip key={variant} variant={variant}>
          {variant}
        </PlChip>
      ))}
    </div>
  );
}
