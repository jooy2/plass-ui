import { PlLineChart } from 'plass-ui';

const latency = [
  {
    name: 'p95 latency',
    data: [180, 210, 240, 205, 260, 320, 280, 230]
  }
];

const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Mon'];

export default function LineChartReference() {
  return (
    <PlLineChart
      className="w-full"
      series={latency}
      categories={days}
      markers="all"
      reference={[
        { value: 250, label: 'Budget' },
        { value: 300, label: 'Breach', color: 'danger' }
      ]}
      yAxis={{ label: 'ms' }}
    />
  );
}
