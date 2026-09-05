import { PlGaugeChart } from 'plass-ui';

const bands = [
  { from: 70, color: 'warning' as const },
  { from: 90, color: 'danger' as const }
];

export default function GaugeChartThresholds() {
  return (
    <div className="grid w-full gap-4 sm:grid-cols-3">
      {[42, 78, 96].map((value) => (
        <PlGaugeChart
          key={value}
          label={`Disk at ${value} percent`}
          value={value}
          thresholds={bands}
          height={160}
          caption="disk"
        />
      ))}
    </div>
  );
}
