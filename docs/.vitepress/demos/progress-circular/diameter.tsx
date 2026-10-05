import { PlProgressCircular } from 'plass-ui';

export default function ProgressCircularDiameter() {
  return (
    <div className="flex flex-wrap items-center gap-8">
      <PlProgressCircular diameter={64} label="Preparing" />
      <PlProgressCircular diameter={96} size="lg" value={72} showValue />
    </div>
  );
}
