import { PlSparkline } from 'plass-ui';

const rows = [
  { name: 'Europe', data: [82, 88, 91, 87, 94, 99] },
  { name: 'Asia', data: [11, 14, 12, 17, 15, 21] }
];

export default function SparklineScale() {
  return (
    <div className="grid w-full max-w-lg gap-8 sm:grid-cols-2">
      {[undefined, 0].map((min, at) => (
        <div key={at} className="flex flex-col gap-2">
          <span className="text-xs text-(--plass-muted-fg)">
            {min === undefined ? 'Each to its own range' : 'Both from 0 to 100'}
          </span>
          {rows.map((row) => (
            <div key={row.name} className="flex items-center gap-3">
              <span className="w-14 shrink-0 text-sm text-(--plass-muted-fg)">{row.name}</span>
              <PlSparkline data={row.data} min={min} max={min === undefined ? undefined : 100} />
            </div>
          ))}
        </div>
      ))}
    </div>
  );
}
