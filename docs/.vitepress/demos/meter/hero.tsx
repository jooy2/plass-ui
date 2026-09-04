import { PlMeter } from 'plass-ui';

export default function MeterHero() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-5">
      <PlMeter
        value={18}
        max={100}
        label="Documents"
        showValue
        format={{ style: 'unit', unit: 'gigabyte', maximumFractionDigits: 0 }}
      />
      <PlMeter value={62} label="Seats taken" showValue />
      <PlMeter
        value={94}
        label="Disk used"
        showValue
        thresholds={[
          { from: 75, color: 'warning' },
          { from: 90, color: 'danger' }
        ]}
      />
    </div>
  );
}
