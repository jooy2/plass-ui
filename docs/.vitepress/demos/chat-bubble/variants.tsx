import { PlChatBubble } from 'plass-ui';

export default function ChatBubbleVariants() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      {(['solid', 'glass', 'ghost'] as const).map((variant) => (
        <PlChatBubble key={variant} variant={variant} name={variant}>
          A bubble is the thing being coloured, so its sheet takes the tint.
        </PlChatBubble>
      ))}
    </div>
  );
}
