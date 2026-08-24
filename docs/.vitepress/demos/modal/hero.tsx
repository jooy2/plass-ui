import { PlButton, PlModal, PlModalClose, PlTextField } from 'plass-ui';

export default function ModalHero() {
  return (
    <PlModal
      trigger={<PlButton color="danger">Delete project</PlButton>}
      title="Delete “Aurora”?"
      description="Everything in it goes with it. This cannot be undone."
      actions={
        <>
          <PlModalClose
            render={
              <PlButton variant="ghost" color="secondary">
                Cancel
              </PlButton>
            }
          />
          <PlModalClose render={<PlButton color="danger">Delete</PlButton>} />
        </>
      }
    >
      <PlTextField fullWidth label="Type the project name to confirm" placeholder="Aurora" />
    </PlModal>
  );
}
