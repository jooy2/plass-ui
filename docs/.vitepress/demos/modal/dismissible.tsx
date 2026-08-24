import { PlButton, PlModal, PlModalClose } from 'plass-ui';

export default function ModalDismissible() {
  return (
    <PlModal
      dismissible={false}
      showClose={false}
      size="sm"
      trigger={<PlButton variant="glass">Finish setup</PlButton>}
      title="One more thing"
      description="Escape and a click outside are both off, so the actions are the only way out."
      actions={<PlModalClose render={<PlButton>I understand</PlButton>} />}
    />
  );
}
