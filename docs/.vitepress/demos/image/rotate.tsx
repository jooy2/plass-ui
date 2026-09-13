import { PlImage, PlTypography } from 'plass-ui';

const turns = [0, 90, 180, 270] as const;

export default function ImageRotate() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-2 items-start gap-4 sm:grid-cols-4">
      {turns.map((rotate) => (
        <div key={rotate} className="flex flex-col gap-2">
          {/* The file's own size reserves the turned box before it arrives. */}
          <PlImage
            src="/samples/photos/bicycle-coastal-path.webp"
            alt="A bicycle parked on a path above the sea"
            width={800}
            height={533}
            rotate={rotate}
            rounded
          />
          <PlTypography level="caption">{rotate}</PlTypography>
        </div>
      ))}
    </div>
  );
}
