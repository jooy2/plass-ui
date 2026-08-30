import { PlColorPicker, type PlColorFormat } from 'plass-ui';

export default function ColorPickerFormats() {
  return (
    <div className="flex flex-wrap items-end gap-4">
      {(['hex', 'rgb', 'hsl'] as PlColorFormat[]).map((format) => (
        <PlColorPicker key={format} label={format} format={format} defaultValue="#22c55e" />
      ))}
    </div>
  );
}
