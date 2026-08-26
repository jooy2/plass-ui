import { PlAspectRatio } from 'plass-ui';

export default function AspectRatioHero() {
  return (
    <div className="w-full max-w-sm">
      <PlAspectRatio ratio="16 / 9" rounded size="lg">
        <img src="/portrait-2.svg" alt="A portrait" />
      </PlAspectRatio>
    </div>
  );
}
