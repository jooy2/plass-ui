import { PlAnimateFade, PlChip } from 'plass-ui';

export default function AnimateFadeStagger() {
  return (
    <PlAnimateFade
      className="flex flex-wrap items-center justify-center gap-2"
      stagger={90}
      duration={500}
    >
      <PlChip>Queued</PlChip>
      <PlChip>Building</PlChip>
      <PlChip>Testing</PlChip>
      <PlChip>Deploying</PlChip>
      <PlChip>Live</PlChip>
    </PlAnimateFade>
  );
}
