import { PlAvatar, PlChatBubble } from 'plass-ui';

export default function ChatBubbleHero() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      <PlChatBubble
        name="Nadia Rowan"
        time="09:12"
        avatar={<PlAvatar size="sm" name="Nadia Rowan" src="/samples/avatars/nadia-rowan.webp" />}
      >
        The gradient turns rather than shades. Have a look at the new fills.
      </PlChatBubble>

      <PlChatBubble side="end" variant="solid" time="09:14" status="read">
        Already did — the vermilion one is much better.
      </PlChatBubble>

      <PlChatBubble
        typing
        avatar={<PlAvatar size="sm" name="Nadia Rowan" src="/samples/avatars/nadia-rowan.webp" />}
      />
    </div>
  );
}
