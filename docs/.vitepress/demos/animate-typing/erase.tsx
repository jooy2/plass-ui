import { PlAnimateTyping } from 'plass-ui';

export default function AnimateTypingErase() {
  return (
    <div className="flex flex-col items-center gap-2 font-mono">
      <PlAnimateTyping
        text="rewritten, not replaced"
        speed={18}
        hold={900}
        erase
        repeat="infinite"
      />

      <PlAnimateTyping
        text="replaced in one frame"
        speed={18}
        hold={900}
        repeat="infinite"
        caret={false}
      />
    </div>
  );
}
