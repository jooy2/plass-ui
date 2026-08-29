import { PlAnimateBlink, PlChip, PlTypography } from 'plass-ui';

export default function AnimateBlinkHero() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-8">
      <div className="flex items-center gap-2">
        <PlAnimateBlink duration={1400} min={0.15}>
          <span className="block size-2.5 rounded-full bg-(--plass-danger-accent)" />
        </PlAnimateBlink>
        <PlTypography level="body">Recording</PlTypography>
      </div>

      <PlAnimateBlink duration={1600} min={0.45}>
        <PlChip color="warning">Awaiting approval</PlChip>
      </PlAnimateBlink>
    </div>
  );
}
