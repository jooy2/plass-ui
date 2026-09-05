import { PlHeatmapChart } from 'plass-ui';

const quarters = ['Q1', 'Q2', 'Q3', 'Q4'];

const regions = [
  { name: 'Europe', data: [-8, -2, 5, 12] },
  { name: 'Asia', data: [3, 9, 14, 18] },
  { name: 'Americas', data: [-14, -9, -3, 2] }
];

export default function HeatmapChartDiverging() {
  return (
    <PlHeatmapChart
      className="w-full"
      label="Growth against last year"
      scale="diverging"
      series={regions}
      categories={quarters}
      valueLabels="all"
      height={200}
      format={{ signDisplay: 'exceptZero' }}
    />
  );
}
