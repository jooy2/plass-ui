import { PlBarChart } from 'plass-ui';

const sources = [
  {
    name: 'Sessions',
    data: [4820, 3910, 2740, 1980, 1120]
  }
];

const channels = [
  'Organic search',
  'Direct traffic',
  'Email campaigns',
  'Paid social',
  'Referral links'
];

export default function BarChartOrientation() {
  return (
    <PlBarChart
      className="w-full"
      series={sources}
      categories={channels}
      orientation="horizontal"
      valueLabels="all"
      legend={false}
    />
  );
}
