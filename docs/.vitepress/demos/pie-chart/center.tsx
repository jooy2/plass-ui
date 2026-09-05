import { PlPieChart } from 'plass-ui';

const plans = [1840, 620, 210];

const tiers = ['Starter', 'Team', 'Enterprise'];

export default function PieChartCenter() {
  return (
    <PlPieChart
      className="w-full"
      data={plans}
      categories={tiers}
      shape="donut"
      label="Accounts by plan"
      center={
        <>
          <span className="text-2xl font-semibold text-(--plass-fg)">2,670</span>
          <span className="text-xs text-(--plass-muted-fg)">accounts</span>
        </>
      }
    />
  );
}
