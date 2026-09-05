import { PlImage, PlTypography } from 'plass-ui';

const PHOTO = '/samples/photos/rowboat-misty-pond-sunrise.webp';

const named = ['none', 'grayscale', 'sepia', 'desaturate'] as const;

export default function ImageFilter() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-2 gap-4 sm:grid-cols-4">
      {named.map((filter) => (
        <div key={filter} className="flex flex-col gap-2">
          <PlImage
            src={PHOTO}
            alt="A rowboat moored on a misty pond"
            ratio="1"
            filter={filter}
            rounded
          />
          <PlTypography level="caption">{filter}</PlTypography>
        </div>
      ))}

      <div className="flex flex-col gap-2">
        {/* Anything that is not one of the names is a CSS filter chain. */}
        <PlImage
          src={PHOTO}
          alt="A rowboat moored on a misty pond"
          ratio="1"
          filter="contrast(1.4) hue-rotate(200deg)"
          rounded
        />
        <PlTypography level="caption">A chain of your own</PlTypography>
      </div>
    </div>
  );
}
