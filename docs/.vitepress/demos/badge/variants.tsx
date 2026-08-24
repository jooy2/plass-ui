import { PlBadge } from 'plass-ui';

export default function BadgeVariants() {
  return (
    <div className="flex flex-wrap items-center gap-4">
      {(['solid', 'glass', 'ghost'] as const).map((variant) => (
        <PlBadge key={variant} variant={variant} content={variant} />
      ))}
    </div>
  );
}
