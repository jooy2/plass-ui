import { PlButton, PlPopconfirm } from 'plass-ui';

export default function PopconfirmAsync() {
  return (
    <PlPopconfirm
      title="Revoke this key?"
      description="Anything using it stops working."
      confirmLabel="Revoke"
      trigger={<PlButton color="danger">Revoke key</PlButton>}
      onConfirm={() => new Promise((resolve) => setTimeout(resolve, 1200))}
    />
  );
}
