import { PlButton } from 'plass-ui';

function PlusIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.8" aria-hidden="true">
      <path d="M8 3.5v9M3.5 8h9" strokeLinecap="round" />
    </svg>
  );
}

function ArrowIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.8" aria-hidden="true">
      <path d="M3.5 8h9M9 4.5 12.5 8 9 11.5" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

export default function ButtonIcons() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <PlButton startIcon={<PlusIcon />}>New project</PlButton>
      <PlButton variant="glass" endIcon={<ArrowIcon />}>
        Continue
      </PlButton>
      <PlButton aria-label="Add" startIcon={<PlusIcon />} />
      <PlButton variant="ghost" aria-label="Add" startIcon={<PlusIcon />} />
    </div>
  );
}
