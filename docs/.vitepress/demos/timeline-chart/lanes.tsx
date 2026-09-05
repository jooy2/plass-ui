import { PlTimelineChart } from 'plass-ui';

const hour = (h: number) => new Date(2026, 0, 5, h);

const rooms = [
  {
    name: 'Studio A',
    data: [
      { start: hour(9), end: hour(12), label: 'Standup' },
      { start: hour(10), end: hour(14), label: 'Workshop' },
      { start: hour(15), end: hour(18), label: 'Review' }
    ]
  },
  {
    name: 'Studio B',
    data: [{ start: hour(11), end: hour(17), label: 'Recording' }]
  }
];

export default function TimelineChartLanes() {
  return <PlTimelineChart className="w-full" label="Room bookings" series={rooms} height={180} />;
}
