import { PlToggle, type PlassVariant } from 'plass-ui';

export default function ToggleVariants() {
  return (
    <div className="flex flex-col gap-4">
      {(['solid', 'glass', 'ghost'] as PlassVariant[]).map((variant) => (
        <div key={variant} className="flex items-center gap-3">
          <PlToggle variant={variant}>{variant} off</PlToggle>
          <PlToggle variant={variant} defaultPressed>
            {variant} on
          </PlToggle>
        </div>
      ))}
    </div>
  );
}
