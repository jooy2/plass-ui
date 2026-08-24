import { PlCard } from 'plass-ui';

export default function CardPadded() {
  return (
    <PlCard padded={false} className="w-full max-w-sm overflow-hidden">
      <div
        className="h-28 w-full"
        style={{ backgroundImage: 'var(--plass-primary-fill)' }}
        aria-hidden="true"
      />
      <div className="p-5">
        <p className="font-semibold text-(--plass-fg)">Full bleed</p>
        <p className="mt-1 text-(--plass-muted-fg)">
          With `padded` off the sheet keeps no inset, so the banner reaches all four edges and the
          text brings its own.
        </p>
      </div>
    </PlCard>
  );
}
