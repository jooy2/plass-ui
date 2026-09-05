import { PlPieChart } from 'plass-ui';

const devices = [58, 34, 8];

const kinds = ['Mobile', 'Desktop', 'Tablet'];

export default function PieChartValueLabels() {
  return (
    <PlPieChart
      className="w-full"
      data={devices}
      categories={kinds}
      shape="donut"
      valueLabels="all"
      label="Sessions by device"
    />
  );
}
