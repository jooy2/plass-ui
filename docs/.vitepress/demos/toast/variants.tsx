import { PlButton, PlToastProvider, usePlToast } from 'plass-ui';

function Raise() {
  const toast = usePlToast();

  return (
    <div className="flex flex-wrap gap-2">
      {(['solid', 'glass', 'ghost'] as const).map((variant) => (
        <PlButton
          key={variant}
          size="sm"
          variant="glass"
          color="secondary"
          onClick={() => toast.add({ variant, title: variant, description: 'One of three.' })}
        >
          {variant}
        </PlButton>
      ))}
    </div>
  );
}

export default function ToastVariants() {
  return (
    <PlToastProvider timeout={4000}>
      <Raise />
    </PlToastProvider>
  );
}
