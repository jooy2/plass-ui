import { PlProgressLinear } from 'plass-ui';

export default function ProgressLinearFormat() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-6">
      <PlProgressLinear label="Percentage of the range" value={3} max={4} showValue />
      <PlProgressLinear
        label="Downloaded"
        value={148}
        max={512}
        showValue
        format={{ style: 'unit', unit: 'megabyte', unitDisplay: 'narrow' }}
      />
    </div>
  );
}
