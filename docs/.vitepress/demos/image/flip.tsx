import { PlImage, PlTypography } from 'plass-ui';

const flips = ['none', 'horizontal', 'vertical', 'both'] as const;

export default function ImageFlip() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-2 gap-4 sm:grid-cols-4">
      {flips.map((flip) => (
        <div key={flip} className="flex flex-col gap-2">
          <PlImage
            src="/samples/photos/rowboat-misty-pond-sunrise.webp"
            alt="A rowboat moored on a misty pond"
            ratio="3 / 2"
            flip={flip}
            rounded
          />
          <PlTypography level="caption">{flip}</PlTypography>
        </div>
      ))}
    </div>
  );
}
