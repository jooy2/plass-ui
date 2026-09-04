import { PlFloatingActionButton } from 'plass-ui';

function Plus() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path d="M8 3.5v9M3.5 8h9" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" />
    </svg>
  );
}

export default function FloatingActionButtonExtended() {
  return (
    <div className="flex items-center justify-center gap-5">
      <PlFloatingActionButton floating={false} icon={<Plus />} label="New project" />
      <PlFloatingActionButton floating={false} extended icon={<Plus />} label="New project" />
    </div>
  );
}
