import { PlCarousel, PlTypography } from 'plass-ui';

function Slide({ children }: { children: string }) {
  return (
    <div className="flex h-24 items-center justify-center bg-(--plass-primary-soft) text-sm">
      {children}
    </div>
  );
}

export default function CarouselVariants() {
  return (
    <div className="flex w-full max-w-md flex-col gap-4">
      {(['glass', 'solid', 'ghost'] as const).map((variant) => (
        <div key={variant} className="flex flex-col gap-1">
          <PlTypography level="caption">{variant}</PlTypography>
          <PlCarousel variant={variant} label={variant} indicators={false}>
            <Slide>One</Slide>
            <Slide>Two</Slide>
            <Slide>Three</Slide>
          </PlCarousel>
        </div>
      ))}
    </div>
  );
}
