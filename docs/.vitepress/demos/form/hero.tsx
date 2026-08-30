import { useState } from 'react';
import { PlAlert, PlButton, PlForm, PlTextField } from 'plass-ui';

export default function FormHero() {
  const [submitted, setSubmitted] = useState<Record<string, unknown> | null>(null);

  return (
    <div className="flex w-full max-w-sm flex-col gap-4">
      <PlForm onSubmit={setSubmitted}>
        <PlTextField
          name="email"
          type="email"
          label="Email"
          placeholder="ada@example.com"
          required
        />
        <PlTextField name="password" type="password" label="Password" required minLength={8} />
        <PlButton type="submit" fullWidth>
          Sign in
        </PlButton>
      </PlForm>

      {submitted ? (
        <PlAlert color="success" title="Submitted">
          {Object.entries(submitted)
            .map(([key, value]) => `${key}: ${String(value)}`)
            .join(' · ')}
        </PlAlert>
      ) : null}
    </div>
  );
}
