import { PlRadio, PlRadioGroup } from 'plass-ui';

export default function RadioGroupColors() {
  return (
    <div className="flex flex-wrap gap-8">
      {(['primary', 'success', 'warning', 'danger'] as const).map((color) => (
        <PlRadioGroup key={color} color={color} label={color} defaultValue="on">
          <PlRadio value="on" label="Chosen" />
          <PlRadio value="off" label="Not chosen" />
        </PlRadioGroup>
      ))}
    </div>
  );
}
