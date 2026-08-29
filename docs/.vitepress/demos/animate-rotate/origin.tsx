import { PlAnimateRotate, PlBox } from 'plass-ui';

export default function AnimateRotateOrigin() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-10">
      {['center', 'bottom left'].map((origin) => (
        <PlAnimateRotate
          key={origin}
          origin={origin}
          from={-30}
          duration={1400}
          repeat="infinite"
          alternate
          fade={false}
        >
          <PlBox size="sm">{origin}</PlBox>
        </PlAnimateRotate>
      ))}
    </div>
  );
}
