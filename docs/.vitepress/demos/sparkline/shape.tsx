import { PlSparkline } from 'plass-ui';

const readings = [12, 19, 15, 22, 18, 26, 24, 31];

export default function SparklineShape() {
  return (
    <div className="w-full max-w-xs flex flex-col gap-6">
      {(['line', 'area', 'bar'] as const).map((shape) => (
        <div key={shape} className="flex items-center gap-4">
          <span className="w-12 shrink-0 text-sm text-(--plass-muted-fg)">{shape}</span>
          <PlSparkline data={readings} shape={shape} />
        </div>
      ))}
    </div>
  );
}
