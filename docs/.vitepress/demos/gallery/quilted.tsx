import { PlGallery } from 'plass-ui';
import { photos } from './items';

export default function GalleryQuilted() {
  return (
    <PlGallery
      items={[
        { ...photos[4], cols: 2, rows: 2 },
        photos[1],
        photos[2],
        { ...photos[3], cols: 2 },
        photos[5]
      ]}
      layout="quilted"
      columns={{ xs: 2, md: 4 }}
      rowHeight={110}
      caption="none"
      className="w-full"
    />
  );
}
