import { PlLineChart } from 'plass-ui';
import { months, revenue } from './data';

export default function LineChartLabels() {
  return (
    <PlLineChart
      className="w-full"
      size="sm"
      series={revenue.slice(0, 2)}
      categories={months}
      valueLabels="last"
      markers="none"
      yAxis={{ hidden: true }}
      format={{ style: 'currency', currency: 'GBP', maximumFractionDigits: 0 }}
    />
  );
}
