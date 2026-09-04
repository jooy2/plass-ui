import { useRef, useState } from 'react';
import { PlButton, PlCard, PlTour } from 'plass-ui';

export default function TourSides() {
  const middle = useRef<HTMLButtonElement>(null);
  const [running, setRunning] = useState(false);

  return (
    <PlCard className="w-full max-w-md items-center" size="sm">
      <PlButton ref={middle} size="sm" variant="ghost">
        The target
      </PlButton>

      <PlButton size="sm" onClick={() => setRunning(true)}>
        Walk round it
      </PlButton>

      <PlTour
        open={running}
        onOpenChange={setRunning}
        scrollIntoView={false}
        steps={[
          { target: middle, title: 'Below', side: 'bottom' },
          { target: middle, title: 'Above', side: 'top' },
          { target: middle, title: 'Beside it', side: 'right', align: 'start' },
          // No target: the card goes to the middle and nothing is cut out.
          { title: 'And nowhere in particular' }
        ]}
      />
    </PlCard>
  );
}
