import { PlChatBubble } from 'plass-ui';

export default function ChatBubbleMedia() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      <PlChatBubble
        name="Grace Hopper"
        media={
          <img
            src="/portrait-2.svg"
            alt="A portrait"
            className="h-32 w-full bg-(--plass-glass) object-cover"
          />
        }
      >
        Drawn edge to edge, so the bubble’s own corners crop it.
      </PlChatBubble>

      <PlChatBubble
        side="end"
        variant="solid"
        preview={{
          url: '#chat-bubble',
          site: 'plass.cdget.com',
          title: 'Design language',
          description:
            'Why a Plass surface looks and behaves the way it does — the tinted-glass rule and everything that follows from it.'
        }}
      >
        Here is the page about it.
      </PlChatBubble>
    </div>
  );
}
