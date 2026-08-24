import { PlButton, PlTooltip } from 'plass-ui';

export default function TooltipSides() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      {(['top', 'right', 'bottom', 'left'] as const).map((side) => (
        <PlTooltip key={side} side={side} content={`On the ${side}`} defaultOpen>
          <PlButton size="sm" variant="glass" color="secondary">
            {side}
          </PlButton>
        </PlTooltip>
      ))}
    </div>
  );
}
