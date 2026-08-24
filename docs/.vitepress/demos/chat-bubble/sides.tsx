import { PlChatBubble } from 'plass-ui';

export default function ChatBubbleSides() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      <PlChatBubble>Theirs, at the start. The near corner is cut short.</PlChatBubble>
      <PlChatBubble side="end" variant="solid">
        Yours, at the end. The other corner is.
      </PlChatBubble>
    </div>
  );
}
