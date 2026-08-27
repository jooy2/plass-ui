import { PlSpoiler, PlTypography } from 'plass-ui';

export default function SpoilerHero() {
  return (
    <PlSpoiler className="w-full max-w-md" reversible>
      <PlTypography level="body">
        Rosebud was the name painted on the sled he had as a child, and it is thrown into the
        furnace in the last shot of the film.
      </PlTypography>
    </PlSpoiler>
  );
}
