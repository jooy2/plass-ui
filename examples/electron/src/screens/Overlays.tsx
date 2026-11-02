import { useState } from 'react';
import {
  PlButton,
  PlCommandPalette,
  PlContextMenu,
  PlDrawer,
  PlDrawerClose,
  PlMenu,
  PlMenuItem,
  PlMenuSeparator,
  PlModal,
  PlModalClose,
  PlPopover,
  PlSwitch,
  PlTextField,
  PlTooltip,
  usePlConfirm,
  usePlToast,
  type PlCommandItem
} from 'plass-ui';

const commands: PlCommandItem[] = [
  { value: 'new', label: 'New project', group: 'File', shortcut: 'Mod+N' },
  { value: 'invite', label: 'Invite a colleague', group: 'Team' },
  { value: 'settings', label: 'Open settings', group: 'App' }
];

/** One button for each thing that floats over a window. */
export function Overlays() {
  const [palette, setPalette] = useState(false);
  const toast = usePlToast();
  const confirm = usePlConfirm();

  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-wrap gap-3">
        <PlModal
          trigger={<PlButton variant="glass">Modal</PlButton>}
          title="Rename project"
          description="It changes the address as well."
          actions={
            <>
              <PlModalClose
                render={
                  <PlButton variant="ghost" color="secondary">
                    Cancel
                  </PlButton>
                }
              />
              <PlModalClose render={<PlButton>Rename</PlButton>} />
            </>
          }
        >
          <PlTextField fullWidth label="Name" placeholder="Aurora" />
        </PlModal>

        <PlDrawer
          side="right"
          trigger={<PlButton variant="glass">Drawer</PlButton>}
          title="Filters"
          description="Show orders that are:"
          actions={<PlDrawerClose render={<PlButton>Done</PlButton>} />}
        >
          <div className="flex flex-col gap-3">
            <PlSwitch label="Paid" defaultChecked />
            <PlSwitch label="Open" defaultChecked />
            <PlSwitch label="Overdue" />
          </div>
        </PlDrawer>

        <PlPopover
          trigger={<PlButton variant="glass">Popover</PlButton>}
          title="Effective rate"
          description="Updated hourly"
        >
          The base rate plus whatever your plan adds to it.
        </PlPopover>

        <PlMenu trigger={<PlButton variant="glass">Menu</PlButton>}>
          <PlMenuItem>Cut</PlMenuItem>
          <PlMenuItem>Copy</PlMenuItem>
          <PlMenuItem>Paste</PlMenuItem>
          <PlMenuSeparator />
          <PlMenuItem color="danger">Delete</PlMenuItem>
        </PlMenu>

        <PlTooltip content="Saved two minutes ago">
          <PlButton variant="glass">Tooltip</PlButton>
        </PlTooltip>

        <PlButton
          variant="glass"
          onClick={() =>
            toast.add({
              color: 'success',
              title: 'Saved',
              description: 'Your changes are live.'
            })
          }
        >
          Toast
        </PlButton>

        <PlButton
          variant="glass"
          onClick={async () => {
            const ok = await confirm.confirm({
              title: 'Delete this project?',
              description: 'It cannot be undone.',
              confirmLabel: 'Delete',
              color: 'danger'
            });

            toast.add({ title: ok ? 'Deleted' : 'Kept' });
          }}
        >
          Confirm
        </PlButton>

        <PlButton variant="glass" onClick={() => setPalette(true)}>
          Command palette
        </PlButton>
      </div>

      <PlContextMenu
        content={
          <>
            <PlMenuItem>Rename</PlMenuItem>
            <PlMenuItem>Duplicate</PlMenuItem>
            <PlMenuSeparator />
            <PlMenuItem color="danger">Delete</PlMenuItem>
          </>
        }
      >
        <div className="grid h-40 place-items-center rounded-2xl border border-dashed border-(--plass-border) text-(--plass-muted-fg)">
          Right-click here
        </div>
      </PlContextMenu>

      <PlCommandPalette items={commands} open={palette} onOpenChange={setPalette} />
    </div>
  );
}
