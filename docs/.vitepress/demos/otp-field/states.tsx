import { PlOtpField } from 'plass-ui';

export default function OtpFieldStates() {
  return (
    <div className="flex flex-col gap-4">
      <PlOtpField label="Masked" length={4} mask defaultValue="1234" />
      <PlOtpField label="Read only" length={4} readOnly defaultValue="1234" />
      <PlOtpField label="Disabled" length={4} disabled defaultValue="12" />
      <PlOtpField
        label="Wrong code"
        length={4}
        defaultValue="1234"
        error="That code has expired."
      />
    </div>
  );
}
