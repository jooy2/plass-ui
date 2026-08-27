import { useState } from 'react';
import { PlButton, PlDrawer, PlDrawerClose, PlSwitch } from 'plass-ui';

export default function DrawerHero() {
  const [open, setOpen] = useState(false);

  return (
    <PlDrawer
      side="right"
      open={open}
      onOpenChange={setOpen}
      trigger={<PlButton variant="glass">Filters</PlButton>}
      title="Filters"
      description="Nothing is applied yet"
      actions={
        <>
          <PlDrawerClose render={<PlButton variant="ghost">Cancel</PlButton>} />
          <PlDrawerClose render={<PlButton>Apply</PlButton>} />
        </>
      }
    >
      <div className="flex flex-col gap-3">
        <PlSwitch label="In stock only" defaultChecked />
        <PlSwitch label="On sale" />
        <PlSwitch label="Free delivery" />
      </div>
    </PlDrawer>
  );
}
