import { useState } from 'react';
import { PlButton, PlImage } from 'plass-ui';

const PHOTO = '/samples/photos/misty-tea-terraces-sunrise.webp';

export default function ImagePlaceholder() {
  // No `src` until the button is pressed, so the stand-in stays up for as long
  // as you want to look at it.
  const [src, setSrc] = useState<string>();

  return (
    <div className="flex w-full max-w-md flex-col gap-3">
      <PlImage
        src={src}
        alt="Terraced tea fields under morning mist"
        ratio="3 / 2"
        placeholder={{ src: '/samples/photos/misty-tea-terraces-sunrise-tiny.webp', blur: true }}
        rounded
      />
      <div>
        <PlButton variant="glass" onClick={() => setSrc(src === undefined ? PHOTO : undefined)}>
          {src === undefined ? 'Load the picture' : 'Show the stand-in again'}
        </PlButton>
      </div>
    </div>
  );
}
