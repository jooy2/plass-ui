import { PlAspectRatio, PlTypography } from 'plass-ui';

const FITS = ['cover', 'contain', 'fill', 'none'] as const;

export default function AspectRatioFit() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-2 gap-4 sm:grid-cols-4">
      {FITS.map((fit) => (
        <div key={fit} className="flex flex-col gap-2">
          <PlAspectRatio ratio="4 / 3" fit={fit} rounded>
            <img
              src="/samples/photos/lighthouse-cliff-wildflowers.webp"
              alt=""
              className="bg-(--plass-glass)"
            />
          </PlAspectRatio>
          <PlTypography level="caption">{fit}</PlTypography>
        </div>
      ))}
    </div>
  );
}
