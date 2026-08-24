import { PlNumberField } from 'plass-ui';

export default function NumberFieldSteppers() {
  return (
    <div className="flex w-full max-w-md flex-col gap-4">
      <PlNumberField fullWidth label="end" defaultValue={2} />
      <PlNumberField fullWidth label="split" steppers="split" defaultValue={2} />
      <PlNumberField fullWidth label="none" steppers="none" defaultValue={2} />
    </div>
  );
}
