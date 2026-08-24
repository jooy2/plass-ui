import { Button } from 'plass-ui';

export default function ButtonDensity() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <Button size="lg">Default</Button>
      <Button size="lg" density="compact">
        Compact
      </Button>
      <Button size="lg" variant="glass">
        Default
      </Button>
      <Button size="lg" variant="glass" density="compact">
        Compact
      </Button>
    </div>
  );
}
