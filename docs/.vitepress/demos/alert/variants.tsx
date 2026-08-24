import { PlAlert } from 'plass-ui';

export default function AlertVariants() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      {(['solid', 'glass', 'ghost'] as const).map((variant) => (
        <PlAlert key={variant} variant={variant} color="info" title={variant}>
          The same alert, three materials deep.
        </PlAlert>
      ))}
    </div>
  );
}
