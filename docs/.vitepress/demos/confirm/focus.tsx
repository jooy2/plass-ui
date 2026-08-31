import { PlButton, PlConfirmProvider, usePlConfirm } from 'plass-ui';

function Asks() {
  const { confirm } = usePlConfirm();

  return (
    <div className="flex flex-wrap justify-center gap-3">
      <PlButton
        color="danger"
        onClick={() =>
          confirm({
            title: 'Delete this project?',
            description: 'Enter lands on Cancel.',
            confirmLabel: 'Delete',
            color: 'danger'
          })
        }
      >
        Destructive
      </PlButton>

      <PlButton
        variant="glass"
        onClick={() =>
          confirm({
            title: 'Save before closing?',
            description: 'Enter lands on Save.',
            confirmLabel: 'Save',
            initialFocus: 'confirm'
          })
        }
      >
        Harmless
      </PlButton>
    </div>
  );
}

export default function ConfirmFocus() {
  return (
    <PlConfirmProvider>
      <Asks />
    </PlConfirmProvider>
  );
}
