import { PlButton, PlToastProvider, usePlToast } from 'plass-ui';

function Actions() {
  const toast = usePlToast();

  return (
    <div className="flex flex-wrap gap-2">
      <PlButton
        size="sm"
        onClick={() =>
          toast.add({ color: 'success', title: 'Saved', description: 'Your changes are live.' })
        }
      >
        Save
      </PlButton>

      <PlButton
        size="sm"
        variant="glass"
        color="danger"
        onClick={() =>
          toast.add({
            color: 'danger',
            title: 'Deleted “Aurora”',
            timeout: 0,
            actionLabel: 'Undo',
            onAction: () => toast.add({ color: 'info', title: 'Restored' })
          })
        }
      >
        Delete
      </PlButton>
    </div>
  );
}

export default function ToastHero() {
  return (
    <PlToastProvider position="bottom-end">
      <Actions />
    </PlToastProvider>
  );
}
