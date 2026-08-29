import { PlAnimateGrow, PlBox } from 'plass-ui';

const origins = ['center', 'top', 'bottom right'];

export default function AnimateGrowOrigin() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-4">
      {origins.map((origin) => (
        <PlAnimateGrow
          key={origin}
          origin={origin}
          from={0.4}
          duration={1400}
          repeat="infinite"
          alternate
        >
          <PlBox size="sm">{origin}</PlBox>
        </PlAnimateGrow>
      ))}
    </div>
  );
}
