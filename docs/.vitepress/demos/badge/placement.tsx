import { PlBadge, PlButton } from 'plass-ui';

export default function BadgePlacement() {
  return (
    <div className="flex flex-wrap items-center gap-8">
      {(['top-start', 'top-end', 'bottom-start', 'bottom-end'] as const).map((placement) => (
        <PlBadge key={placement} content={3} placement={placement}>
          <PlButton variant="glass" color="secondary" size="sm">
            {placement}
          </PlButton>
        </PlBadge>
      ))}
    </div>
  );
}
