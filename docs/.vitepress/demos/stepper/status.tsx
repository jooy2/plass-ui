import { PlStep, PlStepper } from 'plass-ui';

export default function StepperStatus() {
  return (
    <div className="w-full max-w-2xl">
      {/* The reader has moved on, and the second step failed validation behind
          them. `status` and `color` say so without moving `active`. */}
      <PlStepper active={2} linear={false}>
        <PlStep label="Account" />
        <PlStep label="Verify" description="Code expired" status="current" color="danger" />
        <PlStep label="Profile" />
      </PlStepper>
    </div>
  );
}
