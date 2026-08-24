import { PlFilePicker } from 'plass-ui';

export default function FilePickerStates() {
  return (
    <div className="grid w-full gap-4 sm:grid-cols-2">
      <PlFilePicker size="sm" label="Disabled" disabled />
      <PlFilePicker size="sm" label="Invalid" error="A signed contract is required." />
    </div>
  );
}
