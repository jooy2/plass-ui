import { PlButton, PlToastProvider, usePlToast } from 'plass-ui';

function Deploy() {
  const toast = usePlToast();

  function run(succeed: boolean) {
    const work = new Promise<string>((resolve, reject) =>
      window.setTimeout(() => (succeed ? resolve('v128') : reject(new Error('health check'))), 1600)
    );

    toast.promise(work, {
      loading: { title: 'Deploying…', icon: false },
      success: (version) => ({ color: 'success', title: `Deployed ${version}` }),
      error: (error) => ({
        color: 'danger',
        title: 'The deploy failed',
        description: String((error as Error).message)
      })
    });
  }

  return (
    <div className="flex flex-wrap gap-2">
      <PlButton size="sm" onClick={() => run(true)}>
        Deploy
      </PlButton>
      <PlButton size="sm" variant="glass" color="danger" onClick={() => run(false)}>
        Deploy badly
      </PlButton>
    </div>
  );
}

export default function ToastPromise() {
  return (
    <PlToastProvider>
      <Deploy />
    </PlToastProvider>
  );
}
