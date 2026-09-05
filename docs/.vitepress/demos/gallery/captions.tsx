import { PlGallery, PlTypography } from 'plass-ui';
import { photos } from './items';

export default function GalleryCaptions() {
  return (
    <div className="flex w-full flex-col gap-6">
      {(['below', 'overlay', 'hover'] as const).map((caption) => (
        <div key={caption} className="flex flex-col gap-2">
          <PlTypography level="overline">{caption}</PlTypography>
          <PlGallery items={photos.slice(0, 3)} columns={3} caption={caption} hover="zoom" />
        </div>
      ))}
    </div>
  );
}
