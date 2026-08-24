import { PlNumberField } from 'plass-ui';

export default function NumberFieldStates() {
  return (
    <div className="flex w-full max-w-md flex-col gap-4">
      <PlNumberField fullWidth label="Read-only" readOnly value={12} />
      <PlNumberField fullWidth label="Disabled" disabled defaultValue={12} />
      <PlNumberField fullWidth label="With an error" defaultValue={99} error="Twelve at most." />
      <PlNumberField
        fullWidth
        label="With a unit"
        defaultValue={3}
        endIcon={<span className="text-xs">kg</span>}
      />
    </div>
  );
}
