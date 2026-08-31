import { useState } from 'react';
import { PlHotKeys, PlTextField } from 'plass-ui';

export default function TextFieldHotKeys() {
  const [note, setNote] = useState('');
  const [saved, setSaved] = useState<string | null>(null);

  return (
    <div className="flex w-full max-w-sm flex-col gap-4">
      <PlTextField
        fullWidth
        multiline
        rows={3}
        label="Note"
        placeholder="Write something, then press the shortcut"
        value={note}
        onChange={(event) => setNote(event.target.value)}
        description={
          <span className="flex items-center gap-1.5">
            <PlHotKeys keys="Mod+Enter" size="xs" /> to save, <PlHotKeys keys="Escape" size="xs" />{' '}
            to clear
          </span>
        }
        hotKeys={{
          'Mod+Enter': () => setSaved(note),
          Escape: () => {
            setNote('');
            setSaved(null);
          }
        }}
      />

      <p className="text-sm text-(--plass-muted-fg)">
        {saved === null ? 'Nothing saved yet.' : `Saved: ${saved}`}
      </p>
    </div>
  );
}
