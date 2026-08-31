import { PlImage } from 'plass-ui';

export default function ImageHero() {
  return (
    <div className="grid w-full max-w-lg grid-cols-2 gap-4">
      <PlImage src="/portrait-1.svg" alt="A portrait" ratio="4 / 3" rounded size="lg" />
      <PlImage src="/portrait-2.svg" alt="Another portrait" ratio="4 / 3" rounded size="lg" />
    </div>
  );
}
