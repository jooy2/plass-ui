import { PlCard, PlFloatingActionButton } from 'plass-ui';

function Plus() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path d="M8 3.5v9M3.5 8h9" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" />
    </svg>
  );
}

export default function FloatingActionButtonHero() {
  return (
    <PlCard className="relative h-56 w-full max-w-md">
      <p className="text-sm text-(--plass-muted-fg)">
        The one action this screen is about, in the corner it is always in. Everything else on the
        screen goes on working.
      </p>

      {/* `floating` pins to the window; inside a preview it is pinned to the
          card instead, which is what `absolute` on the caller's side does. */}
      <PlFloatingActionButton
        floating={false}
        className="absolute end-6 bottom-6"
        icon={<Plus />}
        label="New project"
      />
    </PlCard>
  );
}
