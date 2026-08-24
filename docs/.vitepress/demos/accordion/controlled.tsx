import { useState } from 'react';
import { PlAccordion, PlAccordionItem, PlButton } from 'plass-ui';

const sections = ['account', 'billing', 'team'];

export default function AccordionControlled() {
  const [open, setOpen] = useState<(string | number)[]>(['account']);

  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      <div className="flex flex-wrap gap-2">
        <PlButton size="xs" variant="glass" onClick={() => setOpen(sections)}>
          Open all
        </PlButton>
        <PlButton size="xs" variant="glass" onClick={() => setOpen([])}>
          Close all
        </PlButton>
      </div>

      <PlAccordion multiple value={open} onValueChange={setOpen}>
        <PlAccordionItem value="account" title="Account">
          Your name, your avatar, your language.
        </PlAccordionItem>
        <PlAccordionItem value="billing" title="Billing">
          Cards, invoices and the plan you are on.
        </PlAccordionItem>
        <PlAccordionItem value="team" title="Team">
          Who else is here and what they can do.
        </PlAccordionItem>
      </PlAccordion>
    </div>
  );
}
