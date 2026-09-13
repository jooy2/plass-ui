import { PlImage, PlTypography } from 'plass-ui';

const letterboxes = [
  { letterbox: 'none', caption: 'none' },
  { letterbox: 'var(--plass-primary-soft)', caption: 'A colour' },
  { letterbox: 'blur', caption: 'blur' }
];

export default function ImageLetterbox() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-1 gap-4 sm:grid-cols-3">
      {letterboxes.map(({ letterbox, caption }) => (
        <div key={letterbox} className="flex flex-col gap-2">
          {/* A tall photograph in a wide box, fitted whole. */}
          <PlImage
            src="/samples/photos/greenhouse-fern-shadows.webp"
            alt="Ferns throwing shadows across a greenhouse wall"
            ratio="3 / 2"
            fit="contain"
            letterbox={letterbox}
            rounded
          />
          <PlTypography level="caption">{caption}</PlTypography>
        </div>
      ))}
    </div>
  );
}
