import { PlButton, PlTooltip } from 'plass-ui';

export default function TooltipAlign() {
  return (
    <div className="flex flex-wrap items-center gap-4">
      {(['start', 'center', 'end'] as const).map((align) => (
        <PlTooltip key={align} align={align} content={align} defaultOpen>
          <PlButton size="sm" variant="glass" color="secondary">
            A wide enough trigger
          </PlButton>
        </PlTooltip>
      ))}
    </div>
  );
}
