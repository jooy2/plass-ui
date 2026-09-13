import { PlImage, PlTypography } from 'plass-ui';

const positions = ['top', 'center', 'bottom'] as const;

export default function ImagePosition() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-3 gap-4">
      {positions.map((position) => (
        <div key={position} className="flex flex-col gap-2">
          {/* A tall photograph in a wide box, so the crop has to choose. */}
          <PlImage
            src="/samples/photos/lighthouse-cliff-wildflowers.webp"
            alt="A lighthouse on a clifftop above wildflowers"
            ratio="4 / 3"
            position={position}
            rounded
          />
          <PlTypography level="caption">{position}</PlTypography>
        </div>
      ))}
    </div>
  );
}
