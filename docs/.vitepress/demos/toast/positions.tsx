import { useState } from 'react';
import { PlButton, PlSegment, PlSegmentedButton, PlToastProvider, usePlToast } from 'plass-ui';

type Position =
  'top-start' | 'top-center' | 'top-end' | 'bottom-start' | 'bottom-center' | 'bottom-end';

function Raise({ position }: { position: Position }) {
  const toast = usePlToast();

  return (
    <PlButton size="sm" onClick={() => toast.add({ title: position })}>
      Raise it
    </PlButton>
  );
}

export default function ToastPositions() {
  const [position, setPosition] = useState<Position>('bottom-end');

  return (
    <div className="flex flex-col gap-3">
      <PlSegmentedButton
        size="xs"
        aria-label="Position"
        value={position}
        onValueChange={(next) => setPosition(next as Position)}
      >
        <PlSegment value="top-start">top-start</PlSegment>
        <PlSegment value="top-center">top-center</PlSegment>
        <PlSegment value="top-end">top-end</PlSegment>
      </PlSegmentedButton>

      <PlSegmentedButton
        size="xs"
        aria-label="Position"
        value={position}
        onValueChange={(next) => setPosition(next as Position)}
      >
        <PlSegment value="bottom-start">bottom-start</PlSegment>
        <PlSegment value="bottom-center">bottom-center</PlSegment>
        <PlSegment value="bottom-end">bottom-end</PlSegment>
      </PlSegmentedButton>

      <PlToastProvider key={position} position={position} timeout={2500}>
        <Raise position={position} />
      </PlToastProvider>
    </div>
  );
}
