import { PlAnimateLighting, PlCard, PlChip } from 'plass-ui';

export default function AnimateLightingHero() {
  return (
    <PlAnimateLighting className="w-full max-w-sm" size="lg" color="primary">
      <PlCard
        size="lg"
        title="Recommended"
        subtitle="Team — £29 a seat"
        headerAction={<PlChip size="sm">Most picked</PlChip>}
      >
        Unlimited projects, audit log, and single sign-on.
      </PlCard>
    </PlAnimateLighting>
  );
}
