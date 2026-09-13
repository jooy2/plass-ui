import { PlGallery } from 'plass-ui';
import { photos } from './items';

// The second picture is turned onto its side, and still fitted to a square tile.
const items = photos.map((photo, index) =>
  index === 1 ? { ...photo, rotate: 90 as const } : photo
);

export default function GalleryFit() {
  return (
    <PlGallery
      items={items}
      columns={{ xs: 2, sm: 3 }}
      fit="contain"
      letterbox="blur"
      className="w-full"
    />
  );
}
