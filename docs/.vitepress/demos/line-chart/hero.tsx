import { PlLineChart } from 'plass-ui';
import { months, revenue } from './data';

export default function LineChartHero() {
  return (
    <PlLineChart
      className="w-full"
      series={revenue}
      categories={months}
      yAxis={{ label: 'Revenue (£k)' }}
      format={{ style: 'currency', currency: 'GBP', maximumFractionDigits: 0 }}
    />
  );
}
