import { PlColorPicker } from 'plass-ui';

export default function ColorPickerInline() {
  return (
    <PlColorPicker
      inline
      label="Label colour"
      description="Chosen by eye, written as hex."
      defaultValue="#8b5cf6"
    />
  );
}
