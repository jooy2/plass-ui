import { PlBox, PlTypography } from 'plass-ui';

export default function BoxVariants() {
  return (
    <div className="flex w-full max-w-md flex-col gap-3">
      {(['glass', 'solid', 'ghost'] as const).map((variant) => (
        <PlBox key={variant} variant={variant}>
          <PlTypography level="caption">{variant}</PlTypography>
          <PlTypography level="body">The sheet is never dyed, whatever it is made of.</PlTypography>
        </PlBox>
      ))}
    </div>
  );
}
