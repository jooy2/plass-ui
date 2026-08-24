import { PlAccordion, PlAccordionItem, PlButton } from 'plass-ui';

function KeyIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.5" aria-hidden="true">
      <circle cx="5.5" cy="5.5" r="3" />
      <path d="M7.8 7.8 13 13m-2 0 1.5-1.5" strokeLinecap="round" />
    </svg>
  );
}

export default function AccordionSlots() {
  return (
    <PlAccordion defaultValue={['keys']} className="w-full max-w-lg">
      <PlAccordionItem
        value="keys"
        title="API keys"
        subtitle="Two active"
        startIcon={<KeyIcon />}
        action={
          <PlButton size="xs" variant="ghost">
            New key
          </PlButton>
        }
      >
        Keys are shown once, when they are created. Rotate one rather than sharing it.
      </PlAccordionItem>
      <PlAccordionItem value="webhooks" title="Webhooks" subtitle="None yet">
        Point a URL at an event and we will POST to it.
      </PlAccordionItem>
    </PlAccordion>
  );
}
