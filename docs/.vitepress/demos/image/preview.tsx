import { PlImage } from 'plass-ui';

export default function ImagePreview() {
  return (
    <div className="w-full max-w-xs">
      <PlImage
        src="/samples/photos/hand-dyed-wool-yarn.webp"
        alt="Skeins of hand-dyed wool in a basket"
        ratio="1"
        rounded
        size="lg"
        preview
      />
    </div>
  );
}
