import { PlLineChart } from 'plass-ui';

const uptime = [
  {
    name: 'Requests',
    // The sensor was offline for two hours. That is a gap, not a collapse.
    data: [820, 910, 880, 960, null, null, 1040, 990, 1120]
  }
];

const hours = ['09', '10', '11', '12', '13', '14', '15', '16', '17'];

export default function LineChartGaps() {
  return (
    <PlLineChart
      className="w-full"
      series={uptime}
      categories={hours}
      markers="all"
      xAxis={{ label: 'Hour' }}
    />
  );
}
