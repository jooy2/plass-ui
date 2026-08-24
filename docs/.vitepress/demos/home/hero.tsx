import { useState } from 'react';
import { PlButton, PlCard, PlTextField } from 'plass-ui';

/**
 * The home page's hero object: a sign-in card, made of three components and
 * nothing else. No raw tokens, no hand-written sheet.
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
    <PlCard
      className="w-full max-w-sm"
      elevation={3}
      title="Sign in to Acme"
      subtitle="Three components, and this whole card."
      footer={
        <>
          <PlButton className="grow">Sign in</PlButton>
          <PlButton variant="glass" color="secondary">
            Cancel
          </PlButton>
        </>
      }
    >
      <div className="grid gap-4">
        <PlTextField
          fullWidth
          label="Email"
          type="email"
          value={email}
          startIcon={<GlassIcon />}
          onChange={(event) => setEmail(event.target.value)}
        />
        <PlTextField
          fullWidth
          label="Password"
          type="password"
          defaultValue="hunter2"
          description="At least 8 characters."
        />
      </div>
    </PlCard>
  );
}
