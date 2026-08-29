import { useState } from 'react';
import { PlAnimateAppear, PlButton, PlCard } from 'plass-ui';

const rows = [
  { name: 'api-gateway', status: 'Deployed 2 minutes ago' },
  { name: 'billing', status: 'Deployed 14 minutes ago' },
  { name: 'search-index', status: 'Rebuilding' },
  { name: 'mailer', status: 'Deployed yesterday' }
];

export default function AnimateAppearHero() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <PlButton size="sm" variant="glass" color="secondary" onClick={() => setRun(run + 1)}>
        Play again
      </PlButton>

      <PlAnimateAppear key={run} className="flex w-full max-w-sm flex-col gap-2">
        {rows.map((row) => (
          <PlCard key={row.name} size="sm" title={row.name} subtitle={row.status} />
        ))}
      </PlAnimateAppear>
    </div>
  );
}
