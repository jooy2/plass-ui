import { useMemo, useState } from 'react';
import {
  PlAvatar,
  PlBadge,
  PlButton,
  PlCard,
  PlChatBubble,
  PlChip,
  PlEmpty,
  PlList,
  PlListItem,
  PlTextField
} from 'plass-ui';

interface Conversation {
  id: string;
  name: string;
  image?: string;
  subject: string;
  preview: string;
  time: string;
  unread: number;
}

const conversations: Conversation[] = [
  {
    id: 'nadia',
    name: 'Nadia Rowan',
    image: '/samples/avatars/nadia-rowan.webp',
    subject: 'Spring release',
    preview: 'The gradient turns rather than shades. Have a look at the new fills before Friday.',
    time: '09:12',
    unread: 3
  },
  {
    id: 'theo',
    name: 'Theo Quinn',
    image: '/samples/avatars/theo-quinn.webp',
    subject: 'Invoice INV-0104',
    preview: 'Paid in full, thank you.',
    time: '08:47',
    unread: 0
  },
  {
    id: 'anya',
    name: 'Anya Sol',
    image: '/samples/avatars/anya-sol.webp',
    subject: 'Design review',
    preview: 'Can we move it to Thursday afternoon?',
    time: 'Mon',
    unread: 1
  },
  {
    id: 'ines',
    name: 'Ines Holm',
    subject: 'Support rota',
    preview: 'I can cover the weekend.',
    time: 'Sat',
    unread: 0
  }
];

/** Two panes: the conversations and the one that is open. */
export function Inbox() {
  const [query, setQuery] = useState('');
  const [unreadOnly, setUnreadOnly] = useState(false);
  const [openId, setOpenId] = useState(conversations[0].id);
  const [draft, setDraft] = useState('');
  const [sent, setSent] = useState<string[]>([]);

  const found = useMemo(() => {
    const needle = query.trim().toLowerCase();

    return conversations.filter((one) => {
      const matches =
        needle === '' ||
        one.name.toLowerCase().includes(needle) ||
        one.subject.toLowerCase().includes(needle);

      return matches && (!unreadOnly || one.unread > 0);
    });
  }, [query, unreadOnly]);

  const open = conversations.find((one) => one.id === openId)!;

  const send = () => {
    if (draft.trim()) {
      setSent((list) => [...list, draft.trim()]);
      setDraft('');
    }
  };

  return (
    <div className="grid h-full min-h-0 grid-cols-[20rem_1fr] gap-4">
      <div className="flex min-h-0 flex-col gap-3">
        <PlTextField
          fullWidth
          aria-label="Search"
          placeholder="Search people and subjects"
          value={query}
          onChange={(event) => setQuery(event.target.value)}
        />
        <div className="flex gap-2">
          <PlChip selected={!unreadOnly} onClick={() => setUnreadOnly(false)}>
            All
          </PlChip>
          <PlChip selected={unreadOnly} onClick={() => setUnreadOnly(true)}>
            Unread
          </PlChip>
        </div>
        {found.length === 0 ? (
          <PlCard>
            <PlEmpty
              title="Nothing found"
              description="Try another name or subject."
              actions={
                <PlButton variant="glass" onClick={() => setQuery('')}>
                  Clear the search
                </PlButton>
              }
            />
          </PlCard>
        ) : (
          <PlList dividers className="min-h-0 overflow-auto">
            {found.map((one) => (
              <PlListItem
                key={one.id}
                selected={one.id === openId}
                onClick={() => setOpenId(one.id)}
                startIcon={<PlAvatar size="sm" name={one.name} src={one.image} />}
                description={one.subject}
                endIcon={one.unread > 0 ? <PlBadge size="xs" content={one.unread} /> : one.time}
              >
                {one.name}
              </PlListItem>
            ))}
          </PlList>
        )}
      </div>

      <div className="flex min-h-0 flex-col gap-3">
        <div className="flex min-h-0 flex-1 flex-col gap-4 overflow-auto">
          <PlChatBubble
            name={open.name}
            time={open.time}
            avatar={<PlAvatar size="sm" name={open.name} src={open.image} />}
          >
            {open.preview}
          </PlChatBubble>
          {sent.map((text, index) => (
            <PlChatBubble key={index} side="end" variant="solid" status="sent">
              {text}
            </PlChatBubble>
          ))}
        </div>
        <form
          className="flex gap-2"
          onSubmit={(event) => {
            event.preventDefault();
            send();
          }}
        >
          <PlTextField
            fullWidth
            aria-label="Reply"
            placeholder="Write a reply"
            value={draft}
            onChange={(event) => setDraft(event.target.value)}
          />
          <PlButton type="submit">Send</PlButton>
        </form>
      </div>
    </div>
  );
}
