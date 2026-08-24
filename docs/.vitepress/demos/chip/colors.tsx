import { PlChip } from 'plass-ui';

export default function ChipColors() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      {(['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const).map((color) => (
        <PlChip key={color} color={color}>
          {color}
        </PlChip>
      ))}
    </div>
  );
}
