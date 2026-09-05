import { PlPieChart } from 'plass-ui';

const traffic = [42, 27, 18, 9, 4];

const sources = ['Search', 'Direct', 'Social', 'Referral', 'Email'];

export default function PieChartHero() {
  return <PlPieChart className="w-full" data={traffic} categories={sources} label="Traffic" />;
}
