import { PlAnimateFade, PlChip } from 'plass-ui';

export default function AnimateFadeMode() {
  return (
    <div className="flex items-center gap-3">
      <PlAnimateFade duration={1200} repeat="infinite" alternate>
        <PlChip color="success">in</PlChip>
      </PlAnimateFade>

      <PlAnimateFade mode="out" duration={1200} repeat="infinite" alternate>
        <PlChip color="danger">out</PlChip>
      </PlAnimateFade>
    </div>
  );
}
