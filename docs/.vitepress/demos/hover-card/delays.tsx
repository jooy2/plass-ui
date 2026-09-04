import { PlHoverCard, PlTextLink } from 'plass-ui';

export default function HoverCardDelays() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-5">
      <PlHoverCard
        title="Slow to open"
        trigger={<PlTextLink href="#slow">600ms, the default</PlTextLink>}
      >
        Long enough not to fire at every link a pointer passes.
      </PlHoverCard>

      <PlHoverCard
        delay={120}
        title="Quick to open"
        trigger={<PlTextLink href="#quick">120ms</PlTextLink>}
      >
        For a page whose links are all previews, and only there.
      </PlHoverCard>
    </div>
  );
}
