import { PlTypography } from 'plass-ui';

export default function TypographyRender() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      <PlTypography level="h3">A real h3, in the document outline</PlTypography>

      <PlTypography level="h3" render={<p />}>
        The same scale, semantically a paragraph
      </PlTypography>

      <PlTypography level="body" render={<h2 />}>
        A real h2 set at body size
      </PlTypography>
    </div>
  );
}
