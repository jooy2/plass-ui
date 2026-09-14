import { useState } from 'react';
import { PlAnimateMarquee, PlButton, PlChip } from 'plass-ui';

const updates = [
  'Build 412 passed',
  'Staging deployed',
  'Two reviews waiting',
  'Backup finished',
  'Cache cleared',
  'Release notes drafted'
];

export default function AnimateMarqueePaused() {
  const [paused, setPaused] = useState(false);

  return (
    <div className="flex w-full max-w-md flex-col items-center gap-4">
      <PlButton size="sm" onClick={() => setPaused((previous) => !previous)}>
        {paused ? 'Play' : 'Pause'}
      </PlButton>

      <PlAnimateMarquee className="w-full" gap="1rem" speed={45} paused={paused}>
        {updates.map((update) => (
          <PlChip key={update}>{update}</PlChip>
        ))}
      </PlAnimateMarquee>
    </div>
  );
}
