import { PlButton } from 'plass-ui';

export default function ButtonDensity() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <PlButton size="lg">Default</PlButton>
      <PlButton size="lg" density="compact">
        Compact
      </PlButton>
      <PlButton size="lg" variant="glass">
        Default
      </PlButton>
      <PlButton size="lg" variant="glass" density="compact">
        Compact
      </PlButton>
    </div>
  );
}
