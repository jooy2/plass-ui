import { PlIcon } from 'plass-ui';

function BellIcon() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6">
      <path d="M18 8a6 6 0 1 0-12 0c0 6-2 7-2 7h16s-2-1-2-7" strokeLinejoin="round" />
      <path d="M13.7 20a2 2 0 0 1-3.4 0" strokeLinecap="round" />
    </svg>
  );
}

export default function IconSizes() {
  return (
    <div className="flex flex-wrap items-end gap-6">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <div key={size} className="flex flex-col items-center gap-2">
          <PlIcon icon={<BellIcon />} size={size} />
          <span className="text-xs text-(--plass-muted-fg)">{size}</span>
        </div>
      ))}
    </div>
  );
}
