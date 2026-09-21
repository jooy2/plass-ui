import { PlBarChart } from 'plass-ui';

const sources = [
  {
    name: 'Sessions',
    data: [4820, 3910, 2740, 1980, 1120, 860]
  }
];

const channels = [
  'Organic search',
  'Direct traffic',
  'Email campaigns',
  'Paid social',
  'Referral links',
  'Affiliate partners'
];

export default function BarChartTickAngle() {
  return (
    <PlBarChart
      className="w-full"
      series={sources}
      categories={channels}
      height={300}
      xAxis={{ tickAngle: -45 }}
      legend={false}
    />
  );
}
