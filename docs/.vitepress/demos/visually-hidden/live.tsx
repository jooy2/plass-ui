import { useState } from 'react';
import { PlButton, PlVisuallyHidden } from 'plass-ui';

export default function VisuallyHiddenLive() {
  const [count, setCount] = useState(0);

  return (
    <div className="flex flex-col items-center gap-3">
      <PlButton onClick={() => setCount((n) => n + 1)}>Add one</PlButton>

      <span className="text-sm text-(--plass-muted-fg)">{count} in the basket</span>

      <PlVisuallyHidden aria-live="polite" render={<div />}>
        {count} items in the basket
      </PlVisuallyHidden>
    </div>
  );
}
