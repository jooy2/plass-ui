import { PlProgressLinear } from 'plass-ui';

export default function ProgressLinearIndeterminate() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-6">
      <PlProgressLinear label="Known" value={45} showValue />
      <PlProgressLinear label="Unknown" />
    </div>
  );
}
