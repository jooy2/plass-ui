import { PlColorPicker } from 'plass-ui';

export default function ColorPickerStates() {
  return (
    <div className="flex flex-wrap items-end gap-4">
      <PlColorPicker label="Read-only" readOnly defaultValue="#22c55e" />
      <PlColorPicker label="Disabled" disabled defaultValue="#22c55e" />
      <PlColorPicker label="Invalid" error="Pick something darker" defaultValue="#fde68a" />
    </div>
  );
}
