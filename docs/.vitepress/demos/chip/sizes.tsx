import { PlChip } from 'plass-ui';

export default function ChipSizes() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <PlChip key={size} size={size}>
          {size}
        </PlChip>
      ))}
    </div>
  );
}
