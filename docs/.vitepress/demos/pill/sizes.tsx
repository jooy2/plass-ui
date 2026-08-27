import { PlPill } from 'plass-ui';

export default function PillSizes() {
  return (
    <div className="flex flex-col items-center gap-3">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <PlPill key={size} size={size} color="success" title={`size: ${size}`} />
      ))}
    </div>
  );
}
