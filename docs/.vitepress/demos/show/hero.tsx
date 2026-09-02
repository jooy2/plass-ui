import { PlChip, PlShow } from 'plass-ui';

export default function ShowHero() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-3">
      <PlShow until="md">
        <PlChip variant="solid" color="warning">
          Narrow — under 48rem
        </PlChip>
      </PlShow>

      <PlShow from="md">
        <PlChip variant="solid" color="success">
          Wide — 48rem and up
        </PlChip>
      </PlShow>

      <PlShow from="sm" until="lg">
        <PlChip variant="glass" color="secondary">
          A band: 40rem to 64rem
        </PlChip>
      </PlShow>
    </div>
  );
}
