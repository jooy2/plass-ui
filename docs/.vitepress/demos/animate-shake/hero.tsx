import { useState } from 'react';
import { PlAnimateShake, PlButton, PlTextField } from 'plass-ui';

export default function AnimateShakeHero() {
  const [attempts, setAttempts] = useState(0);

  return (
    <div className="flex w-full max-w-xs flex-col gap-4">
      <PlAnimateShake replay={attempts}>
        <PlTextField
          label="Password"
          type="password"
          fullWidth
          invalid={attempts > 0}
          error={attempts > 0 ? 'That password is wrong.' : undefined}
        />
      </PlAnimateShake>

      <PlButton onClick={() => setAttempts((count) => count + 1)}>Sign in</PlButton>
    </div>
  );
}
