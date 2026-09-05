import { PlImage, PlTypography } from 'plass-ui';

const PHOTO = '/samples/photos/rowboat-misty-pond-sunrise.webp';

export default function ImageProtect() {
  return (
    <div className="grid w-full max-w-lg grid-cols-2 gap-4">
      <div className="flex flex-col gap-2">
        <PlImage src={PHOTO} alt="A rowboat moored on a misty pond" ratio="1" rounded />
        <PlTypography level="caption">Right-click offers Save</PlTypography>
      </div>

      <div className="flex flex-col gap-2">
        <PlImage src={PHOTO} alt="A rowboat moored on a misty pond" ratio="1" rounded protect />
        <PlTypography level="caption">protect — no menu, no drag, no selection</PlTypography>
      </div>
    </div>
  );
}
