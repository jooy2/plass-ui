import { useState } from 'react';
import { PlButton, PlConfirmProvider, PlTypography, usePlConfirm } from 'plass-ui';

function DeleteButton({ onResult }: { onResult: (text: string) => void }) {
  const { confirm } = usePlConfirm();

  return (
    <PlButton
      color="danger"
      onClick={async () => {
        const ok = await confirm({
          title: 'Delete this project?',
          description: 'Ten members lose access, and it cannot be undone.',
          confirmLabel: 'Delete',
          color: 'danger'
        });

        onResult(ok ? 'Deleted.' : 'Kept.');
      }}
    >
      Delete project
    </PlButton>
  );
}

export default function ConfirmHero() {
  const [result, setResult] = useState<string | null>(null);

  return (
    <PlConfirmProvider>
      <div className="flex flex-col items-center gap-3">
        <DeleteButton onResult={setResult} />
        <PlTypography level="body" className="text-(--plass-muted-fg)">
          {result ?? 'Nothing has happened yet.'}
        </PlTypography>
      </div>
    </PlConfirmProvider>
  );
}
