import { PlAnimateRotate, PlChip } from 'plass-ui';

export default function AnimateRotateSpin() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-8">
      <PlAnimateRotate from={-90} duration={1600} repeat="infinite" alternate>
        <PlChip color="primary">an arrival</PlChip>
      </PlAnimateRotate>

      <PlAnimateRotate
        from={0}
        to={360}
        duration={3000}
        easing="linear"
        repeat="infinite"
        fade={false}
      >
        <PlChip color="secondary">a spin</PlChip>
      </PlAnimateRotate>
    </div>
  );
}
