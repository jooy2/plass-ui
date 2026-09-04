import { useRef } from 'react';
import { PlChip, usePlOnScreen } from 'plass-ui';

export default function OnScreenDemo() {
  const panel = useRef<HTMLDivElement>(null);
  const target = useRef<HTMLDivElement>(null);
  const seen = usePlOnScreen(target, { root: panel, once: false, threshold: 0.5 });

  return (
    <div className="flex w-full max-w-sm flex-col gap-3">
      <PlChip color={seen ? 'success' : 'secondary'}>{seen ? 'on screen' : 'not on screen'}</PlChip>

      <div
        ref={panel}
        className="h-40 overflow-auto rounded-(--plass-radius-md) border border-(--plass-border) p-3"
      >
        <p className="text-sm text-(--plass-muted-fg)">Scroll down.</p>
        <div className="h-40" />
        <div
          ref={target}
          className="rounded-(--plass-radius-sm) bg-(--plass-glass-press) p-4 text-center text-sm"
        >
          the watched element
        </div>
        <div className="h-40" />
      </div>
    </div>
  );
}
