import { PlButton, PlToastProvider, usePlToast } from 'plass-ui';

function Raise() {
  const toast = usePlToast();

  return (
    <div className="flex flex-wrap gap-2">
      {(['success', 'warning', 'danger', 'info'] as const).map((color) => (
        <PlButton
          key={color}
          size="sm"
          variant="glass"
          color={color}
          onClick={() =>
            toast.add({
              color,
              title: color,
              description: 'Each family draws its own shape as well as its own colour.',
              priority: color === 'danger' ? 'high' : 'low'
            })
          }
        >
          {color}
        </PlButton>
      ))}
    </div>
  );
}

export default function ToastColors() {
  return (
    <PlToastProvider timeout={4000}>
      <Raise />
    </PlToastProvider>
  );
}
