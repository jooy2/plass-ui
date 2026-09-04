import { useRef, useState } from 'react';
import { PlButton, PlCard, PlSwitch, PlTour } from 'plass-ui';

export default function TourMask() {
  const target = useRef<HTMLButtonElement>(null);
  const [running, setRunning] = useState(false);
  const [mask, setMask] = useState(true);

  return (
    <PlCard className="w-full max-w-md" size="sm">
      <PlSwitch size="sm" checked={mask} onCheckedChange={setMask} label="Dim the page" />

      <div className="flex gap-2">
        <PlButton ref={target} size="sm" variant="ghost">
          The thing being pointed at
        </PlButton>
      </div>

      <PlButton size="sm" onClick={() => setRunning(true)}>
        Start
      </PlButton>

      <PlTour
        open={running}
        onOpenChange={setRunning}
        mask={mask}
        scrollIntoView={false}
        steps={[
          {
            target,
            title: 'Try pressing it',
            content: 'The light is a hole in the dimming, so what is inside it still answers.'
          }
        ]}
      />
    </PlCard>
  );
}
