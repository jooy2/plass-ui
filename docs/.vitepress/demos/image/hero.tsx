import { PlImage } from 'plass-ui';

export default function ImageHero() {
  return (
    <div className="grid w-full max-w-lg grid-cols-2 gap-4">
      <PlImage
        src="/samples/photos/alpine-lake-dawn.webp"
        alt="A still mountain lake at first light"
        ratio="4 / 3"
        rounded
        size="lg"
      />
      <PlImage
        src="/samples/photos/forest-trail-sunbeams.webp"
        alt="Sunbeams across a forest trail"
        ratio="4 / 3"
        rounded
        size="lg"
      />
    </div>
  );
}
