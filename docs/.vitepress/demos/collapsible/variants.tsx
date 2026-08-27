import { PlCollapsible, PlTypography } from 'plass-ui';

export default function CollapsibleVariants() {
  return (
    <div className="flex w-full max-w-md flex-col gap-3">
      {(['glass', 'solid', 'ghost'] as const).map((variant) => (
        <div key={variant} className="flex flex-col gap-1">
          <PlTypography level="caption">{variant}</PlTypography>
          <PlCollapsible variant={variant} title="What is inside" defaultOpen={variant === 'glass'}>
            The sheet is never dyed: a fold holds other people&apos;s content.
          </PlCollapsible>
        </div>
      ))}
    </div>
  );
}
