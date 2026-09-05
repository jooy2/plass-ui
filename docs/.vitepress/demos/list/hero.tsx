import { useState } from 'react';
import { PlAvatar, PlBadge, PlList, PlListItem, PlSwitch } from 'plass-ui';

export default function ListHero() {
  const [selected, setSelected] = useState('inbox');

  return (
    <div className="flex w-full max-w-md flex-col gap-5">
      <PlList>
        {[
          { id: 'inbox', label: 'Inbox', description: 'Three unread' },
          { id: 'drafts', label: 'Drafts', description: 'One saved' },
          { id: 'archive', label: 'Archive', description: 'Everything else' }
        ].map((row) => (
          <PlListItem
            key={row.id}
            description={row.description}
            selected={selected === row.id}
            onClick={() => setSelected(row.id)}
            endIcon={row.id === 'inbox' ? <PlBadge size="xs" variant="ghost" content={3} /> : null}
          >
            {row.label}
          </PlListItem>
        ))}
      </PlList>

      <PlList dividers>
        <PlListItem
          startIcon={
            <PlAvatar size="xs" name="Nadia Rowan" src="/samples/avatars/nadia-rowan.webp" />
          }
          description="nadia@example.com"
          action={<PlSwitch size="sm" defaultChecked aria-label="Notify Nadia" />}
        >
          Nadia Rowan
        </PlListItem>
        <PlListItem
          startIcon={
            <PlAvatar size="xs" name="Theo Quinn" src="/samples/avatars/theo-quinn.webp" />
          }
          description="theo@example.com"
          action={<PlSwitch size="sm" aria-label="Notify Theo" />}
        >
          Theo Quinn
        </PlListItem>
      </PlList>
    </div>
  );
}
