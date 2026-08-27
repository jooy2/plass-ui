import { useState } from 'react';
import { PlButton, PlPopover, PlPopoverClose, PlTextField } from 'plass-ui';

export default function PopoverForm() {
  const [name, setName] = useState('Untitled view');

  return (
    <PlPopover
      showClose
      width={320}
      trigger={<PlButton>Rename</PlButton>}
      title="Rename this view"
      description="Everyone on the team sees it"
    >
      <div className="flex flex-col gap-3">
        <PlTextField label="Name" value={name} onChange={(event) => setName(event.target.value)} />
        <div className="flex justify-end gap-2">
          <PlPopoverClose render={<PlButton variant="ghost">Cancel</PlButton>} />
          <PlPopoverClose render={<PlButton>Save</PlButton>} />
        </div>
      </div>
    </PlPopover>
  );
}
