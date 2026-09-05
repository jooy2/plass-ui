import { PlSpoiler } from 'plass-ui';

export default function SpoilerMedia() {
  return (
    <PlSpoiler
      className="w-full max-w-sm"
      padded={false}
      reversible
      description="Sensitive image"
      label="Show anyway"
    >
      <img
        src="/samples/photos/desert-rocks-milky-way.webp"
        alt="The Milky Way over a desert rock formation"
        className="h-40 w-full object-cover"
      />
    </PlSpoiler>
  );
}
