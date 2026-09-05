import { PlButton, PlMockup } from 'plass-ui';

export default function MockupHero() {
  return (
    <PlMockup device="mobile" width={260} elevation={2}>
      <div className="flex h-full flex-col gap-4 p-6">
        <h2 className="text-2xl font-semibold text-(--plass-fg)">Today</h2>
        <p className="text-sm text-(--plass-muted-fg)">
          Three things left. The screen is a real viewport at 390 by 844, so this column wraps where
          it would wrap on a phone.
        </p>
        <PlButton className="mt-auto w-full">Start</PlButton>
      </div>
    </PlMockup>
  );
}
