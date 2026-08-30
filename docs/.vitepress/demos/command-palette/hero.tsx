import { useState } from 'react';
import { PlAlert, PlButton, PlCommandPalette, type PlCommandItem } from 'plass-ui';

export default function CommandPaletteHero() {
  const [open, setOpen] = useState(false);
  const [ran, setRan] = useState<string | null>(null);

  const commands: PlCommandItem[] = [
    { value: 'new', label: 'New document', group: 'File', shortcut: 'Mod+N' },
    { value: 'open', label: 'Open…', group: 'File', shortcut: 'Mod+O', keywords: ['load'] },
    { value: 'export', label: 'Export as PDF', group: 'File', description: 'The whole document' },
    { value: 'copy', label: 'Copy', group: 'Edit', shortcut: 'Mod+C' },
    { value: 'find', label: 'Find in page', group: 'Edit', shortcut: 'Mod+F' },
    { value: 'theme', label: 'Toggle dark mode', group: 'View' },
    { value: 'sidebar', label: 'Toggle sidebar', group: 'View', shortcut: 'Mod+B' }
  ];

  return (
    <div className="flex flex-col items-center gap-4">
      <PlButton onClick={() => setOpen(true)}>Open the palette</PlButton>
      <span className="text-xs text-(--plass-muted-fg)">…or press ⌘K / Ctrl+K.</span>

      {ran ? (
        <PlAlert color="success" title="Ran">
          {ran}
        </PlAlert>
      ) : null}

      <PlCommandPalette
        items={commands}
        open={open}
        onOpenChange={setOpen}
        onSelect={(item) => setRan(item.label)}
      />
    </div>
  );
}
