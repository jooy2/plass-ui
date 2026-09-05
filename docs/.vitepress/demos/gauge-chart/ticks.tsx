import { PlGaugeChart } from 'plass-ui';

export default function GaugeChartTicks() {
  return (
    <PlGaugeChart
      className="w-full max-w-xs"
      label="Line pressure"
      value={4.2}
      min={0}
      max={6}
      sweep={270}
      ticks={7}
      caption="bar"
      format={{ maximumFractionDigits: 1 }}
    />
  );
}
