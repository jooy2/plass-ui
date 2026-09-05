import { PlHeatmapChart } from 'plass-ui';

const spend = [
  {
    name: 'Infrastructure',
    data: [
      { x: 'Compute', y: 4200 },
      { x: 'Storage', y: 1800 },
      { x: 'Network', y: 900 }
    ]
  },
  {
    name: 'Tooling',
    data: [
      { x: 'CI', y: 1200 },
      { x: 'Monitoring', y: 700 },
      { x: 'Analytics', y: 480 }
    ]
  },
  {
    name: 'People',
    data: [
      { x: 'Licences', y: 2600 },
      { x: 'Training', y: 640 }
    ]
  }
];

export default function HeatmapChartTreemap() {
  return (
    <PlHeatmapChart
      className="w-full"
      label="Monthly spend"
      shape="treemap"
      series={spend}
      valueLabels="all"
      height={280}
    />
  );
}
