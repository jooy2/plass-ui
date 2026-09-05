import { PlBarChart } from 'plass-ui';

const change = [{ name: 'Net change', data: [12, -8, 24, -3, 18, -14, 9] }];

const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];

export default function BarChartNegative() {
  return (
    <PlBarChart
      className="w-full"
      series={change}
      categories={months}
      valueLabels="all"
      legend={false}
      format={{ signDisplay: 'exceptZero' }}
    />
  );
}
