import { PlRadio, PlRadioGroup } from 'plass-ui';

export default function RadioGroupSizes() {
  return (
    <div className="flex flex-wrap gap-8">
      {(['sm', 'md', 'lg'] as const).map((size) => (
        <PlRadioGroup key={size} size={size} label={`size="${size}"`} defaultValue="a">
          <PlRadio value="a" label="First" />
          <PlRadio value="b" label="Second" />
        </PlRadioGroup>
      ))}
    </div>
  );
}
