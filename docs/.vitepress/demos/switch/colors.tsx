import { PlSwitch } from 'plass-ui';

export default function SwitchColors() {
  return (
    <div className="flex flex-wrap gap-5">
      {(['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const).map((color) => (
        <PlSwitch key={color} color={color} label={color} defaultChecked />
      ))}
    </div>
  );
}
