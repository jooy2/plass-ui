import { PlScatterChart } from 'plass-ui';

const markets = [
  {
    name: 'Europe',
    data: [
      { x: 8.2, y: 62, z: 84 },
      { x: 11.4, y: 71, z: 47 },
      { x: 6.9, y: 55, z: 120 }
    ]
  },
  {
    name: 'Asia',
    data: [
      { x: 14.1, y: 48, z: 260 },
      { x: 9.6, y: 66, z: 31 },
      { x: 12.8, y: 59, z: 175 }
    ]
  }
];

export default function ScatterChartBubbles() {
  return (
    <PlScatterChart
      className="w-full"
      series={markets}
      label="Growth against margin"
      xAxis={{ label: 'Growth (%)' }}
      yAxis={{ label: 'Margin (%)' }}
    />
  );
}
