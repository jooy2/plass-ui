import { useState } from 'react';
import { Button, TextField } from 'plass-ui';

/**
 * The home page's hero object.
 *
 * It is a sign-in card, and there is no Card component yet — so the sheet is
 * written here out of the library's own tokens. That is on purpose: a demo may
 * compose what the library does not ship, and the moment `Card` lands this file
 * becomes two lines shorter rather than being rewritten.
 */
function GlassIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.6" aria-hidden="true">
      <path d="M2.5 4.5h11v7h-11z" />
      <path d="m2.5 5 5.5 4 5.5-4" strokeLinejoin="round" />
    </svg>
  );
}

export default function HomeHero() {
  const [email, setEmail] = useState('ada@plass.dev');

  return (
    <div
      className="w-full max-w-sm rounded-2xl border p-6 [backdrop-filter:var(--plass-blur)] [-webkit-backdrop-filter:var(--plass-blur)]"
      style={{
        background: 'var(--plass-glass)',
        borderColor: 'var(--plass-glass-line)',
        boxShadow: 'var(--plass-shadow-3), var(--plass-gloss-glass)'
      }}
    >
      <p className="text-base font-bold text-(--plass-fg)">Sign in to Acme</p>
      <p className="mt-1 text-sm text-(--plass-muted-fg)">Two components, and this whole card.</p>

      <div className="mt-5 grid gap-4">
        <TextField
          fullWidth
          label="Email"
          type="email"
          value={email}
          startIcon={<GlassIcon />}
          onChange={(event) => setEmail(event.target.value)}
        />
        <TextField
          fullWidth
          label="Password"
          type="password"
          defaultValue="hunter2"
          description="At least 8 characters."
        />
      </div>

      <div className="mt-5 flex gap-3">
        <Button className="grow">Sign in</Button>
        <Button variant="glass" color="secondary">
          Cancel
        </Button>
      </div>
    </div>
  );
}
