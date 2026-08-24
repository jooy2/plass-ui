import { PlTypography } from 'plass-ui';

const text =
  'A thing that is pressed is tinted glass: a gradient that sweeps between two ends of its colour family, a drop shadow tinted with that family, and a bloom of light that follows the pointer across it.';

export default function TypographyLines() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-4">
      <PlTypography lines={1}>{text}</PlTypography>
      <PlTypography lines={2}>{text}</PlTypography>
      <PlTypography>{text}</PlTypography>
    </div>
  );
}
