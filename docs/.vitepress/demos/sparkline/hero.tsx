import { PlSparkline } from 'plass-ui';

const signups = [12, 19, 15, 22, 18, 26, 24, 31, 28, 37, 35, 44];

export default function SparklineHero() {
  return (
    <div className="w-full max-w-sm flex flex-col gap-4">
      <div className="flex items-center gap-4">
        <span className="w-24 shrink-0 text-sm text-(--plass-muted-fg)">Signups</span>
        <PlSparkline data={signups} endDot label="Signups over twelve months" />
        <span className="w-12 shrink-0 text-right text-sm font-medium">44</span>
      </div>
      <div className="flex items-center gap-4">
        <span className="w-24 shrink-0 text-sm text-(--plass-muted-fg)">Churn</span>
        <PlSparkline data={[9, 8, 11, 7, 6, 8, 5, 6, 4, 5, 3, 4]} color="danger" endDot />
        <span className="w-12 shrink-0 text-right text-sm font-medium">4</span>
      </div>
    </div>
  );
}
