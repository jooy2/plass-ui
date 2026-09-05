import { PlPieChart } from 'plass-ui';

const spend = [46, 31, 23];

const teams = ['Engineering', 'Marketing', 'Support'];

export default function PieChartShape() {
  return (
    <div className="grid w-full gap-6 sm:grid-cols-3">
      {(['pie', 'donut', 'semi'] as const).map((shape) => (
        <PlPieChart
          key={shape}
          data={spend}
          categories={teams}
          shape={shape}
          height={160}
          label={`Spend, ${shape}`}
          legend={false}
        />
      ))}
    </div>
  );
}
