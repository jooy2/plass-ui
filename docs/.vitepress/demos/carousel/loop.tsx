import { PlCarousel, PlTypography } from 'plass-ui';

function Slide({ children }: { children: string }) {
  return (
    <div className="flex h-28 items-center justify-center bg-(--plass-secondary-soft) text-sm">
      {children}
    </div>
  );
}

export default function CarouselLoop() {
  return (
    <div className="flex w-full max-w-md flex-col gap-4">
      <div className="flex flex-col gap-1">
        <PlTypography level="caption">loop — the default</PlTypography>
        <PlCarousel label="Looping">
          <Slide>One</Slide>
          <Slide>Two</Slide>
          <Slide>Three</Slide>
        </PlCarousel>
      </div>

      <div className="flex flex-col gap-1">
        <PlTypography level="caption">loop={'{false}'} — inert at the ends</PlTypography>
        <PlCarousel label="Bounded" loop={false}>
          <Slide>One</Slide>
          <Slide>Two</Slide>
          <Slide>Three</Slide>
        </PlCarousel>
      </div>
    </div>
  );
}
