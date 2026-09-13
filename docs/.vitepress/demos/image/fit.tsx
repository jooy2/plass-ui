import { PlImage, PlTypography } from 'plass-ui';

const fits = ['cover', 'contain', 'fill', 'none', 'scale-down'] as const;

export default function ImageFit() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-2 gap-4 sm:grid-cols-5">
      {fits.map((fit) => (
        <div key={fit} className="flex flex-col gap-2">
          {/* A lone height fixes the box, and the column decides its width. */}
          <PlImage
            src="/samples/photos/alpine-lake-dawn.webp"
            alt="A still mountain lake at first light"
            height={160}
            fit={fit}
            rounded
          />
          <PlTypography level="caption">{fit}</PlTypography>
        </div>
      ))}
    </div>
  );
}
