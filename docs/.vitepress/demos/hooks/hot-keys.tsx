import { useState } from 'react';
import { PlAlert, PlHotKeys, PlTextField, usePlHotKeys } from 'plass-ui';

export default function HotKeysDemo() {
  const [last, setLast] = useState<string | null>(null);
  const [saved, setSaved] = useState(0);

  usePlHotKeys({
    'Mod+S': () => {
      setSaved((n) => n + 1);
      setLast('Mod+S');
    },
    '/': () => setLast('/'),
    Escape: () => setLast('Escape')
  });

  return (
    <div className="flex w-full flex-col gap-3">
      <div className="flex flex-wrap items-center gap-3 text-sm">
        <PlHotKeys size="sm" keys="Mod+S" />
        <PlHotKeys size="sm" keys="/" />
        <PlHotKeys size="sm" keys="Escape" />
      </div>

      <PlTextField
        label="Type here"
        description="The slash is typed; Mod+S and Escape still fire"
      />

      <PlAlert size="sm" color={last ? 'success' : 'info'}>
        {last ? `Last chord: ${last}. Saved ${saved} times.` : 'Press one of the three.'}
      </PlAlert>
    </div>
  );
}
