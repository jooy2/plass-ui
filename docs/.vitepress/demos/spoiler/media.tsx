import { PlSpoiler } from 'plass-ui';

export default function SpoilerMedia() {
  return (
    <PlSpoiler
      className="w-full max-w-sm"
      padded={false}
      reversible
      description="Sensitive image"
      label="Show anyway"
    >
      <div className="grid h-40 place-items-center bg-linear-135 from-(--plass-danger-soft) to-(--plass-warning-soft) text-sm">
        A photograph somebody has not asked to see
      </div>
    </PlSpoiler>
  );
}
