import { PlFilePicker } from 'plass-ui';

export default function FilePickerVariants() {
  return (
    <div className="grid w-full gap-4 sm:grid-cols-3">
      {(['solid', 'glass', 'ghost'] as const).map((variant) => (
        <PlFilePicker key={variant} variant={variant} size="sm" title={variant} icon={null} />
      ))}
    </div>
  );
}
