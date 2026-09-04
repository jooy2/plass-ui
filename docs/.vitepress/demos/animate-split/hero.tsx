import { PlAnimateSplit } from 'plass-ui';

export default function AnimateSplitHero() {
  return (
    <PlAnimateSplit
      className="max-w-md text-3xl leading-tight font-semibold"
      effect="slide"
      stagger={60}
    >
      One design language, two libraries
    </PlAnimateSplit>
  );
}
