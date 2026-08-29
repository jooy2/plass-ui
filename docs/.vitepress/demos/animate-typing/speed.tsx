import { useState } from 'react';
import { PlAnimateTyping, PlButton } from 'plass-ui';

export default function AnimateTypingSpeed() {
  const [run, setRun] = useState(0);

  return (
    <div className="flex flex-col items-center gap-4">
      <PlButton size="sm" variant="glass" color="secondary" onClick={() => setRun(run + 1)}>
        Play again
      </PlButton>

      <div className="flex flex-col gap-2 font-mono">
        {[8, 24, 60].map((speed) => (
          <PlAnimateTyping
            key={`${run}-${speed}`}
            speed={speed}
            text={`${speed} characters a second`}
          />
        ))}
      </div>
    </div>
  );
}
