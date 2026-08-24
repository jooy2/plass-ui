import { PlCard } from 'plass-ui';

export default function CardVariants() {
  return (
    <div className="grid w-full gap-4 sm:grid-cols-3">
      {(['solid', 'glass', 'ghost'] as const).map((variant) => (
        <PlCard key={variant} variant={variant} size="sm" title={variant}>
          The sheet is {variant}.
        </PlCard>
      ))}
    </div>
  );
}
