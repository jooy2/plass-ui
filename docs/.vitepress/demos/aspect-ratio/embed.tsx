import { PlAspectRatio } from 'plass-ui';

export default function AspectRatioEmbed() {
  return (
    <div className="w-full max-w-md">
      <PlAspectRatio ratio="16 / 9" rounded size="lg" render={<figure className="m-0" />}>
        <div className="flex size-full items-center justify-center bg-(--plass-glass-press) text-sm">
          A player, a map, an iframe — anything that has to keep 16 / 9
        </div>
      </PlAspectRatio>
    </div>
  );
}
