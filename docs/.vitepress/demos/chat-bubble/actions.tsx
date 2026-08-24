import { PlButton, PlChatBubble } from 'plass-ui';

export default function ChatBubbleActions() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      <PlChatBubble
        name="Ada Lovelace"
        actions={
          <PlButton size="xs" variant="ghost" color="secondary" aria-label="More">
            ⋯
          </PlButton>
        }
      >
        Hover this row, or move focus into it.
      </PlChatBubble>
    </div>
  );
}
