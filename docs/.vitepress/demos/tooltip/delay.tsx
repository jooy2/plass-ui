import { PlButton, PlTooltip } from 'plass-ui';

export default function TooltipDelay() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <PlTooltip content="The house delay: 600ms">
        <PlButton size="sm" variant="glass" color="secondary">
          Default
        </PlButton>
      </PlTooltip>

      <PlTooltip delay={0} content="Opens the moment you arrive">
        <PlButton size="sm" variant="glass" color="secondary">
          No delay
        </PlButton>
      </PlTooltip>

      <PlTooltip closeDelay={400} content="Waits before it goes">
        <PlButton size="sm" variant="glass" color="secondary">
          Slow to close
        </PlButton>
      </PlTooltip>

      <PlTooltip disabled content="Never shown">
        <PlButton size="sm" variant="glass" color="secondary">
          Disabled
        </PlButton>
      </PlTooltip>
    </div>
  );
}
