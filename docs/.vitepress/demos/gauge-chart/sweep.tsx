import { PlGaugeChart } from 'plass-ui';

export default function GaugeChartSweep() {
  return (
    <div className="grid w-full gap-4 sm:grid-cols-3">
      {[180, 270, 360].map((sweep) => (
        <PlGaugeChart
          key={sweep}
          label={`Load at ${sweep} degrees`}
          value={62}
          sweep={sweep}
          height={160}
          caption={`${sweep}°`}
        />
      ))}
    </div>
  );
}
