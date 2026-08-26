import { PlOtpField } from 'plass-ui';

export default function OtpFieldVariants() {
  return (
    <div className="flex flex-col gap-4">
      {(['glass', 'solid', 'ghost'] as const).map((variant) => (
        <PlOtpField key={variant} variant={variant} label={variant} length={4} defaultValue="12" />
      ))}
    </div>
  );
}
