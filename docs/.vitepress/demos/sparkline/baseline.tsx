import { PlSparkline } from 'plass-ui';

const latency = [180, 210, 240, 195, 320, 280, 260, 340, 300, 250];

export default function SparklineBaseline() {
  return (
    <div className="flex w-full max-w-sm items-center gap-4">
      <span className="w-16 shrink-0 text-sm text-(--plass-muted-fg)">p95 ms</span>
      <PlSparkline data={latency} shape="area" baseline={250} endDot label="p95 latency" />
    </div>
  );
}
