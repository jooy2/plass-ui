import { PlPieChart } from 'plass-ui';

const spend = [46, 31, 23];

const teams = ['Engineering', 'Marketing', 'Support'];

const rings = [
  { innerRadius: 0, padAngle: 0, caption: 'A filled disc, closed up' },
  { innerRadius: 0.5, padAngle: 0, caption: 'Half open, closed up' },
  { innerRadius: 0.8, padAngle: 6, caption: 'A thin band, in segments' }
];

export default function PieChartRing() {
  return (
    <div className="grid w-full gap-6 sm:grid-cols-3">
      {rings.map((ring) => (
        <PlPieChart
          key={ring.caption}
          data={spend}
          categories={teams}
          innerRadius={ring.innerRadius}
          padAngle={ring.padAngle}
          height={160}
          label={ring.caption}
          legend={false}
        />
      ))}
    </div>
  );
}
