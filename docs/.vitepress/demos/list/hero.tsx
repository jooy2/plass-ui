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
          startIcon={<PlAvatar size="xs" name="Ada Lovelace" />}
          description="ada@example.com"
          action={<PlSwitch size="sm" defaultChecked aria-label="Notify Ada" />}
        >
          Ada Lovelace
        </PlListItem>
        <PlListItem
          startIcon={<PlAvatar size="xs" name="Grace Hopper" />}
          description="grace@example.com"
          action={<PlSwitch size="sm" aria-label="Notify Grace" />}
        >
          Grace Hopper
        </PlListItem>
      </PlList>
    </div>
  );
}
