import { PlAreaChart } from 'plass-ui';

const traffic = [
  { name: 'Direct', data: [1200, 1350, 1280, 1520, 1610, 1740] },
  { name: 'Search', data: [980, 1120, 1240, 1180, 1390, 1520] },
  { name: 'Referral', data: [420, 460, 510, 480, 560, 610] }
];

const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

export default function AreaChartHero() {
  return (
    <PlAreaChart
      className="w-full"
      series={traffic}
      categories={months}
      stacked
      curve="smooth"
      yAxis={{ label: 'Sessions' }}
    />
  );
}
