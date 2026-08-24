import { PlBadge } from 'plass-ui';

export default function BadgeSizes() {
  return (
    <div className="flex flex-wrap items-center gap-4">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <PlBadge key={size} size={size} content={12} />
      ))}
    </div>
  );
}
