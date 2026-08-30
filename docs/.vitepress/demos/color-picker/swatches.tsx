import { PlColorPicker } from 'plass-ui';

const brand = ['#0f172a', '#1a58d1', '#0ea5e9', '#10b981', '#f59e0b', '#ef4444'];

export default function ColorPickerSwatches() {
  return (
    <div className="flex flex-wrap items-end gap-6">
      <PlColorPicker inline label="Brand only" swatches={brand} defaultValue="#1a58d1" size="sm" />
      <PlColorPicker inline label="No swatches" swatches={false} defaultValue="#1a58d1" size="sm" />
    </div>
  );
}
