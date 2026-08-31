import { PlButton, PlConfirmProvider, usePlConfirm } from 'plass-ui';

function Teller() {
  const { alert } = usePlConfirm();

  return (
    <PlButton
      variant="glass"
      onClick={async () => {
        await alert({
          title: 'Your session expired.',
          description: 'Sign in again to carry on where you left off.'
        });
      }}
    >
      Show an alert
    </PlButton>
  );
}

export default function ConfirmAlert() {
  return (
    <PlConfirmProvider>
      <Teller />
    </PlConfirmProvider>
  );
}
