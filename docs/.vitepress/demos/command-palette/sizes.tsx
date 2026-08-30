import { useState } from 'react';
import { PlButton, PlCommandPalette, type PlassSize } from 'plass-ui';

const commands = [
  { value: 'new', label: 'New document' },
  { value: 'open', label: 'Open…' },
  { value: 'copy', label: 'Copy' }
];

export default function CommandPaletteSizes() {
  const [size, setSize] = useState<PlassSize | null>(null);

  return (
    <div className="flex flex-wrap items-center justify-center gap-2">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as PlassSize[]).map((step) => (
        <PlButton
          key={step}
          size="sm"
          variant="glass"
          color="secondary"
          onClick={() => setSize(step)}
        >
          {step}
        </PlButton>
      ))}

      <PlCommandPalette
        items={commands}
        size={size ?? 'md'}
        open={size !== null}
        onOpenChange={(next) => setSize(next ? size : null)}
        shortcut={false}
      />
    </div>
  );
}
