import { PlOtpField } from 'plass-ui';

export default function OtpFieldCharset() {
  return (
    <div className="flex flex-col gap-4">
      <PlOtpField label="numeric" length={4} charset="numeric" />
      <PlOtpField label="alphanumeric" length={4} charset="alphanumeric" />
      <PlOtpField label="any" length={4} charset="any" separator="·" groupSize={2} />
    </div>
  );
}
