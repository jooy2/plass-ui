import { PlHighlight } from 'plass-ui';

export default function HighlightVariants() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-3 text-sm/7 text-(--plass-fg)">
      {(['solid', 'glass', 'ghost'] as const).map((variant) => (
        <p key={variant}>
          <PlHighlight variant={variant} query="tinted glass">
            A key of tinted glass resting on a clear sheet.
          </PlHighlight>
        </p>
      ))}
    </div>
  );
}
