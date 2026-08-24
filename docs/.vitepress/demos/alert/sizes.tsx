import { PlAlert } from 'plass-ui';

export default function AlertSizes() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      {(['sm', 'md', 'lg'] as const).map((size) => (
        <PlAlert key={size} size={size} color="info" title={`size="${size}"`}>
          The glyph, the title and the message move together.
        </PlAlert>
      ))}
    </div>
  );
}
