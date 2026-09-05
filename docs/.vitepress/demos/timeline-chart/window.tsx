import { PlTimelineChart } from 'plass-ui';

const day = (n: number) => new Date(2026, 0, n);

const work = [
  { name: 'Migration', data: [{ start: day(-40), end: day(24), label: 'Data migration' }] },
  { name: 'Rewrite', data: [{ start: day(5), end: day(70), label: 'Service rewrite' }] }
];

export default function TimelineChartWindow() {
  return (
    <PlTimelineChart
      className="w-full"
      label="This quarter"
      series={work}
      min={day(1)}
      max={day(31)}
      height={140}
    />
  );
}
