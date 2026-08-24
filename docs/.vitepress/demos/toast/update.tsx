import { PlButton, PlToastProvider, usePlToast } from 'plass-ui';

function Upload() {
  const toast = usePlToast();

  function start() {
    toast.add({ id: 'upload', title: 'Uploading…', icon: false, timeout: 0 });

    window.setTimeout(
      () => toast.update('upload', { id: 'upload', color: 'success', title: 'Uploaded' }),
      1600
    );
  }

  return (
    <PlButton size="sm" onClick={start}>
      Upload a file
    </PlButton>
  );
}

export default function ToastUpdate() {
  return (
    <PlToastProvider>
      <Upload />
    </PlToastProvider>
  );
}
