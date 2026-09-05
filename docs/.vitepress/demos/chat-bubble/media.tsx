import { PlChatBubble } from 'plass-ui';

export default function ChatBubbleMedia() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      <PlChatBubble
        name="Theo Quinn"
        media={
          <img
            src="/samples/photos/snowy-cabin-frozen-stream.webp"
            alt="A cabin in the snow beside a frozen stream"
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
          image: '/samples/illustrations/four-season-geometric-pattern.webp',
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
