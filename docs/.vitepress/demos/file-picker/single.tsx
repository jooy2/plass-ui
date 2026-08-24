import { PlFilePicker } from 'plass-ui';

export default function FilePickerSingle() {
  return (
    <PlFilePicker
      className="max-w-md"
      label="Avatar"
      accept="image/png,image/jpeg"
      title="Choose a picture"
      hint="Square works best"
      description="Replacing it removes the one before."
    />
  );
}
