import { PlIcon } from 'plass-ui';

function BoltIcon() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6">
      <path d="M13 2 4 14h7l-1 8 9-12h-7Z" strokeLinejoin="round" />
    </svg>
  );
}

export default function IconColors() {
  return (
    <div className="flex flex-wrap items-center gap-6 text-(--plass-muted-fg)">
      <PlIcon icon={<BoltIcon />} />
      {(['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const).map((color) => (
        <PlIcon key={color} icon={<BoltIcon />} color={color} />
      ))}
    </div>
  );
}
