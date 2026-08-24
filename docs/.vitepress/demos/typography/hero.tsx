import { PlTypography } from 'plass-ui';

export default function TypographyHero() {
  return (
    <div className="flex w-full max-w-lg flex-col">
      <PlTypography level="overline" gutter>
        Release notes
      </PlTypography>
      <PlTypography level="h2" gutter>
        A material rather than a theme
      </PlTypography>
      <PlTypography level="lead" gutter>
        Every surface answers one question — is this pressed, or does it hold something?
      </PlTypography>
      <PlTypography gutter>
        The answer decides the fill, the shadow, the radius and the way it moves under a pointer.
      </PlTypography>
      <PlTypography level="caption">Written down so nobody has to guess twice.</PlTypography>
    </div>
  );
}
