import { PlFilePicker } from 'plass-ui';

export default function FilePickerSizes() {
  return (
    <div className="flex w-full max-w-md flex-col gap-4">
      {(['sm', 'md', 'lg'] as const).map((size) => (
        <PlFilePicker key={size} size={size} title={`size="${size}"`} />
      ))}
    </div>
  );
}
