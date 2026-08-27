import { PlProgressLinear } from 'plass-ui';

export default function ProgressLinearHero() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-6">
      <PlProgressLinear label="Uploading" value={62} showValue />
      <PlProgressLinear label="Rebuilding index" />
    </div>
  );
}
