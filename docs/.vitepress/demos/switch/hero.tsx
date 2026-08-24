import { PlSwitch } from 'plass-ui';

export default function SwitchHero() {
  return (
    <div className="flex flex-col gap-3">
      <PlSwitch label="Dark mode" defaultChecked />
      <PlSwitch label="Send crash reports" description="Nothing personal leaves the device." />
      <PlSwitch label="Beta features" disabled />
    </div>
  );
}
