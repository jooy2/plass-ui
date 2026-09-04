import { useRef } from 'react';
import { PlCard, usePlElementSize } from 'plass-ui';

export default function ElementSizeDemo() {
  const box = useRef<HTMLDivElement>(null);
  const size = usePlElementSize(box);

  return (
    <PlCard className="w-full max-w-md">
      <div ref={box} className="resize-x overflow-auto p-4 [min-width:12rem]">
        <p className="text-sm text-(--plass-muted-fg)">
          Drag the corner. The figure below is this box's content width and height, without its
          padding.
        </p>
      </div>

      <p className="mt-3 font-mono text-sm tabular-nums">
        {size ? `${Math.round(size.width)} × ${Math.round(size.height)}` : 'not measured yet'}
      </p>
    </PlCard>
  );
}
