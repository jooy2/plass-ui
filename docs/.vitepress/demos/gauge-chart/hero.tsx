import { PlGaugeChart } from 'plass-ui';

export default function GaugeChartHero() {
  return (
    <PlGaugeChart
      className="w-full max-w-xs"
      label="Storage used"
      value={1.36}
      min={0}
      max={2}
      caption="TB of 2 TB used"
      format={{ maximumFractionDigits: 2 }}
    />
  );
}
