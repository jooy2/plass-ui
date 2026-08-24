import { PlTypography } from 'plass-ui';

export default function TypographyWeight() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-2">
      {(['regular', 'medium', 'semibold', 'bold'] as const).map((weight) => (
        <PlTypography key={weight} weight={weight}>
          {weight}
        </PlTypography>
      ))}
    </div>
  );
}
