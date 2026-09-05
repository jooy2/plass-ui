import { PlAreaChart } from 'plass-ui';

const plans = [
  { name: 'Free', data: [62, 58, 54, 49, 44, 40] },
  { name: 'Pro', data: [30, 33, 35, 38, 41, 43] },
  { name: 'Team', data: [8, 9, 11, 13, 15, 17] }
];

const quarters = ['Q1 24', 'Q2 24', 'Q3 24', 'Q4 24', 'Q1 25', 'Q2 25'];

export default function AreaChartShare() {
  return <PlAreaChart className="w-full" series={plans} categories={quarters} stacked="full" />;
}
