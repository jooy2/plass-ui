import { useState } from 'react';
import {
  PlAccordion,
  PlAccordionItem,
  PlButton,
  PlCard,
  PlPagination,
  PlTable,
  PlTextField
} from 'plass-ui';

/**
 * Every component the library has, on one screen.
 *
 * This is the page that has to be updated when a component is added, and the
 * reason it exists is that a component page shows a control on its own and a
 * screen shows it next to the others: a PlButton and a PlTextField of the same
 * `size` sitting on the same row is the only place the shared height ladder is
 * actually visible.
 */
function SearchIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.6" aria-hidden="true">
      <circle cx="7" cy="7" r="4.5" />
      <path d="m10.5 10.5 3 3" strokeLinecap="round" />
    </svg>
  );
}

export default function ShowcaseApp() {
  const [name, setName] = useState('Acme Inc');
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);

  function save() {
    setSaving(true);
    setSaved(false);
    window.setTimeout(() => {
      setSaving(false);
      setSaved(true);
    }, 900);
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-wrap items-center gap-3">
        <PlTextField
          size="md"
          placeholder="Search settings"
          startIcon={<SearchIcon />}
          className="grow"
        />
        <PlButton size="md" variant="glass" color="secondary">
          Filter
        </PlButton>
        <PlButton size="md">New</PlButton>
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <PlCard title="Organisation" elevation={2} render={<section />}>
          <div className="flex flex-col gap-4">
            <PlTextField
              fullWidth
              label="Name"
              value={name}
              description="Shown on invoices."
              onChange={(event) => setName(event.target.value)}
            />
            <PlTextField
              fullWidth
              label="Billing email"
              type="email"
              defaultValue="billing@"
              error="Enter a valid address."
            />
            <div className="flex items-center gap-3">
              <PlButton loading={saving} onClick={save}>
                {saving ? 'Saving' : 'Save changes'}
              </PlButton>
              <PlButton variant="ghost" color="secondary">
                Discard
              </PlButton>
              {saved ? (
                <span className="text-xs font-semibold text-(--plass-success-accent)">Saved</span>
              ) : null}
            </div>
          </div>
        </PlCard>

        <PlCard title="Danger zone" elevation={2} render={<section />}>
          <div className="flex flex-col gap-4">
            <PlTextField
              fullWidth
              variant="solid"
              label="Type the organisation name to confirm"
              placeholder={name}
            />
            <PlTextField
              fullWidth
              multiline
              rows={2}
              label="Why are you leaving?"
              variant="ghost"
            />
            <div className="flex items-center gap-3">
              <PlButton color="danger">Delete organisation</PlButton>
              <PlButton variant="glass" color="secondary" readOnly>
                Export first
              </PlButton>
            </div>
          </div>
        </PlCard>
      </div>

      <PlTable
        size="sm"
        hoverable
        caption="Recent invoices"
        columns={[
          { key: 'id', header: 'Invoice', width: 110 },
          { key: 'customer', header: 'Customer' },
          { key: 'total', header: 'Total', align: 'end' }
        ]}
        rows={[
          { id: 'INV-0102', customer: 'Acme Inc', total: '$1,240.00' },
          { id: 'INV-0101', customer: 'Globex', total: '$340.50' }
        ]}
      />

      <div className="flex justify-center">
        <PlPagination size="sm" count={12} defaultPage={4} />
      </div>

      <PlAccordion size="sm" defaultValue={['keys']}>
        <PlAccordionItem value="keys" title="API keys" subtitle="Two active">
          Keys are shown once, when they are created. Rotate one rather than sharing it.
        </PlAccordionItem>
        <PlAccordionItem value="webhooks" title="Webhooks" subtitle="None yet">
          Point a URL at an event and we will POST to it.
        </PlAccordionItem>
      </PlAccordion>
    </div>
  );
}
