import { PlCheckbox } from 'plass-ui';

export default function CheckboxStates() {
  return (
    <div className="flex flex-col gap-3">
      <PlCheckbox label="Default" />
      <PlCheckbox label="Checked" defaultChecked />
      <PlCheckbox label="Read-only" defaultChecked readOnly />
      <PlCheckbox label="Disabled" disabled />
      <PlCheckbox label="Disabled and checked" defaultChecked disabled />
      <PlCheckbox label="Accept the terms" error="You have to accept them to continue." />
    </div>
  );
}
