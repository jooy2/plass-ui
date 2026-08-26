import { PlOtpField } from 'plass-ui';

export default function OtpFieldSizes() {
  return (
    <div className="flex flex-col gap-4">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <PlOtpField key={size} size={size} label={size} length={4} defaultValue="12" />
      ))}
    </div>
  );
}
