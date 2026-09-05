import { PlScatterChart } from 'plass-ui';

const stores = [
  {
    name: 'Owned',
    data: [
      { x: 12, y: 41 },
      { x: 19, y: 55 },
      { x: 25, y: 52 },
      { x: 31, y: 74 },
      { x: 38, y: 81 },
      { x: 44, y: 78 },
      { x: 52, y: 96 }
    ]
  },
  {
    name: 'Franchise',
    data: [
      { x: 15, y: 28 },
      { x: 22, y: 34 },
      { x: 29, y: 31 },
      { x: 36, y: 47 },
      { x: 47, y: 51 },
      { x: 55, y: 62 }
    ]
  }
];

export default function ScatterChartHero() {
  return (
    <PlScatterChart
      className="w-full"
      series={stores}
      label="Revenue against floor area"
      xAxis={{ label: 'Floor area (m²)' }}
      yAxis={{ label: 'Revenue (£k)' }}
    />
  );
}
