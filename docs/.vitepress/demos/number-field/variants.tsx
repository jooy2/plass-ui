import { PlNumberField } from 'plass-ui';

export default function NumberFieldVariants() {
  return (
    <div className="flex w-full max-w-md flex-col gap-4">
      {(['solid', 'glass', 'ghost'] as const).map((variant) => (
        <PlNumberField key={variant} fullWidth variant={variant} label={variant} defaultValue={8} />
      ))}
    </div>
  );
}
