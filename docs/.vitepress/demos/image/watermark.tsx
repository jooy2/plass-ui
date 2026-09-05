import { PlImage, PlTypography } from 'plass-ui';

const PHOTO = '/samples/photos/rowboat-misty-pond-sunrise.webp';

export default function ImageWatermark() {
  return (
    <div className="grid w-full max-w-lg grid-cols-2 gap-4">
      <div className="flex flex-col gap-2">
        <PlImage
          src={PHOTO}
          alt="A rowboat moored on a misty pond"
          ratio="1"
          rounded
          watermark="© Ada & Co"
        />
        <PlTypography level="caption">A bare string sits in the corner</PlTypography>
      </div>

      <div className="flex flex-col gap-2">
        <PlImage
          src={PHOTO}
          alt="A rowboat moored on a misty pond"
          ratio="1"
          rounded
          watermark={{ text: 'PROOF — NOT FOR PRINT', placement: 'tile' }}
        />
        <PlTypography level="caption">tile covers the whole picture</PlTypography>
      </div>
    </div>
  );
}
