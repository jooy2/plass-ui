import { PlImage } from 'plass-ui';

export default function ImagePreview() {
  return (
    <div className="w-full max-w-xs">
      <PlImage src="/portrait-2.svg" alt="A portrait" ratio="1" rounded size="lg" preview />
    </div>
  );
}
