import { PlGallery } from 'plass-ui';
import { photos } from './items';

export default function GalleryHero() {
  return (
    <PlGallery
      items={photos}
      layout="masonry"
      columns={{ xs: 2, md: 3 }}
      caption="hover"
      preview
      className="w-full"
    />
  );
}
