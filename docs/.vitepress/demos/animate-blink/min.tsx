import { PlAnimateBlink, PlChip } from 'plass-ui';

export default function AnimateBlinkMin() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-3">
      {[0, 0.3, 0.6].map((min) => (
        <PlAnimateBlink key={min} min={min} duration={1400}>
          <PlChip color="danger">min={min}</PlChip>
        </PlAnimateBlink>
      ))}
    </div>
  );
}
