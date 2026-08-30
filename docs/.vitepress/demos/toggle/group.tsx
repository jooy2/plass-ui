import { useState } from 'react';
import { PlToggle, PlToggleGroup } from 'plass-ui';

export default function ToggleGroupDemo() {
  const [align, setAlign] = useState<string[]>(['left']);
  const [marks, setMarks] = useState<string[]>(['bold']);

  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-col gap-2">
        <span className="text-xs text-(--plass-muted-fg)">
          One of a set — <code>{align.join(', ') || 'none'}</code>
        </span>
        <PlToggleGroup value={align} onValueChange={setAlign}>
          <PlToggle value="left">Left</PlToggle>
          <PlToggle value="center">Center</PlToggle>
          <PlToggle value="right">Right</PlToggle>
        </PlToggleGroup>
      </div>

      <div className="flex flex-col gap-2">
        <span className="text-xs text-(--plass-muted-fg)">
          multiple — <code>{marks.join(', ') || 'none'}</code>
        </span>
        <PlToggleGroup multiple value={marks} onValueChange={setMarks}>
          <PlToggle value="bold">Bold</PlToggle>
          <PlToggle value="italic">Italic</PlToggle>
          <PlToggle value="underline">Underline</PlToggle>
        </PlToggleGroup>
      </div>
    </div>
  );
}
