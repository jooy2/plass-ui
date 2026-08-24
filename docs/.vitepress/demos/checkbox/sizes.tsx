import { PlCheckbox } from 'plass-ui';

export default function CheckboxSizes() {
  return (
    <div className="flex flex-col gap-3">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <PlCheckbox key={size} size={size} label={`size="${size}"`} defaultChecked />
      ))}
    </div>
  );
}
