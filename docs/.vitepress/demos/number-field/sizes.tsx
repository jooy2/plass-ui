import { PlNumberField } from 'plass-ui';

export default function NumberFieldSizes() {
  return (
    <div className="flex w-full max-w-md flex-col gap-4">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <PlNumberField key={size} fullWidth size={size} label={size} defaultValue={12} />
      ))}
    </div>
  );
}
