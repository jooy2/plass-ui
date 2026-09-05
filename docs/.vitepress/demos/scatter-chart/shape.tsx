import { PlScatterChart } from 'plass-ui';

const runs = [1, 2, 3, 4, 5].map((n) => ({
  name: `Run ${n}`,
  data: [
    { x: n * 4, y: 20 + n * 6 },
    { x: n * 4 + 9, y: 34 + n * 4 },
    { x: n * 4 + 17, y: 26 + n * 7 }
  ]
}));

export default function ScatterChartShape() {
  return <PlScatterChart className="w-full" series={runs} label="Five runs" shape="varied" />;
}
