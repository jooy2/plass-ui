import { PlHeatmapChart } from 'plass-ui';

const hours = ['00', '03', '06', '09', '12', '15', '18', '21'];

const week = [
  { name: 'Mon', data: [2, 1, 4, 18, 26, 22, 14, 6] },
  { name: 'Tue', data: [1, 1, 5, 21, 29, 24, 15, 5] },
  { name: 'Wed', data: [2, 2, 6, 23, 31, 27, 16, 7] },
  { name: 'Thu', data: [3, 1, 5, 20, 28, 25, 18, 9] },
  { name: 'Fri', data: [4, 2, 6, 17, 24, 20, 21, 14] },
  { name: 'Sat', data: [8, 5, 4, 9, 12, 15, 19, 17] },
  { name: 'Sun', data: [7, 4, 3, 8, 11, 13, 16, 12] }
];

export default function HeatmapChartHero() {
  return (
    <PlHeatmapChart className="w-full" label="Sessions by hour" series={week} categories={hours} />
  );
}
