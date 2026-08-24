import { PlSwitch } from 'plass-ui';

export default function SwitchStates() {
  return (
    <div className="flex flex-col gap-3">
      <PlSwitch label="Off" />
      <PlSwitch label="On" defaultChecked />
      <PlSwitch label="Read-only" defaultChecked readOnly />
      <PlSwitch label="Disabled" disabled />
      <PlSwitch label="Disabled and on" defaultChecked disabled />
    </div>
  );
}
