import { PlAreaChart } from 'plass-ui';

const load = [
  { name: 'Capacity', data: [100, 100, 100, 100, 100, 100, 100] },
  { name: 'Peak load', data: [42, 61, 88, 71, 94, 56, 38] }
];

const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

export default function AreaChartOverlap() {
  return (
    <PlAreaChart
      className="w-full"
      series={load}
      categories={days}
      curve="smooth"
      format={{ style: 'unit', unit: 'percent' }}
    />
  );
}
