import { useState } from 'react';
import { PlChip } from 'plass-ui';

export default function ChipInteractive() {
  const [on, setOn] = useState(true);

  return (
    <div className="flex flex-wrap items-center gap-3">
      <PlChip>Not pressable</PlChip>
      <PlChip selected={on} onClick={() => setOn(!on)}>
        Pressable
      </PlChip>
      <PlChip onDelete={() => {}}>Removable</PlChip>
      <PlChip onClick={() => {}} onDelete={() => {}}>
        Both
      </PlChip>
      <PlChip disabled onClick={() => {}}>
        Disabled
      </PlChip>
    </div>
  );
}
