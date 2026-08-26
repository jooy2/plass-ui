import { PlOtpField } from 'plass-ui';

export default function OtpFieldLength() {
  return (
    <div className="flex flex-col gap-4">
      <PlOtpField label="Four digits" length={4} />
      <PlOtpField label="Eight, in two blocks" length={8} groupSize={4} />
    </div>
  );
}
