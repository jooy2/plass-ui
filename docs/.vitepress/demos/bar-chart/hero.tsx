import { PlBarChart } from 'plass-ui';

const revenue = [
  { name: 'This year', data: [42, 58, 31, 47, 39] },
  { name: 'Last year', data: [35, 44, 38, 41, 30] }
];

const regions = ['Europe', 'Asia', 'Americas', 'Africa', 'Oceania'];

export default function BarChartHero() {
  return (
    <PlBarChart
      className="w-full"
      series={revenue}
      categories={regions}
      yAxis={{ label: 'Revenue (£m)' }}
    />
  );
}
