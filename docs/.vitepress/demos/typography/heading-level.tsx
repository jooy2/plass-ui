import { PlTypography } from 'plass-ui';

export default function TypographyHeadingLevel() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      <PlTypography level="h3">A real h3, in the document outline</PlTypography>

      <PlTypography level="h3" headingLevel={2}>
        The same scale, one level up the outline
      </PlTypography>

      <PlTypography level="body" headingLevel={2}>
        A real h2 set at body size
      </PlTypography>
    </div>
  );
}
