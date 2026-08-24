import { PlButton, PlTooltip, PlTooltipProvider } from 'plass-ui';

function CopyIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.5">
      <rect x="5.5" y="5.5" width="8" height="8" rx="2" />
      <path d="M10.5 3.5a2 2 0 0 0-2-2h-4a3 3 0 0 0-3 3v4a2 2 0 0 0 2 2" strokeLinecap="round" />
    </svg>
  );
}

export default function TooltipHero() {
  return (
    <PlTooltipProvider>
      <div className="flex flex-wrap items-center gap-3">
        <PlTooltip content="Copy to clipboard">
          <PlButton variant="glass" color="secondary" aria-label="Copy">
            <CopyIcon />
          </PlButton>
        </PlTooltip>

        <PlTooltip content="Nothing is deleted until you confirm" side="bottom">
          <PlButton variant="ghost" color="danger">
            Delete
          </PlButton>
        </PlTooltip>

        <PlTooltip content="Saved two minutes ago" side="right">
          <span className="text-sm text-(--plass-muted-fg) underline decoration-dotted">Saved</span>
        </PlTooltip>
      </div>
    </PlTooltipProvider>
  );
}
