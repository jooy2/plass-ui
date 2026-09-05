import { PlImage, PlTypography } from 'plass-ui';

export default function ImageStates() {
  return (
    <div className="grid w-full max-w-lg grid-cols-2 gap-4">
      <div className="flex flex-col gap-2">
        <PlImage
          src="/samples/photos/rowboat-misty-pond-sunrise.webp"
          alt="A rowboat moored on a misty pond"
          ratio="1"
          rounded
        />
        <PlTypography level="caption">Arrived</PlTypography>
      </div>

      <div className="flex flex-col gap-2">
        {/* A URL that is not a picture, so this one always fails. */}
        <PlImage src="/does-not-exist.png" alt="The team, at the 2019 offsite" ratio="1" rounded />
        <PlTypography level="caption">Did not — the alt text is drawn instead</PlTypography>
      </div>
    </div>
  );
}
