import { PlProgressCircular } from 'plass-ui';

export default function ProgressCircularIndeterminate() {
  return (
    <div className="flex flex-col items-start gap-5">
      <PlProgressCircular label="Known" value={45} showValue />
      <PlProgressCircular label="Unknown" />
    </div>
  );
}
