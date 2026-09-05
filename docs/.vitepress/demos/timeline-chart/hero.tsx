import { PlTimelineChart } from 'plass-ui';

const day = (n: number) => new Date(2026, 0, n);

const plan = [
  {
    name: 'Research',
    data: [{ start: day(2), end: day(12), label: 'Interviews' }]
  },
  {
    name: 'Design',
    data: [
      { start: day(9), end: day(20), label: 'Wireframes' },
      { start: day(22), end: day(34), label: 'Visuals' }
    ]
  },
  {
    name: 'Build',
    data: [{ start: day(18), end: day(52), label: 'Implementation' }]
  },
  {
    name: 'Launch',
    data: [{ start: day(50), end: day(58), label: 'Rollout' }]
  }
];

export default function TimelineChartHero() {
  return <PlTimelineChart className="w-full" label="Project plan" series={plan} height={220} />;
}
