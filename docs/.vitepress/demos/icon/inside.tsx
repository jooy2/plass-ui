import { PlAlert, PlButton, PlIcon } from 'plass-ui';

function BoltIcon() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6">
      <path d="M13 2 4 14h7l-1 8 9-12h-7Z" strokeLinejoin="round" />
    </svg>
  );
}

export default function IconInside() {
  return (
    <div className="flex w-full max-w-md flex-col items-start gap-4">
      <PlButton startIcon={<PlIcon icon={<BoltIcon />} size="sm" />}>Deploy now</PlButton>

      <PlAlert color="warning" icon={<PlIcon icon={<BoltIcon />} size="sm" />}>
        The build is running on the fast queue.
      </PlAlert>

      <p className="text-sm text-(--plass-muted-fg)">
        <PlIcon icon={<BoltIcon />} size="xs" /> Sits in a sentence at the sentence’s own colour.
      </p>
    </div>
  );
}
