import { PlAnimateRotate, PlIcon } from 'plass-ui';

function RefreshGlyph() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8">
      <path d="M20 12a8 8 0 1 1-2.6-5.9" strokeLinecap="round" />
      <path d="M20 4v5h-5" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function ChevronGlyph() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8">
      <path d="m6 9 6 6 6-6" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

export default function AnimateRotateHero() {
  return (
    <div className="flex items-center gap-10">
      <PlAnimateRotate
        from={0}
        to={360}
        duration={2400}
        easing="linear"
        repeat="infinite"
        fade={false}
      >
        <PlIcon icon={<RefreshGlyph />} size="xl" color="primary" label="Syncing" />
      </PlAnimateRotate>

      <PlAnimateRotate from={-180} duration={1600} repeat="infinite" alternate fade={false}>
        <PlIcon icon={<ChevronGlyph />} size="xl" color="secondary" />
      </PlAnimateRotate>
    </div>
  );
}
