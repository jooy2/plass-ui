import { PlLineChart } from 'plass-ui';

const revenue = [
  { name: 'Actual', data: [128, 142, 139, 156, 171, null, null, null] },
  // The same line, picked up where the readings stop. `dashed` is what says the
  // rest of it is a projection rather than a measurement.
  { name: 'Forecast', data: [null, null, null, null, 171, 184, 192, 205], dashed: true }
];

const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'];

export default function LineChartDashed() {
  return (
    <PlLineChart
      className="w-full"
      series={revenue}
      categories={months}
      connectNulls
      xAxis={{ label: 'Month' }}
    />
  );
}
