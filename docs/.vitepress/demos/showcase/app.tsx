import { useState } from 'react';
import { Button, TextField } from 'plass-ui';

/**
 * Every component the library has, on one screen — which today is two of them.
 *
 * This is the page that has to be updated when a component is added, and the
 * reason it exists is that a component page shows a control on its own and a
 * screen shows it next to the others: a Button and a TextField of the same
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

function Sheet({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section
      className="flex flex-col gap-4 rounded-2xl border p-5 [backdrop-filter:var(--plass-blur)] [-webkit-backdrop-filter:var(--plass-blur)]"
      style={{
        background: 'var(--plass-glass)',
        borderColor: 'var(--plass-glass-line)',
        boxShadow: 'var(--plass-shadow-2), var(--plass-gloss-glass)'
      }}
    >
      <h3 className="text-sm font-bold text-(--plass-fg)">{title}</h3>
      {children}
    </section>
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
        <TextField
          size="md"
          placeholder="Search settings"
          startIcon={<SearchIcon />}
          className="grow"
        />
        <Button size="md" variant="glass" color="secondary">
          Filter
        </Button>
        <Button size="md">New</Button>
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <Sheet title="Organisation">
          <TextField
            fullWidth
            label="Name"
            value={name}
            description="Shown on invoices."
            onChange={(event) => setName(event.target.value)}
          />
          <TextField
            fullWidth
            label="Billing email"
            type="email"
            defaultValue="billing@"
            error="Enter a valid address."
          />
          <div className="flex items-center gap-3">
            <Button loading={saving} onClick={save}>
              {saving ? 'Saving' : 'Save changes'}
            </Button>
            <Button variant="ghost" color="secondary">
              Discard
            </Button>
            {saved ? (
              <span className="text-xs font-semibold text-(--plass-success-accent)">Saved</span>
            ) : null}
          </div>
        </Sheet>

        <Sheet title="Danger zone">
          <TextField
            fullWidth
            variant="solid"
            label="Type the organisation name to confirm"
            placeholder={name}
          />
          <TextField fullWidth multiline rows={2} label="Why are you leaving?" variant="ghost" />
          <div className="flex items-center gap-3">
            <Button color="danger">Delete organisation</Button>
            <Button variant="glass" color="secondary" readOnly>
              Export first
            </Button>
          </div>
        </Sheet>
      </div>
    </div>
  );
}
