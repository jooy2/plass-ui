import { PlButton, PlModal, usePlDisclosure } from 'plass-ui';

export default function DisclosureDemo() {
  const dialog = usePlDisclosure();

  return (
    <>
      <PlButton onClick={dialog.onOpen}>Delete project</PlButton>

      <PlModal
        open={dialog.open}
        onOpenChange={dialog.setOpen}
        title="Delete this project?"
        description="Everything in it goes with it."
        actions={
          <>
            <PlButton variant="glass" color="secondary" onClick={dialog.onClose}>
              Cancel
            </PlButton>
            <PlButton color="danger" onClick={dialog.onClose}>
              Delete
            </PlButton>
          </>
        }
      />
    </>
  );
}
