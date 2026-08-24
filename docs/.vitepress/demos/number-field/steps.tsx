import { PlNumberField } from 'plass-ui';

export default function NumberFieldSteps() {
  return (
    <div className="flex w-full max-w-md flex-col gap-4">
      <PlNumberField
        fullWidth
        label="Hold Shift for 10, Alt for 0.1"
        description="Arrow keys and the steppers both take the modifiers."
        defaultValue={0}
        largeStep={10}
        smallStep={0.1}
      />
      <PlNumberField
        fullWidth
        label="Snapped to multiples of 5"
        defaultValue={7}
        step={5}
        snapOnStep
      />
    </div>
  );
}
