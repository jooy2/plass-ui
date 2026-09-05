import { useState } from 'react';
import { PlGallery, PlSegment, PlSegmentedButton, type PlGalleryLayout } from 'plass-ui';
import { photos } from './items';

export default function GalleryLayouts() {
  const [layout, setLayout] = useState<PlGalleryLayout>('justified');

  return (
    <div className="flex w-full flex-col gap-4">
      <PlSegmentedButton
        value={layout}
        onValueChange={(next) => setLayout(next as PlGalleryLayout)}
      >
        <PlSegment value="grid">grid</PlSegment>
        <PlSegment value="masonry">masonry</PlSegment>
        <PlSegment value="justified">justified</PlSegment>
        <PlSegment value="quilted">quilted</PlSegment>
      </PlSegmentedButton>

      <PlGallery
        items={photos}
        layout={layout}
        columns={{ xs: 2, md: 3 }}
        rowHeight={140}
        className="w-full"
      />
    </div>
  );
}
