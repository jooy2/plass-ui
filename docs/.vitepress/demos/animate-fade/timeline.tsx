import { PlAnimateFade, PlCard } from 'plass-ui';

export default function AnimateFadeTimeline() {
  return (
    <div className="h-64 w-full max-w-sm overflow-y-auto rounded-xl">
      <div className="h-48" />

      <PlAnimateFade timeline="view">
        <PlCard title="Scroll me">
          The card is not waiting for a moment. It is reading the scroll position, so scrolling back
          up plays it backwards.
        </PlCard>
      </PlAnimateFade>

      <div className="h-64" />
    </div>
  );
}
