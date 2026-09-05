import { PlMockup } from 'plass-ui';

export default function MockupFinish() {
  return (
    <div className="flex w-full flex-wrap items-end justify-center gap-6">
      {(['graphite', 'silver', 'white'] as const).map((finish) => (
        <PlMockup key={finish} device="mobile" finish={finish} width={110} elevation={2} />
      ))}
    </div>
  );
}
