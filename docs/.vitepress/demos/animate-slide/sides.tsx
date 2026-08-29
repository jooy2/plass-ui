import { PlAnimateSlide, PlChip } from 'plass-ui';

const sides = ['top', 'right', 'bottom', 'left'] as const;

export default function AnimateSlideSides() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-4">
      {sides.map((side) => (
        <PlAnimateSlide
          key={side}
          from={side}
          distance={24}
          duration={1200}
          repeat="infinite"
          alternate
        >
          <PlChip>{side}</PlChip>
        </PlAnimateSlide>
      ))}
    </div>
  );
}
