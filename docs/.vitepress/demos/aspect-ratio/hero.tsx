import { PlAspectRatio } from 'plass-ui';

export default function AspectRatioHero() {
  return (
    <div className="w-full max-w-sm">
      <PlAspectRatio ratio="16 / 9" rounded size="lg">
        <img
          src="/samples/photos/lakeside-observatory-blue-hour.webp"
          alt="An observatory beside a lake at blue hour"
        />
      </PlAspectRatio>
    </div>
  );
}
