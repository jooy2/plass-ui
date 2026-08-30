import { useState } from 'react';
import { PlButton, PlCommandPalette, type PlCommandItem } from 'plass-ui';

const commands: PlCommandItem[] = [
  { value: 'new', label: 'New document', group: 'File' },
  { value: 'open', label: 'Open…', group: 'File', keywords: ['load', 'import'] },
  { value: 'copy', label: 'Copy', group: 'Edit', description: 'Put it on the clipboard' },
  { value: 'paste', label: 'Paste', group: 'Edit', disabled: true },
  { value: 'zen', label: 'Zen mode', group: 'View', keywords: ['focus', 'distraction free'] }
];

export default function CommandPaletteGroups() {
  const [open, setOpen] = useState(false);

  return (
    <div className="flex flex-col items-center gap-2">
      <PlButton variant="glass" color="secondary" onClick={() => setOpen(true)}>
        Try “load”, or “distraction”
      </PlButton>
      <PlCommandPalette items={commands} open={open} onOpenChange={setOpen} shortcut={false} />
    </div>
  );
}
