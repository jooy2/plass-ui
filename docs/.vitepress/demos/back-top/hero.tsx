import { useRef } from 'react';
import { PlBackTop, PlCard, PlTypography } from 'plass-ui';

export default function BackTopHero() {
  const panel = useRef<HTMLDivElement>(null);

  return (
    <PlCard className="relative w-full max-w-md overflow-hidden p-0">
      <div ref={panel} className="h-64 overflow-y-auto p-4">
        <PlTypography level="body">Scroll down. The button arrives when it is useful.</PlTypography>

        {Array.from({ length: 30 }, (_, index) => (
          <PlTypography key={index} level="body" className="mt-3 block text-(--plass-muted-fg)">
            Line {index + 1}
          </PlTypography>
        ))}
      </div>

      {/* `floating={false}` and a place of its own, because this one belongs to
          the panel rather than to the window. */}
      <PlBackTop
        target={panel}
        visibilityHeight={200}
        floating={false}
        size="sm"
        className="absolute end-4 bottom-4"
      />
    </PlCard>
  );
}
