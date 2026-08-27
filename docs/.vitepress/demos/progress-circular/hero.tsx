import { PlProgressCircular } from 'plass-ui';

export default function ProgressCircularHero() {
  return (
    <div className="flex flex-col items-start gap-5">
      <PlProgressCircular label="Syncing" value={68} showValue />
      <PlProgressCircular label="Reticulating splines" />
    </div>
  );
}
