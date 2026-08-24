import { PlButton, PlTooltip, PlTooltipProvider } from 'plass-ui';

const actions = ['Bold', 'Italic', 'Underline', 'Strikethrough'];

export default function TooltipProviderDemo() {
  return (
    <PlTooltipProvider>
      <div className="flex flex-wrap items-center gap-1">
        {actions.map((action) => (
          <PlTooltip key={action} content={action}>
            <PlButton size="sm" variant="ghost" color="secondary">
              {action[0]}
            </PlButton>
          </PlTooltip>
        ))}
      </div>
    </PlTooltipProvider>
  );
}
