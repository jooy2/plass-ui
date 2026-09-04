import { useRef, useState } from 'react';
import { PlButton, PlCard, PlTextField, PlTour } from 'plass-ui';

export default function TourHero() {
  const filter = useRef<HTMLDivElement>(null);
  const save = useRef<HTMLButtonElement>(null);
  const [running, setRunning] = useState(false);

  return (
    <PlCard className="w-full max-w-md" size="sm">
      <div className="flex items-end gap-2">
        <div ref={filter} className="flex-1">
          <PlTextField size="sm" label="Search" placeholder="Anything at all" fullWidth />
        </div>
        <PlButton ref={save} size="sm">
          Save
        </PlButton>
      </div>

      <PlButton size="sm" variant="ghost" onClick={() => setRunning(true)}>
        Show me around
      </PlButton>

      <PlTour
        open={running}
        onOpenChange={setRunning}
        // Nothing scrolls inside a documentation page, and a smooth scroll
        // would move the page around whoever is reading it.
        scrollIntoView={false}
        steps={[
          {
            target: filter,
            title: 'Narrow the list',
            content: 'Type anything here and the list below follows along.'
          },
          {
            target: save,
            title: 'Keep what you found',
            content: 'A saved search comes back next time you open this.',
            side: 'top',
            align: 'end'
          },
          { title: 'That is all of it', content: 'Everything else works the way you expect.' }
        ]}
      />
    </PlCard>
  );
}
