import { PlButton, PlCollapsible } from 'plass-ui';

export default function CollapsibleTrigger() {
  return (
    <PlCollapsible
      className="w-full max-w-md"
      variant="ghost"
      trigger={<PlButton variant="ghost">Show the details</PlButton>}
    >
      The element you pass becomes the trigger: it is handed the click handler, the
      <code> aria-expanded</code> and the <code>aria-controls</code> pointing at the panel.
    </PlCollapsible>
  );
}
