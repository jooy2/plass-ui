import { PlIconButton, PlPill } from 'plass-ui';

function DotGlyph() {
  return <span className="block size-2 rounded-full bg-current" />;
}

function StopGlyph() {
  return (
    <svg viewBox="0 0 24 24" fill="currentColor" className="size-3.5">
      <rect x="7" y="7" width="10" height="10" rx="2" />
    </svg>
  );
}

export default function PillHero() {
  return (
    <PlPill
      color="danger"
      title="Recording"
      description="00:41"
      startIcon={<DotGlyph />}
      endIcon={<PlIconButton size="xs" variant="ghost" label="Stop" icon={<StopGlyph />} />}
    />
  );
}
