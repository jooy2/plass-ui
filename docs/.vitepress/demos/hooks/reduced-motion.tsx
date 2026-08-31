import { PlAlert, PlAnimateRotate, PlProgressCircular, usePlReducedMotion } from 'plass-ui';

export default function ReducedMotionDemo() {
  const still = usePlReducedMotion();

  return (
    <div className="flex w-full flex-col items-center gap-4">
      <PlAlert size="sm" color={still ? 'success' : 'info'} className="w-full">
        <code>usePlReducedMotion()</code> — {String(still)}. Change it in your system settings and
        this updates without a reload.
      </PlAlert>

      <div className="flex items-center gap-8">
        <div className="flex flex-col items-center gap-2">
          <PlAnimateRotate from={0} to={360} repeat="infinite" easing="linear" duration={3000}>
            <span className="text-2xl">✦</span>
          </PlAnimateRotate>
          <span className="text-xs text-(--plass-muted-fg)">Decoration — stops</span>
        </div>

        <div className="flex flex-col items-center gap-2">
          <PlProgressCircular size="md" />
          <span className="text-xs text-(--plass-muted-fg)">Loading — slows</span>
        </div>
      </div>
    </div>
  );
}
