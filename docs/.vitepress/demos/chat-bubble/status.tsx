import { PlChatBubble } from 'plass-ui';

export default function ChatBubbleStatus() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      {(['sending', 'sent', 'delivered', 'read', 'failed'] as const).map((status) => (
        <PlChatBubble key={status} side="end" variant="solid" status={status}>
          {status}
        </PlChatBubble>
      ))}
    </div>
  );
}
