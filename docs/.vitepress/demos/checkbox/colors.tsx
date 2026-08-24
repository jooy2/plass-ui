import { PlCheckbox } from 'plass-ui';

export default function CheckboxColors() {
  return (
    <div className="flex flex-wrap gap-5">
      {(['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const).map((color) => (
        <PlCheckbox key={color} color={color} label={color} defaultChecked />
      ))}
    </div>
  );
}
