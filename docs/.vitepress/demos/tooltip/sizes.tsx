import { PlButton, PlTooltip } from 'plass-ui';

export default function TooltipSizes() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <PlTooltip key={size} size={size} content={size} defaultOpen>
          <PlButton size={size} variant="glass" color="secondary">
            {size}
          </PlButton>
        </PlTooltip>
      ))}
    </div>
  );
}
