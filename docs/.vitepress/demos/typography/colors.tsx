import { PlTypography } from 'plass-ui';

export default function TypographyColors() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-2">
      <PlTypography>No colour asked for — the page’s own ink.</PlTypography>
      {(['primary', 'success', 'warning', 'danger', 'info'] as const).map((color) => (
        <PlTypography key={color} color={color}>
          {color}
        </PlTypography>
      ))}
    </div>
  );
}
