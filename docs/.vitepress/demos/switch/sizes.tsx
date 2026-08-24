import { PlSwitch } from 'plass-ui';

export default function SwitchSizes() {
  return (
    <div className="flex flex-col gap-3">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <PlSwitch key={size} size={size} label={`size="${size}"`} defaultChecked />
      ))}
    </div>
  );
}
