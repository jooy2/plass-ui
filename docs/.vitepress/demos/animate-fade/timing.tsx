import { PlAnimateFade, PlChip } from 'plass-ui';

export default function AnimateFadeTiming() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-2">
      {[0, 200, 400, 600].map((delay) => (
        <PlAnimateFade key={delay} delay={delay} duration={500}>
          <PlChip>{delay}ms</PlChip>
        </PlAnimateFade>
      ))}
    </div>
  );
}
