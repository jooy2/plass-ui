import { PlChatBubble } from 'plass-ui';

export default function ChatBubbleSizes() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <PlChatBubble key={size} size={size} name={size} time="09:12">
          The corner cut is a flat 4px at every step.
        </PlChatBubble>
      ))}
    </div>
  );
}
