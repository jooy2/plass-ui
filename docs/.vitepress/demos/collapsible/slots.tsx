import { PlCollapsible, PlSwitch } from 'plass-ui';

function BellGlyph() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" className="size-4">
      <path d="M6 9a6 6 0 1 1 12 0c0 4 1.5 5.5 1.5 5.5h-15S6 13 6 9Z" strokeLinejoin="round" />
      <path d="M10 18a2 2 0 0 0 4 0" strokeLinecap="round" />
    </svg>
  );
}

export default function CollapsibleSlots() {
  return (
    <PlCollapsible
      className="w-full max-w-md"
      title="Notifications"
      subtitle="Email and push"
      startIcon={<BellGlyph />}
      action={<PlSwitch size="sm" label="On" defaultChecked />}
    >
      The switch is outside the trigger, because a header that both folds and holds a control has
      two things to press and one of them cannot be nested inside the other.
    </PlCollapsible>
  );
}
